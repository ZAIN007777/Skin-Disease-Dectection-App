// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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
    apiKey: 'AIzaSyC0PiONajzsJJIlGSrErGnG5TqZ216_cl0',
    appId: '1:146550818049:web:f77d8ce355f89a22378700',
    messagingSenderId: '146550818049',
    projectId: 'skin-guardian-6ca3a',
    authDomain: 'skin-guardian-6ca3a.firebaseapp.com',
    storageBucket: 'skin-guardian-6ca3a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtEXXTnc0xCEbDOiQVGgqnyfSIHgf1zNE',
    appId: '1:146550818049:android:5485c48b17368d37378700',
    messagingSenderId: '146550818049',
    projectId: 'skin-guardian-6ca3a',
    storageBucket: 'skin-guardian-6ca3a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChcF8iwsOb2AeHh0E1PRzfEAI5VtgzKtA',
    appId: '1:146550818049:ios:bdb539a71cfc08df378700',
    messagingSenderId: '146550818049',
    projectId: 'skin-guardian-6ca3a',
    storageBucket: 'skin-guardian-6ca3a.firebasestorage.app',
    iosBundleId: 'com.example.skinGuardian',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChcF8iwsOb2AeHh0E1PRzfEAI5VtgzKtA',
    appId: '1:146550818049:ios:bdb539a71cfc08df378700',
    messagingSenderId: '146550818049',
    projectId: 'skin-guardian-6ca3a',
    storageBucket: 'skin-guardian-6ca3a.firebasestorage.app',
    iosBundleId: 'com.example.skinGuardian',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC0PiONajzsJJIlGSrErGnG5TqZ216_cl0',
    appId: '1:146550818049:web:3feffe57231006b0378700',
    messagingSenderId: '146550818049',
    projectId: 'skin-guardian-6ca3a',
    authDomain: 'skin-guardian-6ca3a.firebaseapp.com',
    storageBucket: 'skin-guardian-6ca3a.firebasestorage.app',
  );
}
