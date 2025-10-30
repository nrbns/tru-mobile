import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'mood_service.dart';
import 'spiritual_service.dart';
import 'today_service.dart';

/// Proactive Notifications Service - Context-aware reminders
class ProactiveNotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use default instance to avoid API mismatch across firebase_functions versions
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final MoodService _moodService = MoodService();
  final SpiritualService _spiritualService = SpiritualService();
  final TodayService _todayService = TodayService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('ProactiveNotificationsService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Get proactive suggestions based on current state
  Future<List<Map<String, dynamic>>> getProactiveSuggestions() async {
    final suggestions = <Map<String, dynamic>>[];

    try {
      // Get today's stats
      final today = await _todayService.getToday();

      // Check mood
      final recentMoods = await _moodService.getMoodLogs(limit: 1);
      if (recentMoods.isNotEmpty && recentMoods.first.score < 5) {
        suggestions.add({
          'type': 'mood',
          'priority': 'high',
          'title': 'Low Mood Detected',
          'message':
              'Try a 5-minute meditation or light workout to boost your mood',
          'action': 'meditation',
          'icon': 'mind',
        });
      }

      // Check hydration
      if (today.waterMl < 1000) {
        suggestions.add({
          'type': 'hydration',
          'priority': 'medium',
          'title': 'Stay Hydrated',
          'message': 'You\'ve had less water today. Drink a glass now!',
          'action': 'log_water',
          'icon': 'water',
        });
      }

      // Check meals
      if (today.calories < 500) {
        final hour = DateTime.now().hour;
        if (hour >= 12 && hour < 14) {
          suggestions.add({
            'type': 'nutrition',
            'priority': 'high',
            'title': 'Time for Lunch',
            'message':
                'You haven\'t eaten much today. Consider a balanced meal',
            'action': 'log_food',
            'icon': 'food',
          });
        }
      }

      // Check spiritual practice
      final spiritualStreak = await _spiritualService.getStreakDays();
      if (spiritualStreak > 0) {
        final practiceLogs = await _spiritualService.getPracticeLogs(limit: 1);
        if (practiceLogs.isEmpty ||
            (practiceLogs.isNotEmpty &&
                DateTime.now()
                        .difference(
                            (practiceLogs.first['date'] as Timestamp).toDate())
                        .inHours >
                    12)) {
          suggestions.add({
            'type': 'spiritual',
            'priority': 'medium',
            'title': 'Continue Your Streak',
            'message':
                'You\'re on a $spiritualStreak-day streak! Don\'t break it',
            'action': 'daily_practice',
            'icon': 'spirit',
          });
        }
      }

      // Check workout
      if (today.workouts.done == 0 && DateTime.now().hour < 20) {
        suggestions.add({
          'type': 'workout',
          'priority': 'low',
          'title': 'Move Your Body',
          'message': 'A quick 15-minute workout can boost your energy',
          'action': 'start_workout',
          'icon': 'workout',
        });
      }

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// Schedule notification via Cloud Function
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable('scheduleNotification');
      await callable.call({
        'title': title,
        'body': body,
        'scheduled_time': scheduledTime.toIso8601String(),
        'data': data ?? {},
      });
    } catch (e) {
      // Notification scheduling failed, but don't throw
      print('Failed to schedule notification: $e');
    }
  }

  /// Check if user should receive mood check-in prompt
  Future<bool> shouldPromptMoodCheckin() async {
    final recentMoods = await _moodService.getMoodLogs(limit: 1);
    if (recentMoods.isEmpty) return true;

    final lastMood = recentMoods.first.at;
    final hoursSinceLastMood = DateTime.now().difference(lastMood).inHours;

    // Prompt if last mood was more than 8 hours ago
    return hoursSinceLastMood > 8;
  }

  /// Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    final uid = _requireUid();
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    final push = settings['push'] as Map<String, dynamic>? ?? {};

    return {
      'enabled': push['enabled'] ?? true,
      'evening_reflection': push['evening_reflection'] ?? true,
      'hydration_nudges': push['hydration_nudges'] ?? true,
      'sadhana_reminders': push['sadhana_reminders'] ?? true,
      'mood_checkins': push['mood_checkins'] ?? true,
      'workout_reminders': push['workout_reminders'] ?? true,
    };
  }
}
