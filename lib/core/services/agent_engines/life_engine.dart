import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Life Engine - Long-term personal growth mentor
class LifeEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final String? _uid;

  LifeEngine(this._db, this._auth) : _uid = _auth.currentUser?.uid;

  /// Analyze life patterns and suggest improvements
  Future<LifeInsight> analyzeLifePatterns() async {
    if (_uid == null) {
      return LifeInsight.empty();
    }

    // Analyze multiple dimensions
    final fitnessTrend = await _analyzeFitnessTrend();
    final moodTrend = await _analyzeMoodTrend();
    final spiritualTrend = await _analyzeSpiritualTrend();
    final nutritionTrend = await _analyzeNutritionTrend();

    // Identify areas needing attention
    final weakAreas = <String>[];
    if (fitnessTrend.score < 0.6) weakAreas.add('fitness');
    if (moodTrend.score < 0.6) weakAreas.add('emotional_wellbeing');
    if (spiritualTrend.score < 0.5) weakAreas.add('spiritual_practice');
    if (nutritionTrend.score < 0.7) weakAreas.add('nutrition');

    // Generate personalized advice
    final advice = _generateLifeAdvice(weakAreas, fitnessTrend, moodTrend);

    return LifeInsight(
      weakAreas: weakAreas,
      strongAreas: _getStrongAreas(weakAreas),
      overallScore: (fitnessTrend.score + moodTrend.score + spiritualTrend.score + nutritionTrend.score) / 4,
      personalizedAdvice: advice,
      longTermGoals: await _getLongTermGoals(),
    );
  }

  /// Set micro-goals for the day based on patterns
  Future<List<MicroGoal>> generateDailyMicroGoals() async {
    final insight = await analyzeLifePatterns();
    final goals = <MicroGoal>[];

    if (insight.weakAreas.contains('fitness')) {
      goals.add(MicroGoal(
        category: 'fitness',
        description: 'Complete a 20-minute movement session',
        priority: 'high',
        karmaReward: 10,
      ));
    }

    if (insight.weakAreas.contains('mood')) {
      goals.add(MicroGoal(
        category: 'mind',
        description: 'Log your mood and reflect for 5 minutes',
        priority: 'medium',
        karmaReward: 5,
      ));
    }

    if (insight.weakAreas.contains('spiritual_practice')) {
      goals.add(MicroGoal(
        category: 'spirit',
        description: '5-minute meditation or mantra practice',
        priority: 'medium',
        karmaReward: 8,
      ));
    }

    if (insight.weakAreas.contains('nutrition')) {
      goals.add(MicroGoal(
        category: 'nutrition',
        description: 'Log one healthy meal',
        priority: 'high',
        karmaReward: 7,
      ));
    }

    // Always add at least one goal
    if (goals.isEmpty) {
      goals.add(MicroGoal(
        category: 'general',
        description: 'Complete your daily practice',
        priority: 'low',
        karmaReward: 5,
      ));
    }

    return goals;
  }

  Future<TrendAnalysis> _analyzeFitnessTrend() async {
    // Analyze last 30 days of workouts
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('workout_sessions')
        .where('completedAt', isGreaterThan: Timestamp.fromDate(monthAgo))
        .get();

    final count = snapshot.docs.length;
    final target = 15; // ~3-4 workouts per week
    final score = (count / target).clamp(0.0, 1.0);

    return TrendAnalysis(
      score: score,
      trend: count >= 12 ? 'improving' : count >= 8 ? 'stable' : 'declining',
      message: 'You\'ve completed $count workouts this month.',
    );
  }

  Future<TrendAnalysis> _analyzeMoodTrend() async {
    // Analyze mood logs
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('mood_logs')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(monthAgo))
        .get();

    if (snapshot.docs.isEmpty) {
      return TrendAnalysis(
        score: 0.5,
        trend: 'unknown',
        message: 'Start logging your mood to see trends.',
      );
    }

    final moods = snapshot.docs.map((doc) {
      final data = doc.data();
      return (data['score'] as num?)?.toDouble() ?? 5.0;
    }).toList();

    final avg = moods.reduce((a, b) => a + b) / moods.length;
    final score = (avg / 10).clamp(0.0, 1.0);

    return TrendAnalysis(
      score: score,
      trend: avg >= 7 ? 'improving' : avg >= 5 ? 'stable' : 'declining',
      message: 'Average mood: ${avg.toStringAsFixed(1)}/10',
    );
  }

  Future<TrendAnalysis> _analyzeSpiritualTrend() async {
    // Analyze spiritual practice frequency
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('spiritual_practices')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(monthAgo))
        .get();

    final count = snapshot.docs.length;
    final target = 20; // Most days
    final score = (count / target).clamp(0.0, 1.0);

    return TrendAnalysis(
      score: score,
      trend: count >= 15 ? 'improving' : count >= 10 ? 'stable' : 'declining',
      message: '$count spiritual practices this month.',
    );
  }

  Future<TrendAnalysis> _analyzeNutritionTrend() async {
    // Simplified - would analyze meal logs
    return TrendAnalysis(
      score: 0.7,
      trend: 'stable',
      message: 'Keep logging meals for better insights.',
    );
  }

  String _generateLifeAdvice(List<String> weakAreas, TrendAnalysis fitness, TrendAnalysis mood) {
    if (weakAreas.isEmpty) {
      return 'You\'re doing great! Keep maintaining this balance.';
    }

    if (weakAreas.length == 1) {
      final area = weakAreas.first;
      switch (area) {
        case 'fitness':
          return 'Focus on consistency over intensity. Even 10 minutes daily makes a difference.';
        case 'emotional_wellbeing':
          return 'Your emotional health matters. Try journaling or meditation to process feelings.';
        case 'spiritual_practice':
          return 'Even 2 minutes of daily practice can transform your inner peace.';
        case 'nutrition':
          return 'Small, mindful meals build better habits than strict diets.';
      }
    }

    return 'Focus on one area at a time. Progress in fitness often improves mood and vice versa.';
  }

  List<String> _getStrongAreas(List<String> weakAreas) {
    final allAreas = ['fitness', 'emotional_wellbeing', 'spiritual_practice', 'nutrition'];
    return allAreas.where((a) => !weakAreas.contains(a)).toList();
  }

  Future<List<String>> _getLongTermGoals() async {
    // Would fetch from user goals
    return [
      'Build consistent daily routine',
      'Improve emotional resilience',
      'Deepen spiritual practice',
    ];
  }
}

class LifeInsight {
  final List<String> weakAreas;
  final List<String> strongAreas;
  final double overallScore;
  final String personalizedAdvice;
  final List<String> longTermGoals;

  LifeInsight({
    required this.weakAreas,
    required this.strongAreas,
    required this.overallScore,
    required this.personalizedAdvice,
    required this.longTermGoals,
  });

  factory LifeInsight.empty() {
    return LifeInsight(
      weakAreas: [],
      strongAreas: [],
      overallScore: 0.5,
      personalizedAdvice: 'Start your journey today.',
      longTermGoals: [],
    );
  }
}

class TrendAnalysis {
  final double score; // 0.0 to 1.0
  final String trend; // 'improving', 'stable', 'declining'
  final String message;

  TrendAnalysis({
    required this.score,
    required this.trend,
    required this.message,
  });
}

class MicroGoal {
  final String category;
  final String description;
  final String priority; // 'high', 'medium', 'low'
  final int karmaReward;

  MicroGoal({
    required this.category,
    required this.description,
    required this.priority,
    required this.karmaReward,
  });
}

