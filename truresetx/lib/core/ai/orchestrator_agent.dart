import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../services/ai_service.dart';
import '../services/health_service.dart' as health_service;
import '../services/calendar_service.dart';
import '../../data/models/user_state.dart';
import '../../data/models/agent_action.dart';

/// The Orchestrator Agent - the brain of TruResetX
/// Monitors user state and delegates tasks to specialist agents
class OrchestratorAgent {
  OrchestratorAgent({
    required AIService aiService,
    required health_service.HealthService healthService,
    required CalendarService calendarService,
  })  : _aiService = aiService,
        _healthService = healthService,
        _calendarService = calendarService;
  final AIService _aiService;
  final health_service.HealthService _healthService;
  final CalendarService _calendarService;
  final _uuidGen = const Uuid();

  // Cancellation token — set to true to request orchestrator shutdown
  bool _cancelled = false;

  /// Request cancellation of any running orchestration. Safe to call multiple times.
  void cancel() {
    _cancelled = true;
  }

  /// Main orchestration loop - runs continuously
  Future<void> orchestrateUserExperience(String userId) async {
    try {
      if (_cancelled) return;

      // 1. SCAN - Gather current state
      final userState = await _scanUserState(userId).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TimeoutException('Scan user state timed out'),
      );

      if (_cancelled) return;

      // 2. ASK - Determine what needs attention
      final priorities = await _analyzePriorities(userState)
          .timeout(const Duration(seconds: 10));

      if (_cancelled) return;

      // 3. PLAN - Decide on actions
      final actions = await _planActions(priorities, userState);

      if (_cancelled) return;

      // 4. ACT - Execute actions
      await _executeActions(actions, userId);

      if (_cancelled) return;

      // 5. VERIFY - Check outcomes and adapt
      await _verifyAndAdapt(actions, userId);
    } catch (e, st) {
      // Log and fallback
      print('Orchestrator error: $e\n$st');
      try {
        await _fallbackWellnessPrompt(userId);
      } catch (_) {}
    }
  }

  /// SCAN: Gather comprehensive user state
  Future<UserState> _scanUserState(String userId) async {
    final now = DateTime.now();

    // Get recent activity (commented out due to type conflicts)
    // final recentWorkouts = await _healthService.getRecentWorkouts(userId, 7);
    // final recentMeals = await _healthService.getRecentMeals(userId, 7);
    // final recentMood = await _healthService.getRecentMoodChecks(userId, 7);
    // final recentSpiritual = await _healthService.getRecentSpiritualSessions(userId, 7);

    // Get calendar availability
    final calendarEvents = await _calendarService.getTodaySchedule(userId);
    final availableTime = _calculateAvailableTime(calendarEvents);

    // Get health metrics
    final sleepData = await _healthService.getSleepData(userId, 7);
    final stressLevel = await _healthService.getCurrentStressLevel(userId);
    final energyLevel = await _healthService.getCurrentEnergyLevel(userId);

    // Get community engagement
    final communityActivity =
        await _healthService.getCommunityActivity(userId, 7);

    return UserState(
      userId: userId,
      timestamp: now,
      recentWorkouts: [], // TODO: Convert health service workouts to data models
      recentMeals: [], // TODO: Convert health service meals to data models
      recentMood: [], // TODO: Convert health service mood to data models
      recentSpiritual: [], // TODO: Convert health service spiritual to data models
      availableTime: availableTime,
      sleepQuality: sleepData.averageQuality,
      stressLevel: stressLevel,
      energyLevel: energyLevel,
      communityEngagement: communityActivity,
      currentGoals: [], // TODO: Convert health service goals to data models
      preferences: UserPreferences(
        userId: userId,
        equipment: [],
        dietary: [],
        workoutTime: 'morning',
        goals: [],
      ),
    );
  }

  /// ASK: Analyze priorities based on current state
  Future<List<Priority>> _analyzePriorities(UserState userState) async {
    final prompt = '''
    Analyze this user's wellness state and determine priorities:
    
    User State:
    - Energy Level: ${userState.energyLevel}/10
    - Stress Level: ${userState.stressLevel}/10
    - Sleep Quality: ${userState.sleepQuality}/10
    - Available Time: ${userState.availableTime} minutes
    - Recent Workouts: ${userState.recentWorkouts.length} in last 7 days
    - Recent Meals: ${userState.recentMeals.length} logged in last 7 days
    - Recent Mood Checks: ${userState.recentMood.length} in last 7 days
    - Recent Spiritual Sessions: ${userState.recentSpiritual.length} in last 7 days
    
    Current Goals: ${userState.currentGoals.map((g) => g.title).join(', ')}
    
    Determine the top 3 priorities and return as JSON:
    [
      {
        "category": "workout|nutrition|mood|spiritual|community",
        "urgency": "high|medium|low",
        "reason": "explanation",
        "suggestedAction": "what to do"
      }
    ]
    ''';

    try {
      final raw = await _aiService.chatCompletion(prompt).timeout(
            const Duration(seconds: 8),
          );

      // decode on background isolate to avoid blocking UI
      final decoded = await compute(_safeJsonDecode, raw);
      if (decoded == null || decoded is! List) {
        debugPrint(
            'Priorities parse failed or invalid shape, decoded=$decoded');
        return _fallbackPriorities(userState);
      }

      final list = <Priority>[];
      for (final e in decoded) {
        if (e is Map<String, dynamic>) {
          list.add(Priority.fromJson(e));
        }
      }

      return list;
    } catch (e, st) {
      debugPrint('Failed analyzePriorities: $e\n$st');
      return _fallbackPriorities(userState);
    }
  }

