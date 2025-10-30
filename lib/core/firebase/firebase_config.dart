import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

/// Firebase initialization and configuration
class FirebaseConfig {
  static Future<void> initialize() async {
    // Initialize Firebase with platform-specific options
    // On web this project hasn't been configured via FlutterFire CLI,
    // so skip initialization to allow running the app locally.
    // Initialize Firebase for all platforms where options are available.
    // The generated `DefaultFirebaseOptions` contains web options. For
    // native platforms it will throw if not configured; that's expected
    // during local development when native apps aren't registered.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // If initialization fails on native platforms because options aren't
      // configured, log and continue — but on web we expect initialization
      // to succeed because generated web options are present.
      if (kDebugMode) {
        // ignore: avoid_print
        print('Firebase initialization warning: $e');
      }
    }

    // Configure Crashlytics and messaging only on non-web platforms
    if (!kIsWeb) {
      // Configure Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Request notification permissions
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final token = await messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  }
}

// Background message handler for notifications
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Handle background message
  print('Background message: ${message.messageId}');
}
