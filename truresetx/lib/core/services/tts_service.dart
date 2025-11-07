import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

/// Minimal TTS service shim. We intentionally avoid adding a new external
/// dependency here. If you want real device TTS, replace this implementation
/// with `flutter_tts` or your preferred audio library and update pubspec.
class TtsService {
  TtsService();

  /// Speak text using a lightweight shim. This simply prints in debug mode
  /// and waits a short time to simulate speaking. Replace with actual TTS
  /// when adding `flutter_tts`.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (kDebugMode) {
      // For now just log the text. Developer can replace this with a
      // real TTS implementation in pubspec.
      debugPrint(
          'TtsService.speak: ${text.substring(0, text.length > 200 ? 200 : text.length)}');
    }
    // Simulate a short speak duration
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> stop() async {
    // no-op for shim
  }

  Future<bool> isSpeaking() async {
    return false;
  }

  void dispose() {}
}
