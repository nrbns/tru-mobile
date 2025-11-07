import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Inner Voice Coach: Real-time affirmations and guidance through earbuds
class InnerVoiceCoach {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FlutterTts _tts = FlutterTts();

  InnerVoiceCoach(this._db, this._auth) {
    _initializeTTS();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> _initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5); // Slower, calmer pace
    await _tts.setVolume(0.7);
    await _tts.setPitch(1.0);
  }

  /// Speak affirmation based on context
  Future<void> speakAffirmation({
    required String context, // 'workout', 'meditation', 'stress', 'motivation'
    String? persona, // 'trainer', 'sage', 'friend'
  }) async {
    final affirmation = await _generateAffirmation(context, persona);
    await _tts.speak(affirmation);
  }

  /// Real-time workout guidance
  Future<void> provideWorkoutGuidance({
    required String exerciseName,
    required int currentRep,
    required int totalReps,
    String? formFeedback,
  }) async {
    String guidance = '';

    // Countdown for last reps
    if (currentRep >= totalReps - 2) {
      guidance = 'Almost there. $currentRep of $totalReps. Push through!';
    } else if (currentRep == totalReps) {
      guidance = 'Excellent! Take a deep breath and rest.';
    } else {
      guidance = '$currentRep of $totalReps. Keep your form strong.';
    }

    if (formFeedback != null) {
      guidance += ' $formFeedback';
    }

    await _tts.speak(guidance);
  }

  /// Meditation guidance
  Future<void> guideMeditation({
    required Duration elapsed,
    required Duration total,
    String? instruction,
  }) async {
    final remaining = total - elapsed;
    
    if (instruction != null) {
      await _tts.speak(instruction);
      return;
    }

    // Auto-guidance based on phase
    if (elapsed.inSeconds < 60) {
      await _tts.speak('Find a comfortable position. Close your eyes. Begin to breathe naturally.');
    } else if (elapsed.inSeconds < 180) {
      await _tts.speak('Notice your breath. Inhale slowly... exhale gently.');
    } else if (remaining.inSeconds < 60) {
      await _tts.speak('Slowly bring your awareness back. Wiggle your fingers and toes.');
    }
  }

  /// Stress relief whisper
  Future<void> whisperCalm({
    required double stressLevel,
  }) async {
    await _tts.setVolume(0.5); // Quieter for whispers
    await _tts.setSpeechRate(0.4); // Slower

    String message = '';
    if (stressLevel > 0.8) {
      message = 'You\'re safe. This moment will pass. Breathe with me.';
    } else if (stressLevel > 0.5) {
      message = 'Take a moment. You have everything you need within you.';
    } else {
      message = 'You\'re doing well. Keep this calm energy.';
    }

    await _tts.speak(message);
    await _tts.setVolume(0.7); // Reset volume
    await _tts.setSpeechRate(0.5);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _tts.stop();
  }

  Future<String> _generateAffirmation(String context, String? persona) async {
    final affirmations = {
      'workout': {
        'trainer': [
          'You\'re stronger than you think. Keep pushing!',
          'Your body is capable of amazing things. Let\'s do this!',
          'One more rep. You\'ve got this!',
        ],
        'friend': [
          'You\'re doing great! Remember why you started.',
          'I\'m proud of you for showing up today.',
        ],
      },
      'meditation': {
        'sage': [
          'Peace is already within you. Just breathe.',
          'In this moment, you are exactly where you need to be.',
          'Let go of thoughts. Return to the breath.',
        ],
      },
      'stress': {
        'sage': [
          'This feeling will pass. You are not your stress.',
          'You have survived all your hardest days. This is no different.',
        ],
        'friend': [
          'It\'s okay to feel this way. You\'re not alone.',
        ],
      },
      'motivation': {
        'trainer': [
          'Every champion was once a beginner. Keep going!',
          'Your future self will thank you for this effort.',
        ],
      },
    };

    final contextAffirmations = affirmations[context];
    if (contextAffirmations == null) {
      return 'You\'re doing great. Keep going!';
    }

    final personaAffirmations = contextAffirmations[persona ?? 'friend'];
    if (personaAffirmations == null || personaAffirmations.isEmpty) {
      return 'You\'re doing great. Keep going!';
    }

    // Return random affirmation
    final random = DateTime.now().millisecond % personaAffirmations.length;
    return personaAffirmations[random];
  }
}

