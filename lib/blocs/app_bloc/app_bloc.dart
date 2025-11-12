import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  final FirebaseAuth _firebaseAuth;
  User? currentUser;

  AppBloc({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(AppInitial()) {
    // Check if user is already logged in
    currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      emit(UserLoggedIn());
    }

    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null && state is! UserLoggedIn) {
        currentUser = user;
        add(LoginEvent(user: user));
      } else if (user == null && state is UserLoggedIn) {
        currentUser = null;
        add(LogoutEvent());
      }
    });

    on<LoginEvent>((event, emit) {
      currentUser = event.user;
      emit(UserLoggedIn());
    });

    on<LogoutEvent>((event, emit) async {
      await _firebaseAuth.signOut();
      currentUser = null;
      emit(AppInitial());
    });
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    log("Restoring state from JSON: $json");
    // Firebase Auth handles session persistence automatically
    // We just need to check if there's a current user
    if (_firebaseAuth.currentUser != null) {
      currentUser = _firebaseAuth.currentUser;
      return UserLoggedIn();
    }
    return AppInitial();
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    log("Saving state to JSON: $state");
    if (state is UserLoggedIn && currentUser != null) {
      return {
        "state": "loggedIn",
        "userId": currentUser?.uid,
      };
    }
    return null;
  }
}
