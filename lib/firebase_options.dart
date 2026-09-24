// ============================================================================
//  FIREBASE KEYS GO HERE
// ============================================================================
//  Option A (recommended): run `flutterfire configure` in the project root.
//  It overwrites this file with your real values automatically.
//
//  Option B (manual): Firebase Console -> Project settings -> Your apps.
//  Register an Android app and/or an iOS app and copy the values below.
//    Android: values are in google-services.json
//      apiKey            -> client[0].api_key[0].current_key
//      appId             -> client[0].client_info.mobilesdk_app_id
//      messagingSenderId -> project_info.project_number
//      projectId         -> project_info.project_id
//      storageBucket     -> project_info.storage_bucket
//    iOS: values are in GoogleService-Info.plist
//      apiKey -> API_KEY, appId -> GOOGLE_APP_ID, messagingSenderId -> GCM_SENDER_ID,
//      projectId -> PROJECT_ID, storageBucket -> STORAGE_BUCKET, iosBundleId -> BUNDLE_ID
// ============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('This app is configured for Android and iOS only.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUAegMdL9SBlhM0I-d2PcEHnU9tdPzwO8',
    appId: '1:995688352939:android:8385ddcae631743aebbbee',
    messagingSenderId: '995688352939',
    projectId: 'shopease-f142c',
    storageBucket: 'shopease-f142c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.shopease.shopEase',
  );
}
