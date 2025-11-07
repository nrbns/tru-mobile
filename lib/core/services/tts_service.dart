// Polyfill kDebugMode for non-Flutter environments.
// Use the real 'flutter_tts' package if available; otherwise provide a minimal
// local stub implementation so the library can compile without the package.
///
/// If you have flutter_riverpod available in your project, prefer importing it:
//   import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// Otherwise, provide a minimal Provider fallback so this file compiles in
// non-Flutter or test environments without adding the dependency.

// Minimal fallback for Provider<T> when 'flutter_riverpod' package isn't available.
class Provider<T> {
  final T Function(dynamic) _create;
  Provider(T Function(dynamic) create) : _create = create;
  // Create an instance using an optional ref argument.
  T call([dynamic ref]) => _create(ref);
}

/// Minimal stub for FlutterTts when package:flutter_tts isn't available.
class FlutterTts {
  Future<void> setSpeechRate(double rate) async {}
  Future<void> setVolume(double volume) async {}
  Future<void> setPitch(double pitch) async {}
  Future<void> awaitSpeakCompletion(bool value) async {}
  Future<void> speak(String text) async {}
  Future<void> stop() async {}
  Future<bool?> get getIsSpeaking async => false;
}

const bool kDebugMode = !bool.fromEnvironment('dart.vm.product');

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsService() {
    // Basic defaults; callers can override per-utterance
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  /// Speak a plain text string. Returns once speaking completes (or fails).
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('TtsService.speak error: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      if (kDebugMode) print('TtsService.stop error: $e');
    }
  }

  Future<bool> isSpeaking() async {
    try {
      final res = await _tts.getIsSpeaking;
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    // FlutterTts doesn't require explicit dispose, but stop in case
    stop();
  }
}
