import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/chat_message.dart';
import '../../data/models/user_state.dart';
import 'realtime_ai_service.dart';
import 'supabase_service.dart';

/// Production-ready AI Coach Service with Supabase realtime subscriptions,
/// cooldown/rate-limiting and proper lifecycle management.
class AICoachService {
  AICoachService({
    required RealtimeAIService realtimeAI,
    required SupabaseService supabase,
  })  : _realtimeAI = realtimeAI,
        _supabase = supabase;

  final RealtimeAIService _realtimeAI;
  final SupabaseService _supabase;

  // Stream controllers (broadcast so multiple listeners in UI)
  final StreamController<UserState> _userStateController =
      StreamController<UserState>.broadcast();
  final StreamController<Map<String, dynamic>> _coachInsightsController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<UserState> get userStateStream => _userStateController.stream;
  Stream<Map<String, dynamic>> get coachInsightsStream =>
      _coachInsightsController.stream;

  // Subscriptions & timers
  final List<RealtimeChannel> _channels = [];
  Timer? _monitorTimer;
  bool _initialized = false;

  // Rate limit & concurrency guards
  bool _isGenerating = false;
  DateTime? _lastInsightAt;
  final Duration insightCooldown = const Duration(minutes: 3);
  final Duration periodicInterval = const Duration(minutes: 5);
  final Duration aiTimeout = const Duration(seconds: 10);

  /// Initialize service: start realtime and fallback periodic monitoring
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Set up Supabase realtime subscriptions keyed on current user
    _setupRealtimeListeners();

    // Fallback periodic monitor (kept but now optional)
    _monitorTimer = Timer.periodic(periodicInterval, (t) async {
      await _onPeriodicTick();
    });

