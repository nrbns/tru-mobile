import 'package:flutter_tts/flutter_tts.dart';
import 'agent_engines/spirit_engine.dart';
import '../models/agent_persona.dart';

/// Inner Voice Coach - Whispers affirmations through earbuds in real-time
class InnerVoiceService {
  final FlutterTts _tts;
  final SpiritEngine _spiritEngine;
  bool _isEnabled = false;
  AgentPersona _currentPersona = AgentPersona.coach;

  InnerVoiceService(this._spiritEngine) : _tts = FlutterTts() {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5); // Slower, calmer
    await _tts.setVolume(0.3); // Whisper-like volume
    await _tts.setPitch(1.0);
  }

  /// Enable inner voice coaching
  Future<void> enable({AgentPersona? persona}) async {
    _isEnabled = true;
    if (persona != null) _currentPersona = persona;
  }

  /// Disable inner voice
  Future<void> disable() async {
    _isEnabled = false;
    await _tts.stop();
  }

  /// Speak affirmation during workout/meditation
  Future<void> speakAffirmation({
    required String context, // 'workout', 'meditation', 'recovery'
    double? progress, // 0.0 to 1.0
  }) async {
    if (!_isEnabled) return;

    final affirmation = _generateAffirmation(context, progress);
    await _tts.speak(affirmation);
  }

  String _generateAffirmation(String context, double? progress) {
    switch (_currentPersona) {
      case AgentPersona.trainer:
        if (context == 'workout') {
          if (progress != null && progress > 0.8) {
            return 'Almost there. Push through the final stretch.';
          } else if (progress != null && progress > 0.5) {
            return 'You\'re doing great. Keep the momentum.';
          } else {
            return 'Let\'s begin. Focus on form and breathe.';
          }
        }
        return 'You\'ve got this. Stay strong.';

      case AgentPersona.sage:
        if (context == 'meditation') {
          return 'In this moment, you are present. Nothing else exists.';
        }
        return 'Every breath is a new beginning.';

      case AgentPersona.friend:
        if (progress != null && progress > 0.7) {
          return 'Hey, you\'re doing amazing. Almost done.';
        }
        return 'You\'re here, and that\'s what matters.';

      case AgentPersona.coach:
        if (context == 'recovery') {
          return 'Rest is as important as effort. Honor your body.';
        }
        return 'Focus on the process, not the outcome.';
    }
  }

  /// Speak countdown during workout intervals
  Future<void> speakCountdown(int seconds) async {
    if (!_isEnabled) return;
    
    if (seconds <= 5 && seconds > 0) {
      await _tts.speak(seconds == 1 ? 'One' : '$seconds');
    }
  }
}

