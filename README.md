# Sansaar - Real-time Chat App

A beautiful, modern chat application built with Flutter and Firebase, featuring real-time messaging, user authentication, and a clean Material Design interface.

## Features

- 🔐 **User Authentication** - Sign up and sign in with email/password
- 💬 **Real-time Messaging** - Instant messaging powered by Firebase Firestore
- 🔍 **User Search** - Find and connect with other users by username or name
- 📱 **Modern UI** - Clean, consistent design with rounded navigation bar
- 🎨 **Consistent Theme** - Purple color scheme throughout the app
- 👥 **Stories Section** - User stories display (placeholder for future implementation)
- 📊 **Online Status** - See when users are online/offline
- ✅ **Message Status** - Read receipts and delivery confirmation

## Firebase Configuration

This app uses Firebase for authentication and real-time database. You'll need to set up Firebase with the following configuration:

### Firebase Project Settings
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyBRovunZCM1rnDumj22Drmisp0A4mHXst0",
  authDomain: "sansaar-fbe65.firebaseapp.com",
  projectId: "sansaar-fbe65",
  storageBucket: "sansaar-fbe65.firebasestorage.app",
  messagingSenderId: "624097627628",
  appId: "1:624097627628:web:9005ce70a35349c2b3c4c9"
};
```

### Required Firebase Services
1. **Authentication** - Email/Password provider enabled
2. **Firestore Database** - Real-time database for messages and user data
3. **Storage** (optional) - For future file/image uploads

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Allow reading other users for search
    }
    
    // Chat documents
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Messages within chats
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
    }
  }
}
```

## Dependencies (pubspec.yaml)

Add these dependencies to your `pubspec.yaml` file:

```yaml
name: sansaar
description: A real-time chat application
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # UI & Fonts
  google_fonts: ^6.1.0
  
  # Utilities
  timeago: ^3.6.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

## Android Manifest Configuration

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet permission for Firebase -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        android:label="Sansaar"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd sansaar
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Email/Password provider
   - Create a Firestore database
   - Add your Android/iOS apps to the Firebase project
   - Download and add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)

4. **Configure Firebase**
   - Update the Firebase configuration in `lib/utils/firebase_options.dart` with your project details
   - The current configuration is set up for the Sansaar project

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── models/
│   ├── user_model.dart        # User data model
│   └── message_model.dart     # Message data model
├── screens/
│   ├── auth_screen.dart       # Sign up/Sign in
│   ├── home_screen.dart       # Main app with navigation
│   ├── search_screen.dart     # User search
│   └── chat_detail_screen.dart # Chat conversation
├── widgets/
│   ├── story_widgets.dart     # Stories section
│   └── chat_widgets.dart      # Chat UI components
└── utils/
    ├── theme.dart             # App theme configuration
    └── firebase_options.dart  # Firebase configuration
```

## Key Features Implemented

### Authentication
- Email/password registration and login
- Unique username validation
- User profile creation with auto-generated avatars
- Session management with automatic redirect

### Real-time Chat
- Instant messaging using Firestore streams
- Message delivery and read status
- Online/offline user status
- Unread message counting
- Chat list with last message preview

### User Interface
- Consistent purple theme throughout the app
- Rounded iOS-style bottom navigation
- Smaller "Sansaar" logo using Pacifico font
- Modern Material Design 3 components
- Responsive chat bubbles with proper alignment

### Search Functionality
- Search users by name or username
- Real-time search results
- Easy chat initiation from search results

## Known Limitations

- Stories functionality is placeholder (displays users but no story creation/viewing)
- Voice messages are placeholder UI only
- No file/image sharing yet
- No push notifications
- No group chats

## Future Enhancements

- [ ] Story creation and viewing
- [ ] Voice message recording and playback
- [ ] Image and file sharing
- [ ] Push notifications
- [ ] Group chat functionality
- [ ] Message editing and deletion
- [ ] User profiles and settings
- [ ] Dark mode support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.