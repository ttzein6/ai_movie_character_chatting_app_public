part of 'app_bloc.dart';

abstract class AppEvent {}

class LoginEvent extends AppEvent {
  User user;
  LoginEvent({required this.user});
}

class LogoutEvent extends AppEvent {}
