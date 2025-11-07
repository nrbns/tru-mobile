import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/telemetry_channel.dart';

/// Mind Engine: Emotional understanding, mood prediction, voice tone analysis
class AgenticMindEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final TelemetryChannel _telemetry;

  AgenticMindEngine(this._db, this._auth) : _telemetry = TelemetryChannel();

  String? get _uid => _auth.currentUser?.uid;

  /// Analyze emotional state from multiple inputs
  Future<EmotionalState> analyzeEmotionalState({
    String? voiceTranscript,
    Map<String, dynamic>? facialEmotion,
    String? textInput,
    double? heartRate,
    double? hrv,
  }) async {
    // Combine inputs for holistic emotional analysis
    double stressScore = 0.0;
    double energyLevel = 0.5;
    String dominantEmotion = 'neutral';
    List<String> emotionTags = [];

    // Voice tone analysis (sentiment from transcript)
    if (voiceTranscript != null) {
      final voiceAnalysis = await _analyzeVoiceSentiment(voiceTranscript);
      stressScore = (stressScore + voiceAnalysis['stress']) / 2;
      dominantEmotion = voiceAnalysis['emotion'] ?? dominantEmotion;
      emotionTags.addAll(voiceAnalysis['tags'] as List<String>? ?? []);
    }

    // Facial emotion detection
    if (facialEmotion != null) {
      final faceScore = facialEmotion['happiness'] as double? ?? 0.0;
      final faceStress = facialEmotion['stress'] as double? ?? 0.0;
      stressScore = (stressScore + (1 - faceScore) + faceStress) / 2;
      if (facialEmotion['emotion'] != null) {
        emotionTags.add(facialEmotion['emotion'] as String);
      }
    }

    // Text sentiment
    if (textInput != null) {
      final textAnalysis = await _analyzeTextSentiment(textInput);
      stressScore = (stressScore + textAnalysis['stress']) / 2;
      emotionTags.addAll(textAnalysis['tags'] as List<String>? ?? []);
    }

    // Physiological signals
    if (heartRate != null && hrv != null) {
      // High HR + Low HRV = Stress
      final physiologicalStress = _calculatePhysiologicalStress(heartRate, hrv);
      stressScore = (stressScore + physiologicalStress) / 2;
      energyLevel = _calculateEnergyLevel(heartRate);
    }

    // Determine overall emotional state
    final overallEmotion = _determineDominantEmotion(emotionTags, stressScore);

    return EmotionalState(
      stressLevel: stressScore.clamp(0.0, 1.0),
      energyLevel: energyLevel.clamp(0.0, 1.0),
      dominantEmotion: overallEmotion,
      emotionTags: emotionTags.toSet().toList(),
      timestamp: DateTime.now(),
    );
  }

  /// Predict mood based on patterns
  Future<String> predictMood() async {
    if (_uid == null) return 'neutral';

    // Analyze last 7 days of mood logs
    final recentMoods = await _db
        .collection('users')
        .doc(_uid)
        .collection('mood_logs')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .get();

    if (recentMoods.docs.isEmpty) return 'neutral';

    final moods = recentMoods.docs
        .map((doc) => doc.data()['mood'] as String? ?? 'neutral')
        .toList();

    // Simple pattern: if last 3 are similar, predict continuation
    if (moods.length >= 3) {
      final recent = moods.take(3).toList();
      if (recent.every((m) => m == recent.first)) {
        return recent.first;
      }
    }

    // Default: predict based on time of day patterns
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) return 'motivated';
    if (hour >= 18 && hour < 22) return 'relaxed';
    return 'neutral';
  }

  /// Empathic response generation
  Future<String> generateEmpathicResponse(
    String userInput,
    EmotionalState currentState,
  ) async {
    final tone = _selectEmpathicTone(currentState);

    // TODO: Call LLM with empathic context
    // For now, return contextual response
    if (currentState.stressLevel > 0.7) {
      return "$tone I see you're experiencing stress. Would you like to vent, reflect, or try a grounding exercise?";
    }

    if (currentState.energyLevel < 0.3) {
      return "$tone You seem low on energy today. How about a gentle movement or breathing exercise instead of a heavy workout?";
    }

    return "$tone I'm here to support you. What would help you feel better right now?";
  }

  String _selectEmpathicTone(EmotionalState state) {
    if (state.stressLevel > 0.7) return 'I understand this is tough.';
    if (state.energyLevel < 0.3) return 'It\'s okay to rest when you need to.';
    return 'I\'m listening.';
  }

  Future<Map<String, dynamic>> _analyzeVoiceSentiment(String transcript) async {
    // TODO: Integrate with speech-to-text + sentiment analysis API
    // Mock analysis for now
    final lower = transcript.toLowerCase();
    if (lower.contains('stressed') || lower.contains('worried')) {
      return {'stress': 0.8, 'emotion': 'anxious', 'tags': ['stress', 'worry']};
    }
    if (lower.contains('happy') || lower.contains('great')) {
      return {'stress': 0.2, 'emotion': 'happy', 'tags': ['joy', 'positive']};
    }
    return {'stress': 0.5, 'emotion': 'neutral', 'tags': []};
  }

  Future<Map<String, dynamic>> _analyzeTextSentiment(String text) async {
    // TODO: NLP sentiment analysis
    return _analyzeVoiceSentiment(text); // Reuse for now
  }

  double _calculatePhysiologicalStress(double hr, double hrv) {
    // Simplified: HRV decreases with stress
    // Normal HRV ~50-100ms, stressed <30ms
    final normalizedHRV = (hrv / 100).clamp(0.0, 1.0);
    return 1.0 - normalizedHRV;
  }

  double _calculateEnergyLevel(double heartRate) {
    // Resting HR ~60-100, active >100
    // Normalize to energy (simplified)
    if (heartRate < 60) return 0.3;
    if (heartRate < 100) return 0.6;
    return 0.9;
  }

  String _determineDominantEmotion(List<String> tags, double stress) {
    if (tags.isEmpty) return stress > 0.7 ? 'stressed' : 'neutral';
    
    // Count occurrences
    final counts = <String, int>{};
    for (final tag in tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
    
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.isNotEmpty ? sorted.first.key : 'neutral';
  }
}

/// Emotional state snapshot
class EmotionalState {
  final double stressLevel; // 0.0 to 1.0
  final double energyLevel; // 0.0 to 1.0
  final String dominantEmotion;
  final List<String> emotionTags;
  final DateTime timestamp;

  EmotionalState({
    required this.stressLevel,
    required this.energyLevel,
    required this.dominantEmotion,
    required this.emotionTags,
    required this.timestamp,
  });
}