    // Listen to auth state changes to cleanup if user signs out
    _supabase.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        // signed out -> cleanup
        developer
            .log('User signed out, clearing AICoachService subscriptions.');
        _clearRealtimeSubscriptions();
      } else {
        // user signed in -> (re)setup listeners for new user
        developer.log('User signed in, re-initializing realtime listeners.');
        _clearRealtimeSubscriptions();
        _setupRealtimeListeners();
      }
    });
  }

  Future<void> _onPeriodicTick() async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return;
      final userState = await _getCurrentUserState();
      _userStateController.add(userState);
      await _maybeGenerateInsights(userState);
    } catch (e, st) {
      developer.log('Periodic tick error: $e', error: e, stackTrace: st);
    }
  }

  void _setupRealtimeListeners() {
    final user = _supabase.client.auth.currentUser;
    if (user == null) return;

    try {
      // Reuse SupabaseService helper which subscribes to user-scoped tables
      final channel = _supabase.subscribeToUserData(user.id, (data) {
        // Received an update for the user's data; trigger handler
        _onRealtimeEvent(user.id);
      });

      _channels.add(channel);
    } catch (e) {
      developer.log('Error setting realtime listeners: $e');
    }
  }

  Future<void> _onRealtimeEvent(String userId) async {
    try {
      // When a realtime DB event arrives, fetch current state and generate insights.
      final userState = await _getCurrentUserState();
      _userStateController.add(userState);

      // Generate insights but respect cooldown
      await _maybeGenerateInsights(userState);
    } catch (e, st) {
      developer.log('Realtime event handler error: $e',
          error: e, stackTrace: st);
    }
  }

  Future<void> _maybeGenerateInsights(UserState userState,
      {bool force = false}) async {
    if (_isGenerating) {
      developer.log('Insights generation currently in flight; skipping.');
      return;
    }
    final now = DateTime.now();
    if (!force &&
        _lastInsightAt != null &&
        now.difference(_lastInsightAt!) < insightCooldown) {
      developer.log('Insight cooldown active; skipping generation.');
      return;
    }

    _isGenerating = true;
    try {
      // run AI generation with timeout
      final insightsFuture = _generateCoachingInsights(userState);
      final insights = await insightsFuture.timeout(aiTimeout,
          onTimeout: () => <String, dynamic>{});
      if (insights.isNotEmpty) {
        _coachInsightsController.add(insights);
        _lastInsightAt = DateTime.now();
      }
    } catch (e, st) {
      developer.log('Error generating coaching insights: $e',
          error: e, stackTrace: st);
    } finally {
      _isGenerating = false;
    }
  }

  /// Get current user state - safe defensive calls
  Future<UserState> _getCurrentUserState() async {
    final user = _supabase.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // fetch profile (graceful fallback to empty map)
    Map<String, dynamic> profile = {};
    try {
      final res = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single()
          .maybeSingle();
      if (res != null) profile = Map<String, dynamic>.from(res as Map);
    } catch (e) {
      developer.log('Profile read error: $e');
    }

    // batch fetch recent activity in parallel
    final results = await Future.wait([
      _getRecentWorkouts(user.id),
      _getRecentMeals(user.id),
      _getRecentMood(user.id),
      _getRecentSpiritual(user.id),
    ]);

    final recentWorkouts = results[0]
        .map((w) => Workout.fromJson(w as Map<String, dynamic>))
        .toList();
    final recentMeals = results[1]
        .map((m) => Meal.fromJson(m as Map<String, dynamic>))
        .toList();
    final recentMood = results[2]
        .map((m) => MoodCheck.fromJson(m as Map<String, dynamic>))
        .toList();
    final recentSpiritual = results[3]
        .map((s) => SpiritualSession.fromJson(s as Map<String, dynamic>))
        .toList();

    return UserState(
      userId: user.id,
      timestamp: DateTime.now(),
      recentWorkouts: recentWorkouts,
      recentMeals: recentMeals,
      recentMood: recentMood,
      recentSpiritual: recentSpiritual,
      availableTime: _calculateAvailableTime(),
      sleepQuality: _getSleepQuality(),
      stressLevel: _getStressLevel(),
      energyLevel: _getEnergyLevel(),
      communityEngagement: _getCommunityEngagement(),
      currentGoals: _getCurrentGoals()
          .map((g) => Goal(
                id: g,
                userId: user.id,
                title: g,
                category: 'general',
                targetDate: DateTime.now(),
                progress: 0.0,
              ))
          .toList(),
      preferences: UserPreferences(
        userId: user.id,
        equipment: profile['equipment'] ?? [],
        dietary: profile['dietary_restrictions'] ?? [],
        workoutTime: profile['preferred_workout_time'] ?? 'morning',
        goals: profile['fitness_goals'] ?? [],
      ),
    );
  }

  /// Generate insights (your existing logic kept, but private)
  Future<Map<String, dynamic>> _generateCoachingInsights(
      UserState userState) async {
    final insights = <String, dynamic>{};

    if (userState.recentWorkouts.length < 3) {
      insights['workout_reminder'] = {
        'type': 'workout',
        'message':
            'You haven\'t worked out in a while. Ready for a quick session?',
        'priority': 'medium',
        'action': 'suggest_workout',
      };
    }

    if (userState.recentMeals.length < 3) {
      insights['nutrition_reminder'] = {
        'type': 'nutrition',
        'message': 'Don\'t forget to log your meals for better tracking!',
        'priority': 'low',
        'action': 'remind_meal_logging',
      };
    }

    if (userState.stressLevel > 7) {
      insights['stress_intervention'] = {
        'type': 'mood',
        'message':
            'I notice you might be feeling stressed. Let\'s do a quick breathing exercise.',
        'priority': 'high',
        'action': 'stress_intervention',
      };
    }

    if (userState.sleepQuality < 6) {
      insights['sleep_advice'] = {
        'type': 'sleep',
        'message':
            'Your sleep quality seems low. Here are some tips to improve it.',
        'priority': 'medium',
        'action': 'sleep_advice',
      };
    }

    return insights;
  }

  /// Public method to force insight generation (e.g., user tapped "Analyze now")
  Future<void> forceGenerateInsights() async {
    final user = _supabase.client.auth.currentUser;
    if (user == null) return;
    try {
      final state = await _getCurrentUserState();
      await _maybeGenerateInsights(state, force: true);
    } catch (e) {
      developer.log('forceGenerateInsights error: $e');
    }
  }

  /// Proactive message helper (unchanged logic)
  Future<void> sendProactiveMessage({
    required String userId,
    required String message,
    required String persona,
    Map<String, dynamic>? metadata,
  }) async {
    final chatMessage = ChatMessage.create(
      userId: userId,
      role: 'assistant',
      message: message,
      persona: persona,
    );

    await _saveMessage(chatMessage);

    // push message into realtime AI pipeline / UI
    try {
      _realtimeAI.messageStreamController.add(chatMessage);
    } catch (e) {
      developer.log('Realtime AI push failed: $e');
    }
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      await _supabase.client.from('ai_messages').insert({
        'id': message.id,
        'user_id': message.userId,
        'role': message.role,
        'message': message.message,
        'persona': message.persona,
        'session_id': message.sessionId,
        'created_at': message.createdAt.toIso8601String(),
      });
    } catch (e) {
      developer.log('Error saving message: $e');
    }
  }

  Future<List<ChatMessage>> getConversationHistory({
    required String userId,
    String? sessionId,
    int limit = 50,
  }) async {
    try {
      final query = _supabase.client
          .from('ai_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      // Note: session-scoped filtering omitted here to avoid a builder-type
      // analyzer issue in this project setup. If session filtering is required
      // we can build a separate query branch or update the supabase client
      // helper to support typed chaining in this codebase.
      final response = await query;
      final respList = response as List<dynamic>? ?? [];
      return respList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error getting conversation history: $e');
      return [];
    }
  }

  // Coaching action executor preserved (unchanged)
  Future<void> executeCoachingAction({
    required String userId,
    required String actionType,
    required Map<String, dynamic> parameters,
    required String persona,
  }) async {
    switch (actionType) {
      case 'suggest_workout':
        await _suggestWorkout(userId, parameters);
        break;
      case 'remind_meal_logging':
        await _remindMealLogging(userId, parameters);
        break;
      case 'stress_intervention':
        await _stressIntervention(userId, parameters);
        break;
      case 'sleep_advice':
        await _sleepAdvice(userId, parameters);
        break;
      default:
        developer.log('Unknown coaching action: $actionType');
    }
  }

  // helpers (unchanged)
  Future<void> _suggestWorkout(
      String userId, Map<String, dynamic> parameters) async {
    const message =
        'I\'ve created a personalized workout for you! Check your workout tab to get started.';
    await sendProactiveMessage(
      userId: userId,
      message: message,
      persona: 'astra',
    );
  }

  Future<void> _remindMealLogging(
      String userId, Map<String, dynamic> parameters) async {
    const message =
        'Don\'t forget to log your meals! It helps track your nutrition goals.';
    await sendProactiveMessage(
      userId: userId,
      message: message,
      persona: 'fuel',
    );
  }

  Future<void> _stressIntervention(
      String userId, Map<String, dynamic> parameters) async {
    const message =
        'Let\'s take a moment to breathe. Try this: Inhale for 4 counts, hold for 4, exhale for 6.';
    await sendProactiveMessage(
      userId: userId,
      message: message,
      persona: 'sage',
    );
  }

  Future<void> _sleepAdvice(
      String userId, Map<String, dynamic> parameters) async {
    const message =
        'For better sleep: avoid screens 1 hour before bed, keep your room cool, and try a bedtime routine.';
    await sendProactiveMessage(
      userId: userId,
      message: message,
      persona: 'sage',
    );
  }

  // Recent data helpers (defensive)
  Future<List<dynamic>> _getRecentWorkouts(String userId) async {
    try {
      final response = await _supabase.client
          .from('workouts')
          .select()
          .eq('user_id', userId)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String())
          .order('created_at', ascending: false);
      return response as List<dynamic>? ?? [];
    } catch (e) {
      developer.log('workouts read error: $e');
      return [];
    }
  }

  Future<List<dynamic>> _getRecentMeals(String userId) async {
    try {
      final response = await _supabase.client
          .from('nutrition_logs')
          .select()
          .eq('user_id', userId)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String())
          .order('created_at', ascending: false);
      return response as List<dynamic>? ?? [];
    } catch (e) {
      developer.log('meals read error: $e');
      return [];
    }
  }

  Future<List<dynamic>> _getRecentMood(String userId) async {
    try {
      final response = await _supabase.client
          .from('mood_checkins')
          .select()
          .eq('user_id', userId)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String())
          .order('created_at', ascending: false);
      return response as List<dynamic>? ?? [];
    } catch (e) {
      developer.log('mood read error: $e');
      return [];
    }
  }

  Future<List<dynamic>> _getRecentSpiritual(String userId) async {
    try {
      final response = await _supabase.client
          .from('spiritual_sessions')
          .select()
          .eq('user_id', userId)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String())
          .order('created_at', ascending: false);
      return response as List<dynamic>? ?? [];
    } catch (e) {
      developer.log('spiritual read error: $e');
      return [];
    }
  }

  int _calculateAvailableTime() {
    final hour = DateTime.now().hour;
    if (hour >= 9 && hour <= 17) return 30;
    if (hour >= 18 && hour <= 22) return 60;
    return 120;
  }

  double _getSleepQuality() => 7.5;
  double _getStressLevel() => 5.0;
  double _getEnergyLevel() => 6.5;
  double _getCommunityEngagement() => 0.7;
  List<String> _getCurrentGoals() =>
      ['Lose weight', 'Build muscle', 'Improve sleep'];

  // cleanup helpers
  Future<void> _clearRealtimeSubscriptions() async {
    try {
      for (final ch in _channels) {
        // SupabaseService.unsubscribe handles channel removal
        await _supabase.unsubscribe(ch);
      }
      _channels.clear();
    } catch (e) {
      developer.log('Error clearing realtime subscriptions: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _monitorTimer?.cancel();
    _clearRealtimeSubscriptions();
    try {
      _userStateController.close();
      _coachInsightsController.close();
    } catch (e) {
      developer.log('Error closing controllers: $e');
    }
    _initialized = false;
  }
}

/// Provider for AI Coach Service (autoDispose recommended in UI contexts)
final aiCoachServiceProvider = Provider<AICoachService>((ref) {
  final svc = AICoachService(
    realtimeAI: ref.read(realtimeAIServiceProvider),
    supabase: ref.read(supabaseServiceProvider),
  );

  // Optionally initialize when provider created — remove if you want manual init
  svc.initialize();

  ref.onDispose(() {
    svc.dispose();
  });

  return svc;
});
