import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'today_service.dart';
import 'mood_service.dart';
import 'spiritual_service.dart';

/// Domain types for multi-domain coaching
enum CoachDomain {
  nutrition,
  mood,
  workout,
  spiritual,
  general,
  crossDomain,
}

/// Domain-Aware AI Coach Service
/// Enhanced version of HealthifyMe's "Ria" for body+mind+spirit
class DomainAwareCoachService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TodayService _todayService = TodayService();
  final MoodService _moodService = MoodService();
  final SpiritualService _spiritualService = SpiritualService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('DomainAwareCoachService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Detect domain from user input
  Future<CoachDomain> detectDomain(String message) async {
    final lowerMessage = message.toLowerCase();

    // Keyword-based detection (can be enhanced with ML)
    if (_containsKeywords(lowerMessage, [
      'food',
      'meal',
      'eat',
      'calorie',
      'nutrition',
      'diet',
      'snack',
      'breakfast',
      'lunch',
      'dinner',
    ])) {
      return CoachDomain.nutrition;
    }

    if (_containsKeywords(lowerMessage, [
      'mood',
      'feel',
      'sad',
      'happy',
      'anxious',
      'stress',
      'depressed',
      'emotional',
      'mental',
    ])) {
      return CoachDomain.mood;
    }

    if (_containsKeywords(lowerMessage, [
      'workout',
      'exercise',
      'gym',
      'run',
      'cardio',
      'strength',
      'fitness',
    ])) {
      return CoachDomain.workout;
    }

    if (_containsKeywords(lowerMessage, [
      'pray',
      'meditation',
      'spiritual',
      'mantra',
      'practice',
      'sadhana',
      'ritual',
    ])) {
      return CoachDomain.spiritual;
    }

    return CoachDomain.general;
  }

  bool _containsKeywords(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Get comprehensive user context for coaching
  Future<Map<String, dynamic>> getUserContext() async {
    final uid = _requireUid();
    final today = await _todayService.getToday();

    // Get recent mood (use existing MoodService API)
    final recentMoods = await _moodService.getMoodLogs(limit: 7);
    final avgMood = recentMoods.isNotEmpty
        ? recentMoods.map((m) => m.score).reduce((a, b) => a + b) /
            recentMoods.length
        : 5.0;

    // Get recent meals
    final mealLogsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('meal_logs')
        .orderBy('at', descending: true)
        .limit(3)
        .get();
    final recentMeals = mealLogsSnapshot.docs.length;

    // Get spiritual practice streak
    final streak = await _spiritualService.getStreakDays();

    return {
      'today_stats': {
        'kcal': today.calories,
        'mood': today.mood.latest ?? 5,
        'workouts': today.workouts.done,
        'sadhana': today.sadhana.done,
      },
      'trends': {
        'avg_mood_7d': avgMood,
        'recent_meals': recentMeals,
        'spiritual_streak': streak,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get coach response with domain awareness
  Future<Map<String, dynamic>> getCoachResponse({
    required String message,
    CoachDomain? domain,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    try {
      // Auto-detect domain if not provided
      final detectedDomain = domain ?? await detectDomain(message);

      // Get user context
      final context = await getUserContext();

      // Build domain-specific system prompt
      final systemPrompt = _buildSystemPrompt(detectedDomain, context);

      // Call AI with domain-aware prompt
      final callable = _functions.httpsCallable('domainAwareChat');
      final result = await callable.call({
        'message': message,
        'domain': detectedDomain.name,
        'system_prompt': systemPrompt,
        'context': context,
        'history': chatHistory ?? [],
      });

      final response = Map<String, dynamic>.from(result.data);

      // Generate cross-domain suggestions if applicable
      if (detectedDomain != CoachDomain.general) {
        response['suggestions'] = await _generateCrossDomainSuggestions(
          detectedDomain,
          context,
        );
      }

      return response;
    } catch (e) {
      throw Exception('Failed to get coach response: $e');
    }
  }

  String _buildSystemPrompt(CoachDomain domain, Map<String, dynamic> context) {
    final todayStats = context['today_stats'] as Map<String, dynamic>;
    final trends = context['trends'] as Map<String, dynamic>;

    switch (domain) {
      case CoachDomain.nutrition:
        return '''You are TruResetX Nutrition Coach. Help users with healthy eating.
User's stats: Calories today: ${todayStats['kcal']}, Recent meals: ${trends['recent_meals']}, Avg mood: ${trends['avg_mood_7d']?.toStringAsFixed(1) ?? 5.0}
Consider mood-food correlations. Be supportive and practical. Keep responses concise.''';

      case CoachDomain.mood:
        return '''You are TruResetX Mind Coach (CBT expert). Help users with mood and mental wellness.
User's stats: Today's mood: ${todayStats['mood']}, 7-day avg: ${trends['avg_mood_7d']?.toStringAsFixed(1) ?? 5.0}, Spiritual streak: ${trends['spiritual_streak']} days
Consider suggesting workouts or spiritual practices for mood improvement. Be empathetic.''';

      case CoachDomain.workout:
        return '''You are TruResetX Fitness Coach. Help users with workouts and fitness.
User's stats: Workouts today: ${todayStats['workouts']}, Calories: ${todayStats['kcal']}
Consider suggesting post-workout nutrition or meditation for recovery. Be motivating.''';

      case CoachDomain.spiritual:
        return '''You are TruResetX Spiritual Guide. Help users with spiritual practices.
User's stats: Practices today: ${todayStats['sadhana']}, Streak: ${trends['spiritual_streak']} days
Be respectful of all traditions. Encourage consistency.''';

      default:
        return '''You are TruResetX Wellness Coach covering body, mind, and spirit.
User's stats: ${todayStats.toString()}
Provide holistic guidance across all domains. Be supportive and actionable.''';
    }
  }

  /// Generate cross-domain suggestions
  Future<List<String>> _generateCrossDomainSuggestions(
    CoachDomain currentDomain,
    Map<String, dynamic> context,
  ) async {
    final todayStats = context['today_stats'] as Map<String, dynamic>;
    final trends = context['trends'] as Map<String, dynamic>;
    final suggestions = <String>[];

    // Mood-based suggestions
    final mood = todayStats['mood'] as int? ?? 5;
    if (mood < 4 && currentDomain != CoachDomain.mood) {
      suggestions.add(
          'Your mood seems low today. Try: 10-min walk + gratitude practice');
    }

    // Nutrition + Workout correlation
    if (currentDomain == CoachDomain.nutrition) {
      final workouts = todayStats['workouts'] as int? ?? 0;
      if (workouts > 0) {
        suggestions
            .add('Post-workout tip: Add protein-rich snack within 30 min');
      }
    }

    // Spiritual + Mood correlation
    if (currentDomain == CoachDomain.spiritual) {
      final streak = trends['spiritual_streak'] as int? ?? 0;
      if (streak > 7) {
        suggestions.add(
            'Amazing streak! Notice how this consistency affects your mood');
      }
    }

    // Low calories + low mood
    final kcal = todayStats['kcal'] as int? ?? 0;
    if (kcal < 1200 && mood < 5) {
      suggestions.add(
          'Low calories + mood? Try: Balanced meal → mood check in 30 min');
    }

    return suggestions;
  }

  /// Get proactive suggestions based on user state
  Future<List<String>> getProactiveSuggestions() async {
    final context = await getUserContext();
    final todayStats = context['today_stats'] as Map<String, dynamic>;
    final suggestions = <String>[];

    final mood = todayStats['mood'] as int? ?? 5;
    final kcal = todayStats['kcal'] as int? ?? 0;
    final workouts = todayStats['workouts'] as int? ?? 0;
    final sadhana = todayStats['sadhana'] as int? ?? 0;

    // Morning suggestions
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      if (kcal == 0) {
        suggestions.add('🌅 Start your day: Protein breakfast within 1 hour');
      }
      if (sadhana == 0) {
        suggestions
            .add('🧘 Morning practice: 5-min meditation sets tone for day');
      }
    }

    // Afternoon suggestions
    if (hour >= 12 && hour < 18) {
      if (workouts == 0 && mood < 5) {
        suggestions.add('🚶 Low mood? Quick 10-min walk can boost energy');
      }
    }

    // Evening suggestions
    if (hour >= 18) {
      if (sadhana == 0) {
        suggestions.add('🌙 Evening reflection: Log gratitude practice');
      }
      if (kcal < 1500) {
        suggestions.add('🍽️ Light dinner + early sleep aids recovery');
      }
    }

    return suggestions;
  }
}
