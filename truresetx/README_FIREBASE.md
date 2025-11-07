Firebase setup (Android & iOS)

1) Create a Firebase project in the Firebase console.

Android
-------
- Register an Android app (applicationId) matching your app's package name.
- Download `google-services.json` and place it under `android/app/`.
- In `android/build.gradle` ensure `classpath 'com.google.gms:google-services:4.3.15'` is present.
- In `android/app/build.gradle` apply plugin: `com.google.gms.google-services` and ensure `implementation platform('com.google.firebase:firebase-bom:...')` is configured if using BoM.

iOS
---
- Register an iOS app and download `GoogleService-Info.plist`.
- Add the plist to `ios/Runner` in Xcode (ensure it's in the runner target).
- Add any required capabilities (Sign In With Apple if Apple sign-in desired).

Web
---
- For web, add firebase config and call `Firebase.initializeApp(options: ...)` with your web config.

Notes
-----
- The repo includes `firebase_core` and `firebase_auth` dependencies.
- Google Sign-In flow in our adapter uses `google_sign_in` plugin; Android/iOS platform configs are required.
- After adding platform files, run `flutter clean` and `flutter pub get`, then rebuild.

Commands
--------
```powershell
cd "c:\Users\Nrb\Truresetx mob\truresetx"
flutter clean
flutter pub get
flutter run
```
