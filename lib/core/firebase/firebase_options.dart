// Wrapper: delegate to generated lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:truresetx/firebase_options.dart' as gen;

/// Delegates the `DefaultFirebaseOptions.currentPlatform` lookup to the
/// generated `lib/firebase_options.dart` created by the FlutterFire CLI.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      gen.DefaultFirebaseOptions.currentPlatform;
}
