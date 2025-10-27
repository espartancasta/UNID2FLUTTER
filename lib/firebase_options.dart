// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase no configurado para Linux.');
      default:
        throw UnsupportedError('Plataforma no soportada.');
    }
  }

  // 🌐 Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmBUYIJlAxLswq4IFx0M39wJTuUufq3iI',
    appId: '1:173375782011:web:c38cb553a8d4f04c18b6de',
    messagingSenderId: '173375782011',
    projectId: 'unid2flutter',
    authDomain: 'unid2flutter.firebaseapp.com',
    storageBucket: 'unid2flutter.appspot.com',
    measurementId: 'G-9ZTP8JNDGJ',
  );

  // 🤖 Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmBUYIJlAxLswq4IFx0M39wJTuUufq3iI',
    appId: '1:173375782011:android:c38cb553a8d4f04c18b6de',
    messagingSenderId: '173375782011',
    projectId: 'unid2flutter',
    storageBucket: 'unid2flutter.appspot.com',
  );

  // 🍏 iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmBUYIJlAxLswq4IFx0M39wJTuUufq3iI',
    appId: '1:173375782011:ios:c38cb553a8d4f04c18b6de',
    messagingSenderId: '173375782011',
    projectId: 'unid2flutter',
    storageBucket: 'unid2flutter.appspot.com',
    iosBundleId: 'com.example.unid2_flutter',
  );

  // 🍏 MacOS
  static const FirebaseOptions macos = ios;

  // 🪟 Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAmBUYIJlAxLswq4IFx0M39wJTuUufq3iI',
    appId: '1:173375782011:windows:c38cb553a8d4f04c18b6de',
    messagingSenderId: '173375782011',
    projectId: 'unid2flutter',
    authDomain: 'unid2flutter.firebaseapp.com',
    storageBucket: 'unid2flutter.appspot.com',
    measurementId: 'G-9ZTP8JNDGJ',
  );
}
