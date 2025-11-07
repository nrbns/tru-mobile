import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/telemetry_channel.dart';

/// Life Engine: Long-term guidance, life coaching, holistic growth
class AgenticLifeEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final TelemetryChannel _telemetry;

  AgenticLifeEngine(this._db, this._auth) : _telemetry = TelemetryChannel();

  String? get _uid => _auth.currentUser?.uid;

  /// Generate holistic life guidance based on all domains
  Future<LifeGuidance> generateGuidance({
    required Map<String, dynamic> fitnessData,
    required Map<String, dynamic> mentalData,
    required Map<String, dynamic> spiritualData,
    required Map<String, dynamic> socialData,
  }) async {
    final insights = <String>[];
    final recommendations = <String>[];

    // Analyze patterns across domains
    final fitnessTrend = fitnessData['trend'] as String? ?? 'stable';
    final mentalTrend = mentalData['trend'] as String? ?? 'stable';
    final spiritualTrend = spiritualData['trend'] as String? ?? 'stable';

    // Cross-domain insights
    if (fitnessTrend == 'improving' && mentalTrend == 'declining') {
      insights.add('Your body is thriving, but your mind needs attention');
      recommendations.add('Balance physical gains with mental recovery practices');
    }

    if (spiritualTrend == 'improving' && fitnessTrend == 'declining') {
      insights.add('Spiritual growth is strong; consider integrating movement into your practice');
      recommendations.add('Try spiritual fitness workouts (yoga with mantras)');
    }

    // Long-term goal alignment
    final longTermGoals = await _getLongTermGoals();
    final alignment = _checkGoalAlignment(fitnessData, mentalData, spiritualData, longTermGoals);

    return LifeGuidance(
      insights: insights,
      recommendations: recommendations,
      goalAlignment: alignment,
      suggestedFocus: _determineSuggestedFocus(fitnessData, mentalData, spiritualData),
      timestamp: DateTime.now(),
    );
  }

  /// Design daily rhythm (food, music, habits, social)
  Future<DailyRhythm> designDailyRhythm({
    required double energyLevel,
    required double stressLevel,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final hour = targetDate.hour;

    // Morning routine (6-10 AM)
    final morning = _generateMorningRoutine(energyLevel, stressLevel);

    // Midday (10 AM - 2 PM)
    final midday = _generateMiddayRoutine(energyLevel, stressLevel);

    // Afternoon (2-6 PM)
    final afternoon = _generateAfternoonRoutine(energyLevel, stressLevel);

    // Evening (6-10 PM)
    final evening = _generateEveningRoutine(energyLevel, stressLevel);

    // Night (10 PM+)
    final night = _generateNightRoutine(stressLevel);

    return DailyRhythm(
      date: targetDate,
      morning: morning,
      midday: midday,
      afternoon: afternoon,
      evening: evening,
      night: night,
      musicSuggestions: _generateMusicSuggestions(energyLevel, stressLevel),
      socialDetox: stressLevel > 0.7 ? 'Consider limiting social media today' : null,
    );
  }

  Future<List<String>> _getLongTermGoals() async {
    if (_uid == null) return [];

    final goalsDoc = await _db
        .collection('users')
        .doc(_uid)
        .collection('goals')
        .where('type', isEqualTo: 'long_term')
        .get();

    return goalsDoc.docs.map((doc) => doc.data()['description'] as String).toList();
  }

  Map<String, double> _checkGoalAlignment(
    Map<String, dynamic> fitness,
    Map<String, dynamic> mental,
    Map<String, dynamic> spiritual,
    List<String> goals,
  ) {
    // Simplified: return alignment scores per domain
    return {
      'fitness': 0.7,
      'mental': 0.8,
      'spiritual': 0.6,
    };
  }

  String _determineSuggestedFocus(
    Map<String, dynamic> fitness,
    Map<String, dynamic> mental,
    Map<String, dynamic> spiritual,
  ) {
    // Suggest focus on weakest area
    final scores = <String, double>{
      'fitness': (fitness['score'] as num?)?.toDouble() ?? 0.5,
      'mental': (mental['score'] as num?)?.toDouble() ?? 0.5,
      'spiritual': (spiritual['score'] as num?)?.toDouble() ?? 0.5,
    };

    final sorted = scores.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    return sorted.first.key;
  }

  RoutinePhase _generateMorningRoutine(double energy, double stress) {
    if (stress > 0.7) {
      return RoutinePhase(
        activities: ['Gentle breathing', 'Meditation', 'Light breakfast'],
        duration: Duration(minutes: 20),
      );
    }
    return RoutinePhase(
      activities: ['Movement', 'Hydration', 'Intent setting'],
      duration: Duration(minutes: 30),
    );
  }

  RoutinePhase _generateMiddayRoutine(double energy, double stress) {
    return RoutinePhase(
      activities: ['Focused work', 'Hydration check', 'Micro-break'],
      duration: Duration(hours: 4),
    );
  }

  RoutinePhase _generateAfternoonRoutine(double energy, double stress) {
    if (energy > 0.7) {
      return RoutinePhase(
        activities: ['Main workout', 'Post-workout recovery', 'Nutrition'],
        duration: Duration(hours: 2),
      );
    }
    return RoutinePhase(
      activities: ['Light activity', 'Rest', 'Reflection'],
      duration: Duration(hours: 2),
    );
  }

  RoutinePhase _generateEveningRoutine(double energy, double stress) {
    return RoutinePhase(
      activities: ['Dinner', 'Relaxation', 'Gratitude journal'],
      duration: Duration(hours: 3),
    );
  }

  RoutinePhase _generateNightRoutine(double stress) {
    if (stress > 0.7) {
      return RoutinePhase(
        activities: ['Sleep preparation', 'Calming sounds', 'No screens'],
        duration: Duration(minutes: 60),
      );
    }
    return RoutinePhase(
      activities: ['Wind down', 'Reading/meditation', 'Sleep'],
      duration: Duration(minutes: 60),
    );
  }

  List<String> _generateMusicSuggestions(double energy, double stress) {
    if (stress > 0.7) return ['Calm instrumental', 'Nature sounds', 'Binaural beats'];
    if (energy > 0.7) return ['Upbeat workout mix', 'Motivational tracks'];
    return ['Balanced playlist', 'Ambient background'];
  }
}

class LifeGuidance {
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, double> goalAlignment;
  final String suggestedFocus;
  final DateTime timestamp;

  LifeGuidance({
    required this.insights,
    required this.recommendations,
    required this.goalAlignment,
    required this.suggestedFocus,
    required this.timestamp,
  });
}

class DailyRhythm {
  final DateTime date;
  final RoutinePhase morning;
  final RoutinePhase midday;
  final RoutinePhase afternoon;
  final RoutinePhase evening;
  final RoutinePhase night;
  final List<String> musicSuggestions;
  final String? socialDetox;

  DailyRhythm({
    required this.date,
    required this.morning,
    required this.midday,
    required this.afternoon,
    required this.evening,
    required this.night,
    required this.musicSuggestions,
    this.socialDetox,
  });
}

class RoutinePhase {
  final List<String> activities;
  final Duration duration;

  RoutinePhase({
    required this.activities,
    required this.duration,
  });
}

