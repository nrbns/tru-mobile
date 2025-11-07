import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime environment loader used in development to load a local `.env` file.
///
/// Production and CI should still pass values with `--dart-define` so that
/// values are embedded at compile time and secrets are handled by the CI.
class EnvRuntime {
  static bool _initialized = false;

  /// Load the given `.env` file (defaults to `.env` in the project root).
  /// Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> init([String fileName = '.env']) async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: fileName);
      _initialized = true;
    } catch (_) {
      // If no .env exists or load fails, keep going — values may be provided
      // via --dart-define in CI or developer machines.
    }
  }

  /// Get a runtime env value loaded from `.env` or null if not present.
  static String? get(String key) {
    if (!_initialized) return null;
    return dotenv.env[key];
  }
}
