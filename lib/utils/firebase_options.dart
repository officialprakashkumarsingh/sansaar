import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBRovunZCM1rnDumj22Drmisp0A4mHXst0',
    appId: '1:624097627628:web:9005ce70a35349c2b3c4c9',
    messagingSenderId: '624097627628',
    projectId: 'sansaar-fbe65',
    authDomain: 'sansaar-fbe65.firebaseapp.com',
    storageBucket: 'sansaar-fbe65.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRovunZCM1rnDumj22Drmisp0A4mHXst0',
    appId: '1:624097627628:android:9005ce70a35349c2b3c4c9',
    messagingSenderId: '624097627628',
    projectId: 'sansaar-fbe65',
    authDomain: 'sansaar-fbe65.firebaseapp.com',
    storageBucket: 'sansaar-fbe65.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRovunZCM1rnDumj22Drmisp0A4mHXst0',
    appId: '1:624097627628:ios:9005ce70a35349c2b3c4c9',
    messagingSenderId: '624097627628',
    projectId: 'sansaar-fbe65',
    authDomain: 'sansaar-fbe65.firebaseapp.com',
    storageBucket: 'sansaar-fbe65.firebasestorage.app',
    iosBundleId: 'com.example.sansaar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBRovunZCM1rnDumj22Drmisp0A4mHXst0',
    appId: '1:624097627628:macos:9005ce70a35349c2b3c4c9',
    messagingSenderId: '624097627628',
    projectId: 'sansaar-fbe65',
    authDomain: 'sansaar-fbe65.firebaseapp.com',
    storageBucket: 'sansaar-fbe65.firebasestorage.app',
    iosBundleId: 'com.example.sansaar',
  );
}