# Task Manager (MVVM Architecture)

Smart Task Manager is a Flutter application designed to help users manage their tasks efficiently with a modern UI and robust features.


## Project Details

- **Flutter Version**: 3.x.x (Ensure you have the latest stable version)
- **Dart SDK**: `>=2.16.1 <3.0.0`
- **State Management**: BLoC
- **Backend**: Firebase
- **Database**: Drift (SQLite)

## Features

- Task management with categories
- Offline support using Drift (SQLite)
- Firebase Authentication (Google Sign-In, Email/Password, etc.)
- Push notifications with Firebase Messaging and Awesome Notifications
- Animated lists, charts, and modern UI components
- Secure storage using `flutter_secure_storage`
- Network connectivity detection

## Installation & Setup

### Prerequisites
Ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK
- Android Studio or Visual Studio Code (recommended IDEs)
- Firebase account (for authentication and notifications)

### Steps to Run

1. **Clone the Repository**
   ```sh
   git clone https://github.com/Asrat001/smartTask.git
   cd smartTask
   ```

2. **Install Dependencies**
   ```sh
   flutter pub get
   ```

3. **Setup Firebase**
    - Create a Firebase project
    - Add an Android and iOS app to Firebase
    - Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS)
    - Place them in the respective `android/app/` and `ios/Runner/` directories
    - Enable Firestore, Firebase Authentication, and Firebase Messaging

4. **Generate Necessary Files**
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the App**
   ```sh
   flutter run
   ```

## Folder Structure

```plaintext
task_manager-main/
│── .dart_tool/
│── .github/
│── .idea/
│── .vscode/
│── android/
│── assets/
│── build/
│── ios/
│── lib/
│   ├── blocs/
│   ├── bottom_sheets/
│   ├── components/
│   ├── cubits/
│   ├── helpers/
│   ├── l10n/
│   ├── messaging/
│   ├── models/
│   ├── repositories/
│   ├── router/
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── validators/
│   ├── app.dart
│   ├── constants.dart
│   ├── firebase_options.dart
│   ├── generated_plugin_registrant.dart
│   ├── main.dart
│── analysis_options.yaml

```

## Dependencies

Key dependencies used in the project:
- **State Management**: BLoC (`flutter_bloc`, `bloc_concurrency`)
- **Database**: Drift (SQLite)
- **Authentication**: Firebase Auth, Google Sign-In
- **UI Components**: Cached Network Image, Fl Chart, Animated Lists
- **Notifications**: Firebase Messaging, Awesome Notifications

## Additional Commands

- **Generate JSON Serialization Code**
  ```sh
  flutter pub run build_runner build
  ```

- **Run Tests**
  ```sh
  Due to a tight deadline, I am unable to write tests for the app properly
  ```






## Contribution Guidelines

- Fork the repository
- Create a new feature branch
- Commit changes with descriptive messages
- Push to the branch and create a pull request

## License

This project is licensed under the MIT License.



