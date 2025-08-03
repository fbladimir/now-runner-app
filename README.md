# NowRunner

A modern Flutter mobile app that connects service requesters with runners for various tasks and errands.

## Features

- **User Authentication**: Secure login and signup with Firebase Auth
- **Service Requests**: Users can request various services (grocery pickup, delivery, errands, etc.)
- **Runner System**: Users can become runners and accept available jobs
- **Real-time Updates**: Live job updates and notifications
- **Modern UI**: Clean, intuitive interface with Material Design 3
- **Firebase Integration**: Complete backend with Firestore and Storage

## Project Structure

```
lib/
├── controllers/          # Business logic controllers
├── models/              # Data models
│   ├── user_model.dart
│   └── job_model.dart
├── services/            # Firebase and external services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── views/               # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── requester/
│   │   └── requester_screen.dart
│   └── runner/
│       └── runner_screen.dart
├── widgets/             # Reusable UI components
└── main.dart           # App entry point

assets/
├── images/             # App images
├── icons/              # App icons
└── fonts/              # Custom fonts
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd now_runner
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

4. Run the app:
```bash
flutter run
```

## Firebase Setup

### Authentication
- Enable Email/Password authentication
- Configure sign-in methods as needed

### Firestore Database
Create the following collections:
- `users`: User profiles and preferences
- `jobs`: Service requests and job details

### Storage
Set up Firebase Storage for:
- Profile images
- Job-related images
- Documents

## Dependencies

- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: Database operations
- **firebase_storage**: File storage
- **provider**: State management
- **google_fonts**: Typography
- **flutter_svg**: SVG support
- **image_picker**: Image selection

## Features in Detail

### Authentication
- Email/password signup and login
- Password reset functionality
- User profile management

### Service Requests
- Create detailed service requests
- Set budget and location
- Choose service categories
- Upload images and documents

### Runner System
- Browse available jobs
- Filter by category, budget, and urgency
- Accept and complete jobs
- Track earnings and ratings

### Real-time Features
- Live job updates
- Push notifications
- Real-time chat (planned)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.
