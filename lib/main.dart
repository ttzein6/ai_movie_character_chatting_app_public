import 'dart:developer';

import 'package:ai_char_chat_app/blocs/app_bloc/app_bloc.dart';
import 'package:ai_char_chat_app/blocs/light_dark_bloc/light_dark_bloc.dart';
import 'package:ai_char_chat_app/firebase_options.dart';
import 'package:ai_char_chat_app/screens/api_setup/api_setup_screen.dart';
import 'package:ai_char_chat_app/screens/email_verification/email_verification_screen.dart';
import 'package:ai_char_chat_app/screens/main_screen.dart';
import 'package:ai_char_chat_app/services/api_key_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/onboarding_screen/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize HydratedBloc storage

  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LightDarkBloc(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => AppBloc(firebaseAuth: FirebaseAuth.instance),
        ),
      ],
      child: BlocBuilder<LightDarkBloc, LightDarkState>(
        builder: (context, state) {
          log("state : $state");
          return MaterialApp(
            title: 'AI Character Chatting App',
            debugShowCheckedModeBanner: false,
            themeMode: state is DarkMode
                ? ThemeMode.dark
                : state is LightMode
                    ? ThemeMode.light
                    : ThemeMode.system,
            theme: ThemeData(
              brightness:
                  state is DarkMode ? Brightness.dark : Brightness.light,
              // primaryColorDark: Color(0xff1e1e1e),
              useMaterial3: true,
              primarySwatch: Colors.blue,
              // scaffoldBackgroundColor: const Color(0xFFEEF1F8),
              fontFamily: "Intel",
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                // fillColor: Colors.white,

                errorStyle: TextStyle(height: 0),
                border: defaultInputBorder,
                enabledBorder: defaultInputBorder,
                focusedBorder: defaultInputBorder,
                errorBorder: defaultInputBorder,
              ),
            ),

            home: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state is UserLoggedIn) {
                  return const ApiKeyCheckWrapper();
                } else {
                  return const OnboardingScreen();
                }
              },
            ),
            //  MainScreen(),
          );
        },
      ),
    );
  }
}

/// Wrapper widget that checks email verification and API keys
/// before showing the main screen
class ApiKeyCheckWrapper extends StatelessWidget {
  const ApiKeyCheckWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // First check: Email verification
    if (user != null && !user.emailVerified) {
      return const EmailVerificationScreen();
    }

    // Second check: API keys configuration
    final apiKeyService = ApiKeyService();

    return FutureBuilder<bool>(
      future: apiKeyService.areKeysConfigured(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const MainScreen();
        } else {
          return const ApiSetupScreen();
        }
      },
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
