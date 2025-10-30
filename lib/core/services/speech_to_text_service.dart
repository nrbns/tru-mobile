import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize speech-to-text
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    // On web the permission_handler does not support `Permission.speech`.
    // Avoid requesting it and fail initialization gracefully.
    if (kIsWeb) {
      return false;
    }

    final status = await Permission.speech.request();
    if (!status.isGranted) {
      return false;
    }

    _isInitialized = await _speech.initialize(
      onError: (error) {
        // ignore: avoid_print
        print('Speech recognition error: $error');
      },
      onStatus: (status) {
        // ignore: avoid_print
        print('Speech recognition status: $status');
      },
    );

    return _isInitialized;
  }

  /// Start listening for speech
  Future<bool> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResults,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return false;
      }
    }

    if (_isListening) {
      return false;
    }

    _isListening = true;

    _isListening = true;

    // Prefer the new SpeechListenOptions but still pass listenFor/pauseFor/localeId
    final listenOptions = stt.SpeechListenOptions(
      cancelOnError: true,
      partialResults: true,
      onDevice: false,
      listenMode: stt.ListenMode.confirmation,
      sampleRate: 0,
    );

    return await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
        } else if (onPartialResults != null) {
          onPartialResults(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      listenOptions: listenOptions,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if service is available
  bool get isAvailable => _speech.isAvailable;

  /// Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    return await _speech.locales();
  }
}
