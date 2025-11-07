import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/food_log.dart';
import '../models/mood_log.dart';
import '../models/meditation_log.dart';
import '../models/daily_summary.dart';
import '../models/notification.dart' as app_notification;
import '../../core/services/supabase_service.dart';
import '../../core/services/realtime_service.dart';

/// Live user profile provider
final liveUserProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield null;
    return;
  }

  // Get initial profile
  final profile =
      await ref.read(supabaseServiceProvider).getUserProfile(user.id);
  yield profile;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'user_profile' && data['action'] == 'UPDATE') {
      final updatedProfile = UserProfile.fromJson(data['data']);
      yield updatedProfile;
    }
  }
});

/// Live workouts provider
final liveWorkoutsProvider = StreamProvider<List<Workout>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  // Get initial workouts
  final workouts =
      await ref.read(supabaseServiceProvider).getUserWorkouts(user.id);
  yield workouts;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'workout') {
      // Refresh workouts when changes occur
      final updatedWorkouts =
          await ref.read(supabaseServiceProvider).getUserWorkouts(user.id);
      yield updatedWorkouts;
    }
  }
});

/// Live food logs provider
final liveFoodLogsProvider = StreamProvider<List<FoodLog>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  // Get initial food logs
  final foodLogs =
      await ref.read(supabaseServiceProvider).getUserFoodLogs(user.id);
  yield foodLogs;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'food_log') {
      // Refresh food logs when changes occur
      final updatedFoodLogs =
          await ref.read(supabaseServiceProvider).getUserFoodLogs(user.id);
      yield updatedFoodLogs;
    }
  }
});

/// Live mood logs provider
final liveMoodLogsProvider = StreamProvider<List<MoodLog>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  // Get initial mood logs
  final moodLogs =
      await ref.read(supabaseServiceProvider).getUserMoodLogs(user.id);
  yield moodLogs;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'mood_log') {
      // Refresh mood logs when changes occur
      final updatedMoodLogs =
          await ref.read(supabaseServiceProvider).getUserMoodLogs(user.id);
      yield updatedMoodLogs;
    }
  }
});

/// Live meditation logs provider
final liveMeditationLogsProvider =
    StreamProvider<List<MeditationLog>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  // Get initial meditation logs
  final meditationLogs =
      await ref.read(supabaseServiceProvider).getUserMeditationLogs(user.id);
  yield meditationLogs;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'meditation_log') {
      // Refresh meditation logs when changes occur
      final updatedMeditationLogs = await ref
          .read(supabaseServiceProvider)
          .getUserMeditationLogs(user.id);
      yield updatedMeditationLogs;
    }
  }
});

/// Live daily summary provider
final liveDailySummaryProvider = StreamProvider<DailySummary?>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield null;
    return;
  }

  final today = DateTime.now();

  // Get today's summary
  final summary =
      await ref.read(supabaseServiceProvider).getDailySummary(user.id, today);
  yield summary;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'daily_summary') {
      // Refresh daily summary when changes occur
      final updatedSummary = await ref
          .read(supabaseServiceProvider)
          .getDailySummary(user.id, today);
      yield updatedSummary;
    }
  }
});

/// Live user statistics provider
final liveUserStatsProvider =
    StreamProvider<Map<String, dynamic>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield {};
    return;
  }

  // Get initial stats
  final stats = await ref.read(supabaseServiceProvider).getUserStats(user.id);
  yield stats;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'workout' ||
        data['type'] == 'food_log' ||
        data['type'] == 'mood_log' ||
        data['type'] == 'meditation_log') {
      // Refresh stats when any data changes
      final updatedStats =
          await ref.read(supabaseServiceProvider).getUserStats(user.id);
      yield updatedStats;
    }
  }
});

/// Live weekly progress provider
final liveWeeklyProgressProvider =
    StreamProvider<Map<String, dynamic>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield {};
    return;
  }

  final startOfWeek =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  // Get initial weekly progress
  final progress = await ref
      .read(supabaseServiceProvider)
      .getWeeklyProgress(user.id, startOfWeek);
  yield progress;

  // Listen for real-time updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final data in realtimeService.dataStream) {
    if (data['type'] == 'workout' ||
        data['type'] == 'food_log' ||
        data['type'] == 'mood_log' ||
        data['type'] == 'meditation_log') {
      // Refresh weekly progress when any data changes
      final updatedProgress = await ref
          .read(supabaseServiceProvider)
          .getWeeklyProgress(user.id, startOfWeek);
      yield updatedProgress;
    }
  }
});

/// Live notifications provider
final liveNotificationsProvider =
    StreamProvider<List<app_notification.Notification>>((ref) async* {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  // Get initial notifications
  final notifications =
      await ref.read(supabaseServiceProvider).getUserNotifications(user.id);
  yield notifications;

  // Listen for real-time notification updates
  final realtimeService = ref.read(realtimeServiceProvider);
  await for (final _ in realtimeService.notificationStream) {
    // Refresh notifications when an event arrives
    final currentNotifications =
        await ref.read(supabaseServiceProvider).getUserNotifications(user.id);
    yield currentNotifications;
  }
});

/// Live connection status provider
final liveConnectionStatusProvider = StreamProvider<String>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.connectionStream;
});

/// Live metrics provider for real-time tracking
final liveMetricsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream
      .where((data) => data['type'] == 'live_metrics');
});

/// Live AI insights provider
final liveAIInsightsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream
      .where((data) => data['type'] == 'ai_insight');
});

/// Live community updates provider
final liveCommunityUpdatesProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream
      .where((data) => data['type'] == 'community_update');
});

/// Live workout metrics provider for real-time workout tracking
final liveWorkoutMetricsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream.where(
      (data) => data['type'] == 'workout_metrics' || data['type'] == 'workout');
});

/// Live mood tracking provider for real-time mood updates
final liveMoodTrackingProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream.where(
      (data) => data['type'] == 'mood_update' || data['type'] == 'mood_log');
});

/// Live nutrition tracking provider for real-time nutrition updates
final liveNutritionTrackingProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream.where((data) =>
      data['type'] == 'nutrition_update' || data['type'] == 'food_log');
});

/// Live meditation progress provider for real-time meditation tracking
final liveMeditationProgressProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.dataStream.where((data) =>
      data['type'] == 'meditation_progress' ||
      data['type'] == 'meditation_log');
});