// small safe decoder used with compute
  dynamic _safeJsonDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  List<Priority> _fallbackPriorities(UserState s) {
    return [
      Priority(
        category: 'nutrition',
        urgency: 'medium',
        reason: 'default fallback',
        suggestedAction: 'log_meal',
      ),
    ];
  }

  /// PLAN: Create specific actions based on priorities
  Future<List<AgentAction>> _planActions(
      List<Priority> priorities, UserState userState) async {
    final actions = <AgentAction>[];

    for (final priority in priorities) {
      switch (priority.category) {
        case 'workout':
          actions.addAll(await _planWorkoutActions(priority, userState));
          break;
        case 'nutrition':
          actions.addAll(await _planNutritionActions(priority, userState));
          break;
        case 'mood':
          actions.addAll(await _planMoodActions(priority, userState));
          break;
        case 'spiritual':
          actions.addAll(await _planSpiritualActions(priority, userState));
          break;
        case 'community':
          actions.addAll(await _planCommunityActions(priority, userState));
          break;
      }
    }

    return actions;
  }

  /// ACT: Execute planned actions
  Future<void> _executeActions(List<AgentAction> actions, String userId) async {
    for (final action in actions) {
      try {
        await _executeAction(action, userId);
      } catch (e) {
        print('Failed to execute action ${action.type}: $e');
      }
    }
  }

  /// VERIFY: Check outcomes and adapt
  Future<void> _verifyAndAdapt(List<AgentAction> actions, String userId) async {
    // Check if actions were successful
    final successfulActions = <AgentAction>[];
    final failedActions = <AgentAction>[];

    for (final action in actions) {
      final success = await _checkActionSuccess(action, userId);
      if (success) {
        successfulActions.add(action);
      } else {
        failedActions.add(action);
      }
    }

    // Adapt based on results
    if (failedActions.isNotEmpty) {
      await _adaptToFailures(failedActions, userId);
    }

    // Update user preferences based on successful actions
    await _updateUserPreferences(successfulActions, userId);
  }

  // Specialist Agent Planning Methods

  Future<List<AgentAction>> _planWorkoutActions(
      Priority priority, UserState userState) async {
    final actions = <AgentAction>[];

    // Check if user needs movement assessment
    final lastAssessment =
        await _healthService.getLastAssessment(userState.userId);
    final daysSinceAssessment = lastAssessment != null
        ? DateTime.now().difference(lastAssessment.date).inDays
        : 999;

    if (daysSinceAssessment > 7) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.workoutAssessment,
        priority: priority.urgency,
        parameters: {
          'reason': 'Weekly movement assessment due',
          'duration': 10, // minutes
        },
      ));
    }

    // Plan workout based on available time and energy
    if (userState.availableTime > 20 && userState.energyLevel > 6) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.createWorkout,
        priority: priority.urgency,
        parameters: {
          'duration': userState.availableTime,
          'energy_level': userState.energyLevel,
          'stress_level': userState.stressLevel,
          'equipment': userState.preferences.equipment,
        },
      ));
    } else if (userState.availableTime > 5) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.createQuickWorkout,
        priority: priority.urgency,
        parameters: {
          'duration': 5,
          'type': 'mobility',
        },
      ));
    }

    return actions;
  }

  Future<List<AgentAction>> _planNutritionActions(
      Priority priority, UserState userState) async {
    final actions = <AgentAction>[];

    // Check meal logging frequency
    final todayMeals = userState.recentMeals
        .where((meal) => meal.date.day == DateTime.now().day)
        .length;

    if (todayMeals < 3) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.remindMealLogging,
        priority: priority.urgency,
        parameters: {
          'meals_missed': 3 - todayMeals,
          'next_meal_time': _getNextMealTime(),
        },
      ));
    }

    // Suggest next meal based on macros
    final remainingMacros =
        await _healthService.getRemainingMacros(userState.userId);

    if (remainingMacros.protein > 20) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.suggestMeal,
        priority: priority.urgency,
        parameters: {
          'remaining_macros': remainingMacros.toJson(),
          'preferences': userState.preferences.dietary,
        },
      ));
    }

    return actions;
  }

  Future<List<AgentAction>> _planMoodActions(
      Priority priority, UserState userState) async {
    final actions = <AgentAction>[];

    // Check mood check-in frequency
    final todayMood = userState.recentMood
        .where((mood) => mood.date.day == DateTime.now().day)
        .length;

    if (todayMood == 0) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.moodCheckIn,
        priority: priority.urgency,
        parameters: {
          'time_of_day': _getTimeOfDay(),
          'stress_level': userState.stressLevel,
        },
      ));
    }

    // Suggest interventions based on stress/energy
    if (userState.stressLevel > 7) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.stressIntervention,
        priority: 'high',
        parameters: {
          'stress_level': userState.stressLevel,
          'available_time': userState.availableTime,
        },
      ));
    }

    return actions;
  }

  Future<List<AgentAction>> _planSpiritualActions(
      Priority priority, UserState userState) async {
    final actions = <AgentAction>[];

    // Check spiritual session frequency
    final todaySpiritual = userState.recentSpiritual
        .where((session) => session.date.day == DateTime.now().day)
        .length;

    if (todaySpiritual == 0) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.spiritualSession,
        priority: priority.urgency,
        parameters: {
          'time_of_day': _getTimeOfDay(),
          'stress_level': userState.stressLevel,
          'energy_level': userState.energyLevel,
        },
      ));
    }

    return actions;
  }

  Future<List<AgentAction>> _planCommunityActions(
      Priority priority, UserState userState) async {
    final actions = <AgentAction>[];

    // Check community engagement
    if (userState.communityEngagement < 0.3) {
      final actionId = _uuidGen.v4();
      actions.add(AgentAction(
        id: actionId,
        type: ActionType.communityEngagement,
        priority: priority.urgency,
        parameters: {
          'engagement_level': userState.communityEngagement,
          'suggested_actions': ['check_in', 'share_progress', 'support_others'],
        },
      ));
    }

    return actions;
  }

  // Helper Methods

  int _calculateAvailableTime(List<CalendarEvent> events) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
    int availableMinutes = endOfDay.difference(now).inMinutes;

    // Merge overlapping busy intervals and subtract from available time
    events.sort((a, b) => a.start.compareTo(b.start));
    DateTime? currentBusyEnd;
    int totalBusy = 0;

    for (final ev in events) {
      if (ev.end.isBefore(now)) continue;
      final start = ev.start.isBefore(now) ? now : ev.start;
      final end = ev.end.isAfter(endOfDay) ? endOfDay : ev.end;

      if (currentBusyEnd == null || start.isAfter(currentBusyEnd)) {
        // new busy block
        totalBusy += end.difference(start).inMinutes;
        currentBusyEnd = end;
      } else {
        // extend current block
        if (end.isAfter(currentBusyEnd)) {
          totalBusy += end.difference(currentBusyEnd).inMinutes;
          currentBusyEnd = end;
        }
      }
    }

    final available = (availableMinutes - totalBusy).clamp(0, 480);
    return available;
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _getNextMealTime() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'breakfast';
    if (hour < 15) return 'lunch';
    return 'dinner';
  }

  Future<void> _executeAction(AgentAction action, String userId) async {
    switch (action.type) {
      case ActionType.workoutAssessment:
        await _healthService.scheduleAssessment(userId, action.parameters);
        break;
      case ActionType.createWorkout:
        await _healthService.createWorkoutPlan(userId, action.parameters);
        break;
      case ActionType.createQuickWorkout:
        await _healthService.createQuickWorkout(userId, action.parameters);
        break;
      case ActionType.startARWorkout:
        // TODO: Implement AR workout session start
        print('Starting AR workout session for user $userId');
        break;
      case ActionType.submitRepMetrics:
        // TODO: Submit rep metrics to database
        print('Submitting rep metrics for user $userId');
        break;
      case ActionType.remindMealLogging:
        await _healthService.sendMealReminder(userId, action.parameters);
        break;
      case ActionType.suggestMeal:
        await _healthService.suggestNextMeal(userId, action.parameters);
        break;
      case ActionType.moodCheckIn:
        await _healthService.scheduleMoodCheck(userId, action.parameters);
        break;
      case ActionType.stressIntervention:
        await _healthService.scheduleStressIntervention(
            userId, action.parameters);
        break;
      case ActionType.spiritualSession:
        await _healthService.scheduleSpiritualSession(
            userId, action.parameters);
        break;
      case ActionType.communityEngagement:
        await _healthService.scheduleCommunityActivity(
            userId, action.parameters);
        break;
      default:
        print('Unhandled action type: ${action.type}');
        break;
    }
  }

  Future<bool> _checkActionSuccess(AgentAction action, String userId) async {
    // Implementation would check if the action was completed successfully
    return true; // Simplified for now
  }

  Future<void> _adaptToFailures(
      List<AgentAction> failedActions, String userId) async {
    // Learn from failures and adjust future actions
    for (final action in failedActions) {
      await _healthService.recordActionFailure(userId, action);
    }
  }

  Future<void> _updateUserPreferences(
      List<AgentAction> successfulActions, String userId) async {
    // Update user preferences based on successful actions
    await _healthService.updateUserPreferences(userId, successfulActions);
  }

  Future<void> _fallbackWellnessPrompt(String userId) async {
    // Send a simple wellness check-in if orchestration fails
    await _healthService.sendWellnessCheckIn(userId);
  }
}

// Providers
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(apiKey: 'demo-key'); // TODO: Use real API key
});

final healthServiceProvider = Provider<health_service.HealthService>((ref) {
  return health_service.HealthService();
});

final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

// Provider for the Orchestrator Agent
final orchestratorAgentProvider =
    Provider.autoDispose<OrchestratorAgent>((ref) {
  final agent = OrchestratorAgent(
    aiService: ref.read(aiServiceProvider),
    healthService: ref.read(healthServiceProvider),
    calendarService: ref.read(calendarServiceProvider),
  );

  // Ensure long-running orchestration is cancelled when provider is disposed
  ref.onDispose(() {
    agent.cancel();
  });

  return agent;
});

// Priority class
class Priority {
  Priority({
    required this.category,
    required this.urgency,
    required this.reason,
    required this.suggestedAction,
  });

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      category: json['category'],
      urgency: json['urgency'],
      reason: json['reason'],
      suggestedAction: json['suggestedAction'],
    );
  }
  final String category;
  final String urgency;
  final String reason;
  final String suggestedAction;
}
