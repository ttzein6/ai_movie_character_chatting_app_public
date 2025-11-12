# AI Character Chat App

A Flutter application that lets you chat with AI-powered movie characters using Google's Gemini AI. Browse characters from your favorite movies and have realistic conversations as if you're talking to the actual character!

## Features

- **Firebase Authentication**: Secure login and signup with email and password
- **Movie Character Search**: Browse and discover characters from various movies
- **AI-Powered Chat**: Have conversations with characters powered by Google's Gemini AI
- **Character Personas**: Each character maintains their personality, speech patterns, and mannerisms from their movie
- **Chat History**: Your conversations are saved locally for later access
- **Netflix-Style UI**: Modern, polished interface with smooth animations
- **Dark Mode**: Beautiful dark theme for comfortable viewing

## Prerequisites

Before running this app, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK version 3.4.1 or higher)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)
- An iOS Simulator, Android Emulator, or physical device
- A Firebase project (for authentication)
- A Google Gemini API key (for AI chat functionality)
- A TMDb API key (for movie/character search)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/ttzein6/ai_movie_character_chatting_app_public.git
cd ai_movie_character_chatting_app_public
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

This app uses **Firebase Authentication** with email and password for user login.

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable Email/Password authentication:
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" provider
3. Download the configuration files:
   - **For Android**: Download `google-services.json` and place it in `android/app/`
   - **For iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`
4. Follow the [FlutterFire setup guide](https://firebase.google.com/docs/flutter/setup) for additional platform-specific configuration

### 4. API Keys Setup

You'll need to configure API keys when you first run the app:

1. **Google Gemini API Key**:
   - Get your key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Enter it in the app's Settings screen

2. **TMDb API Key** (for movie/character search):
   - Sign up at [The Movie Database](https://www.themoviedb.org/)
   - Get your API key from [API Settings](https://www.themoviedb.org/settings/api)
   - Enter it in the app's Settings screen

## Running the App

### Run on an Emulator/Simulator

```bash
# For iOS (macOS only)
flutter run -d ios

# For Android
flutter run -d android
```

### Run on a Physical Device

1. Connect your device via USB
2. Enable USB debugging (Android) or trust the computer (iOS)
3. Run:
```bash
flutter run
```

### Run in Release Mode

```bash
flutter run --release
```

## First-Time Setup

When you first launch the app:

1. **Sign Up**: Create an account using email and password
2. **Configure API Keys**:
   - Navigate to Settings
   - Enter your Gemini API key
   - Enter your TMDb API key
3. **Start Chatting**: Search for your favorite movie characters and start conversations!

## Project Structure

```
lib/
├── models/          # Data models (Character, Chat, Message)
├── screens/         # UI screens (Login, Home, Chat, Settings)
├── services/        # API and authentication services
├── blocs/           # State management (BLoC pattern)
└── main.dart        # App entry point
```

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Firebase Authentication**: Email and password authentication
- **Google Gemini AI**: AI-powered character conversations
- **TMDb API**: Movie and character data
- **BLoC Pattern**: State management
- **Shared Preferences**: Local storage for chat history

## Troubleshooting

### Build Errors

If you encounter build errors, try:
```bash
flutter clean
flutter pub get
flutter run
```

### Firebase Issues

- Make sure your Firebase configuration files are in the correct directories
- Verify that Email/Password authentication is enabled in Firebase Console
- Check that your app's bundle ID (iOS) or package name (Android) matches Firebase project settings

### API Key Issues

- Verify your API keys are valid and active
- Check that you've entered them correctly in the Settings screen

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you encounter any issues or have questions, please open an issue on GitHub.
