import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/mood_log_model.dart';

/// Mind Engine - Emotional understanding and mood prediction
class MindEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final String? _uid;

  MindEngine(this._db, this._auth) : _uid = _auth.currentUser?.uid;

  /// Analyze emotional state from multiple sources
  Future<EmotionalState> analyzeEmotionalState({
    String? voiceTranscript,
    String? textInput,
    double? facialEmotionScore,
    Map<String, dynamic>? recentActivity,
  }) async {
    double stressLevel = 0.5;
    String dominantEmotion = 'neutral';
    double energyLevel = 0.5;

    // Analyze voice tone (placeholder - would use sentiment analysis)
    if (voiceTranscript != null) {
      final voiceStress = _analyzeVoiceStress(voiceTranscript);
      stressLevel = (stressLevel + voiceStress) / 2;
    }

    // Analyze text sentiment
    if (textInput != null) {
      final textSentiment = _analyzeTextSentiment(textInput);
      dominantEmotion = textSentiment['emotion'] as String;
      stressLevel = (stressLevel + (textSentiment['stress'] as double)) / 2;
    }

    // Incorporate facial emotion if available
    if (facialEmotionScore != null) {
      energyLevel = facialEmotionScore;
    }

    // Get recent mood logs for context
    final recentMoods = await _getRecentMoods();
    if (recentMoods.isNotEmpty) {
      final avgMood = recentMoods.map((m) => m.score.toDouble()).reduce((a, b) => a + b) / recentMoods.length;
      energyLevel = (energyLevel + (avgMood / 10)) / 2;
    }

    return EmotionalState(
      stressLevel: stressLevel,
      dominantEmotion: dominantEmotion,
      energyLevel: energyLevel,
      timestamp: DateTime.now(),
    );
  }

  /// Predict mood and energy for the day
  Future<MoodPrediction> predictDailyMood() async {
    if (_uid == null) {
      return MoodPrediction(
        predictedEnergy: 0.5,
        predictedMood: 7.0,
        confidence: 0.0,
      );
    }

    // Get last 7 days of mood data
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('mood_logs')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
        .orderBy('timestamp', descending: true)
        .limit(21)
        .get();

    final moods = snapshot.docs
        .map((doc) => MoodLogModel.fromFirestore(doc))
        .toList();

    if (moods.isEmpty) {
      return MoodPrediction(
        predictedEnergy: 0.5,
        predictedMood: 7.0,
        confidence: 0.3,
      );
    }

    // Calculate trends
    final avgMood = moods.map((m) => m.score.toDouble()).reduce((a, b) => a + b) / moods.length;
    final avgEnergy = avgMood / 10; // Normalize to 0-1

    // Time-based patterns (morning vs evening mood)
    final hour = DateTime.now().hour;
    final morningMoods = moods.where((m) {
      final h = m.at.hour;
      return h >= 6 && h < 12;
    }).map((m) => m.score.toDouble()).toList();

    final morningAvg = morningMoods.isEmpty
        ? avgMood
        : morningMoods.reduce((a, b) => a + b) / morningMoods.length;

    return MoodPrediction(
      predictedEnergy: (avgEnergy * 0.7 + (hour < 12 ? morningAvg / 10 : avgEnergy) * 0.3),
      predictedMood: avgMood,
      confidence: moods.length > 10 ? 0.8 : 0.5,
    );
  }

  double _analyzeVoiceStress(String transcript) {
    // Placeholder - would use NLP/sentiment analysis
    final stressKeywords = ['tired', 'exhausted', 'stressed', 'anxious', 'overwhelmed'];
    final calmKeywords = ['relaxed', 'calm', 'peaceful', 'good', 'happy'];
    
    final lower = transcript.toLowerCase();
    int stressCount = stressKeywords.where((k) => lower.contains(k)).length;
    int calmCount = calmKeywords.where((k) => lower.contains(k)).length;
    
    if (stressCount + calmCount == 0) return 0.5;
    return (stressCount / (stressCount + calmCount)).clamp(0.0, 1.0);
  }

  Map<String, dynamic> _analyzeTextSentiment(String text) {
    // Placeholder - would use sentiment analysis API
    final lower = text.toLowerCase();
    final emotions = {
      'happy': ['happy', 'joy', 'great', 'amazing', 'wonderful'],
      'sad': ['sad', 'depressed', 'down', 'melancholy'],
      'angry': ['angry', 'frustrated', 'mad', 'irritated'],
      'anxious': ['anxious', 'worried', 'nervous', 'stressed'],
      'neutral': ['ok', 'fine', 'alright'],
    };

    for (final entry in emotions.entries) {
      if (entry.value.any((word) => lower.contains(word))) {
        return {
          'emotion': entry.key,
          'stress': entry.key == 'anxious' || entry.key == 'angry' ? 0.8 : 0.3,
        };
      }
    }

    return {'emotion': 'neutral', 'stress': 0.5};
  }

  Future<List<MoodLogModel>> _getRecentMoods({int days = 3}) async {
    if (_uid == null) return [];
    final since = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('mood_logs')
        .where('at', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('at', descending: true)
        .get();

    return snapshot.docs.map((doc) => MoodLogModel.fromFirestore(doc)).toList();
  }
}

class EmotionalState {
  final double stressLevel;
  final String dominantEmotion;
  final double energyLevel;
  final DateTime timestamp;

  EmotionalState({
    required this.stressLevel,
    required this.dominantEmotion,
    required this.energyLevel,
    required this.timestamp,
  });
}

class MoodPrediction {
  final double predictedEnergy;
  final double predictedMood;
  final double confidence;

  MoodPrediction({
    required this.predictedEnergy,
    required this.predictedMood,
    required this.confidence,
  });
}

