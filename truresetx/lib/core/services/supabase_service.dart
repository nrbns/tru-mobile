import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/workout.dart';
import '../../data/models/food_log.dart';
import '../../data/models/mood_log.dart';
import '../../data/models/meditation_log.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/user_goal.dart';
import '../../data/models/user_streak.dart';
import '../../data/models/notification.dart';
import '../../data/models/daily_summary.dart';
import 'realtime_service.dart';

/// Supabase Service for TruResetX v1.0
/// Handles all database operations and real-time subscriptions
class SupabaseService {
  SupabaseService._();
  static SupabaseService? _instance;
  late SupabaseClient _client;

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  /// Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );

    _client = Supabase.instance.client;

    // Initialize the realtime service with the Supabase client so the
    // app can receive realtime updates (lists, items, notifications, etc.).
    try {
      await RealtimeService.instance.initialize(_client);
    } catch (e) {
      // don't fail initialization if realtime can't start — apps should
      // still be usable in degraded mode.
      // ignore: avoid_print
      print('RealtimeService initialization failed: $e');
    }

    // Set up auth state listener
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _onUserSignedIn(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        _onUserSignedOut();
      }
    });
  }

  void _onUserSignedIn(User user) {
    print('User signed in: ${user.email}');
  }

  void _onUserSignedOut() {
    print('User signed out');
  }

  // Authentication Methods

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.truresetx://login-callback',
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // User Profile Methods

  /// Create user profile
  Future<UserProfile> createUserProfile(UserProfile profile) async {
    final response =
        await _client.from('users').insert(profile.toJson()).select().single();

    return UserProfile.fromJson(response);
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    final response =
        await _client.from('users').select().eq('id', userId).maybeSingle();

    return response != null ? UserProfile.fromJson(response) : null;
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    final response = await _client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  // Workout Methods

  /// Create workout
  Future<Workout> createWorkout(Workout workout) async {
    final response = await _client
        .from('workouts')
        .insert(workout.toJson())
        .select()
        .single();

    return Workout.fromJson(response);
  }

  /// Get user workouts
  Future<List<Workout>> getUserWorkouts(String userId, {int limit = 50}) async {
    final response = await _client
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return response.map((json) => Workout.fromJson(json)).toList();
  }

  /// Get workout by ID
  Future<Workout?> getWorkout(String workoutId) async {
    final response = await _client
        .from('workouts')
        .select()
        .eq('id', workoutId)
        .maybeSingle();

    return response != null ? Workout.fromJson(response) : null;
  }

  /// Update workout
  Future<Workout> updateWorkout(
      String workoutId, Map<String, dynamic> updates) async {
    final response = await _client
        .from('workouts')
        .update(updates)
        .eq('id', workoutId)
        .select()
        .single();

    return Workout.fromJson(response);
  }

  /// Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    await _client.from('workouts').delete().eq('id', workoutId);
  }

  // Food Log Methods

  /// Create food log
  Future<FoodLog> createFoodLog(FoodLog foodLog) async {
    final response = await _client
        .from('food_logs')
        .insert(foodLog.toJson())
        .select()
        .single();

    return FoodLog.fromJson(response);
  }

  /// Get user food logs
  Future<List<FoodLog>> getUserFoodLogs(String userId, {int limit = 50}) async {
    final response = await _client
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return response.map((json) => FoodLog.fromJson(json)).toList();
  }

  /// Get food logs for specific date
  Future<List<FoodLog>> getFoodLogsForDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _client
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .order('created_at', ascending: true);

    return response.map((json) => FoodLog.fromJson(json)).toList();
  }

  /// Delete food log
  Future<void> deleteFoodLog(String foodLogId) async {
    await _client.from('food_logs').delete().eq('id', foodLogId);
  }

  // Mood Log Methods

  /// Create mood log
  Future<MoodLog> createMoodLog(MoodLog moodLog) async {
    final response = await _client
        .from('mood_logs')
        .insert(moodLog.toJson())
        .select()
        .single();

    return MoodLog.fromJson(response);
  }

  /// Get user mood logs
  Future<List<MoodLog>> getUserMoodLogs(String userId, {int limit = 50}) async {
    final response = await _client
        .from('mood_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return response.map((json) => MoodLog.fromJson(json)).toList();
  }

  /// Get mood log for specific date
  Future<MoodLog?> getMoodLogForDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _client
        .from('mood_logs')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();

    return response != null ? MoodLog.fromJson(response) : null;
  }

  // Meditation Log Methods

  /// Create meditation log
  Future<MeditationLog> createMeditationLog(MeditationLog meditationLog) async {
    final response = await _client
        .from('meditation_logs')
        .insert(meditationLog.toJson())
        .select()
        .single();

    return MeditationLog.fromJson(response);
  }

  /// Get user meditation logs
  Future<List<MeditationLog>> getUserMeditationLogs(String userId,
      {int limit = 50}) async {
    final response = await _client
        .from('meditation_logs')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return response.map((json) => MeditationLog.fromJson(json)).toList();
  }

  // Chat Methods

  /// Create chat message
  Future<ChatMessage> createChatMessage(ChatMessage message) async {
    final response = await _client
        .from('chat_history')
        .insert(message.toJson())
        .select()
        .single();

    return ChatMessage.fromJson(response);
  }

  /// Get chat history
  Future<List<ChatMessage>> getChatHistory(String userId,
      {String? sessionId, int limit = 50}) async {
    var query = _client.from('chat_history').select().eq('user_id', userId);

    if (sessionId != null) {
      query = query.eq('session_id', sessionId);
    }

    final response =
        await query.order('created_at', ascending: false).limit(limit);
    return response.map((json) => ChatMessage.fromJson(json)).toList();
  }

  /// Get recent chat sessions
  Future<List<Map<String, dynamic>>> getChatSessions(String userId) async {
    final response = await _client
        .from('chat_history')
        .select('session_id, created_at, persona')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    // Group by session_id and get unique sessions
    final sessions = <String, Map<String, dynamic>>{};
    for (final row in response) {
      final sessionId = row['session_id'] as String?;
      if (sessionId != null && !sessions.containsKey(sessionId)) {
        sessions[sessionId] = {
          'session_id': sessionId,
          'created_at': row['created_at'],
          'persona': row['persona'],
        };
      }
    }

    return sessions.values.toList();
  }

  // User Goals Methods

  /// Create user goal
  Future<UserGoal> createUserGoal(UserGoal goal) async {
    final response = await _client
        .from('user_goals')
        .insert(goal.toJson())
        .select()
        .single();

    return UserGoal.fromJson(response);
  }

  /// Get user goals
  Future<List<UserGoal>> getUserGoals(String userId) async {
    final response = await _client
        .from('user_goals')
        .select()
        .eq('user_id', userId)
        .eq('is_completed', false)
        .order('created_at', ascending: false);

    return response.map((json) => UserGoal.fromJson(json)).toList();
  }

  /// Update user goal
  Future<UserGoal> updateUserGoal(
      String goalId, Map<String, dynamic> updates) async {
    final response = await _client
        .from('user_goals')
        .update(updates)
        .eq('id', goalId)
        .select()
        .single();

    return UserGoal.fromJson(response);
  }

  /// Complete user goal
  Future<UserGoal> completeUserGoal(String goalId) async {
    return await updateUserGoal(goalId, {
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  // User Streaks Methods

  /// Get user streaks
  Future<List<UserStreak>> getUserStreaks(String userId) async {
    final response =
        await _client.from('user_streaks').select().eq('user_id', userId);

    return response.map((json) => UserStreak.fromJson(json)).toList();
  }

  /// Get streak for specific category
  Future<UserStreak?> getUserStreak(String userId, String category) async {
    final response = await _client
        .from('user_streaks')
        .select()
        .eq('user_id', userId)
        .eq('category', category)
        .maybeSingle();

    return response != null ? UserStreak.fromJson(response) : null;
  }

  // Notifications Methods

  /// Create notification
  Future<Notification> createNotification(Notification notification) async {
    final response = await _client
        .from('notifications')
        .insert(notification.toJson())
        .select()
        .single();

    return Notification.fromJson(response);
  }

  /// Get user notifications
  Future<List<Notification>> getUserNotifications(String userId,
      {int limit = 50}) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return response.map((json) => Notification.fromJson(json)).toList();
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  // Daily Summaries Methods

  /// Create daily summary
  Future<DailySummary> createDailySummary(DailySummary summary) async {
    final response = await _client
        .from('daily_summaries')
        .upsert(summary.toJson())
        .select()
        .single();

    return DailySummary.fromJson(response);
  }

  /// Get daily summary
  Future<DailySummary?> getDailySummary(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _client
        .from('daily_summaries')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();

    return response != null ? DailySummary.fromJson(response) : null;
  }

  /// Get recent daily summaries
  Future<List<DailySummary>> getRecentDailySummaries(String userId,
      {int limit = 30}) async {
    final response = await _client
        .from('daily_summaries')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return response.map((json) => DailySummary.fromJson(json)).toList();
  }

  // Real-time Subscriptions

  /// Subscribe to user data changes
  RealtimeChannel subscribeToUserData(
      String userId, Function(Map<String, dynamic>) onData) {
    return _client
        .channel('user_data_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'workouts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onData(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'food_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onData(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mood_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }

  /// Unsubscribe from real-time updates
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  // Analytics Methods

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    // Get workout count
    final workoutCount = await _client
        .from('workouts')
        .select('id')
        .eq('user_id', userId)
        .count();

    // Get meditation count
    final meditationCount = await _client
        .from('meditation_logs')
        .select('id')
        .eq('user_id', userId)
        .count();

    // Get mood logs count
    final moodLogsCount = await _client
        .from('mood_logs')
        .select('id')
        .eq('user_id', userId)
        .count();

    // Get food logs count
    final foodLogsCount = await _client
        .from('food_logs')
        .select('id')
        .eq('user_id', userId)
        .count();

    // Get total calories burned
    final caloriesResult = await _client
        .from('workouts')
        .select('calories_burned')
        .eq('user_id', userId);

    final totalCaloriesBurned = caloriesResult
        .map((row) => row['calories_burned'] as int? ?? 0)
        .fold(0, (sum, calories) => sum + calories);

    // Get total meditation minutes
    final meditationMinutesResult = await _client
        .from('meditation_logs')
        .select('duration')
        .eq('user_id', userId);

    final totalMeditationMinutes = meditationMinutesResult
        .map((row) => row['duration'] as int? ?? 0)
        .fold(0, (sum, minutes) => sum + minutes);

    return {
      'workout_count': workoutCount,
      'meditation_count': meditationCount,
      'mood_logs_count': moodLogsCount,
      'food_logs_count': foodLogsCount,
      'total_calories_burned': totalCaloriesBurned,
      'total_meditation_minutes': totalMeditationMinutes,
    };
  }

  /// Get weekly progress
  Future<Map<String, dynamic>> getWeeklyProgress(
      String userId, DateTime startDate) async {
    final endDate = startDate.add(const Duration(days: 7));

    // Get workouts this week
    final workouts = await _client
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lt('date', endDate.toIso8601String().split('T')[0]);

    // Get meditation sessions this week
    final meditations = await _client
        .from('meditation_logs')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lt('date', endDate.toIso8601String().split('T')[0]);

    // Get mood logs this week
    final moodLogs = await _client
        .from('mood_logs')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lt('date', endDate.toIso8601String().split('T')[0]);

    return {
      'workouts': workouts.length,
      'meditation_sessions': meditations.length,
      'mood_logs': moodLogs.length,
      'average_mood': moodLogs.isNotEmpty
          ? moodLogs
                  .map((log) => log['mood_score'] as int)
                  .reduce((a, b) => a + b) /
              moodLogs.length
          : null,
      'total_workout_minutes': workouts
          .map((w) => w['duration'] as int? ?? 0)
          .fold(0, (sum, minutes) => sum + minutes),
      'total_meditation_minutes': meditations
          .map((m) => m['duration'] as int)
          .fold(0, (sum, minutes) => sum + minutes),
    };
  }
}

// Provider for Supabase Service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

// Provider for Supabase Client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // Return the globally initialized Supabase client. `Supabase.initialize`
  // is called in `main()` before providers are used, so using
  // `Supabase.instance.client` avoids accessing a late field on the
  // service singleton that may not yet be initialized.
  return Supabase.instance.client;
});
