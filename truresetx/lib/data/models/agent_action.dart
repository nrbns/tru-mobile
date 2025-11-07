/// Agent Action model for tracking AI agent actions
class AgentAction {
  AgentAction({
    required this.id,
    required this.type,
    required this.priority,
    required this.parameters,
    this.scheduledTime,
    this.completedTime,
    this.status = ActionStatus.pending,
    this.result,
    this.error,
  });

  factory AgentAction.fromJson(Map<String, dynamic> json) {
    return AgentAction(
      id: json['id'],
      type: ActionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ActionType.unknown,
      ),
      priority: json['priority'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'])
          : null,
      completedTime: json['completed_time'] != null
          ? DateTime.parse(json['completed_time'])
          : null,
      status: ActionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ActionStatus.pending,
      ),
      result: json['result'],
      error: json['error'],
    );
  }
  final String id;
  final ActionType type;
  final String priority; // high, medium, low
  final Map<String, dynamic> parameters;
  final DateTime? scheduledTime;
  final DateTime? completedTime;
  final ActionStatus status;
  final String? result;
  final String? error;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'priority': priority,
      'parameters': parameters,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'completed_time': completedTime?.toIso8601String(),
      'status': status.toString(),
      'result': result,
      'error': error,
    };
  }

  AgentAction copyWith({
    String? id,
    ActionType? type,
    String? priority,
    Map<String, dynamic>? parameters,
    DateTime? scheduledTime,
    DateTime? completedTime,
    ActionStatus? status,
    String? result,
    String? error,
  }) {
    return AgentAction(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      parameters: parameters ?? this.parameters,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedTime: completedTime ?? this.completedTime,
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

/// Action types enum
enum ActionType {
  // Workout actions
  workoutAssessment,
  createWorkout,
  createQuickWorkout,
  startARWorkout,
  submitRepMetrics,

  // Nutrition actions
  scanFood,
  logMeal,
  suggestMeal,
  createMealPlan,
  generateGroceryList,
  remindMealLogging,

  // Mood actions
  moodCheckIn,
  stressIntervention,
  cognitiveGame,
  moodAnalysis,

  // Spiritual actions
  spiritualSession,
  meditationGuide,
  breathworkSession,
  wisdomSharing,

  // Community actions
  communityEngagement,
  createChallenge,
  shareProgress,
  accountabilityCheck,

  // Safety actions
  safetyCheck,
  painDetection,
  emergencyAlert,
  riskAssessment,

  // General actions
  sendNotification,
  updatePreferences,
  dataSync,
  unknown,
}

/// Action status enum
enum ActionStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
  skipped,
}

/// Action result model
class ActionResult {
  ActionResult({
    required this.actionId,
    required this.success,
    this.message,
    this.data,
    required this.timestamp,
  });

  factory ActionResult.fromJson(Map<String, dynamic> json) {
    return ActionResult(
      actionId: json['action_id'],
      success: json['success'],
      message: json['message'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  final String actionId;
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'action_id': actionId,
      'success': success,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Action queue model for managing pending actions
class ActionQueue {
  ActionQueue({
    this.pendingActions = const [],
    this.inProgressActions = const [],
    this.completedActions = const [],
    this.maxConcurrentActions = 3,
  });
  final List<AgentAction> pendingActions;
  final List<AgentAction> inProgressActions;
  final List<ActionResult> completedActions;
  final int maxConcurrentActions;

  /// Add action to queue
  ActionQueue addAction(AgentAction action) {
    final updatedPending = List<AgentAction>.from(pendingActions)..add(action);
    return copyWith(pendingActions: updatedPending);
  }

  /// Start action
  ActionQueue startAction(String actionId) {
    final actionIndex = pendingActions.indexWhere((a) => a.id == actionId);
    if (actionIndex == -1) return this;

    final action = pendingActions[actionIndex];
    final updatedPending = List<AgentAction>.from(pendingActions)
      ..removeAt(actionIndex);
    final updatedInProgress = List<AgentAction>.from(inProgressActions)
      ..add(action.copyWith(status: ActionStatus.inProgress));

    return copyWith(
      pendingActions: updatedPending,
      inProgressActions: updatedInProgress,
    );
  }

  /// Complete action
  ActionQueue completeAction(String actionId, ActionResult result) {
    final actionIndex = inProgressActions.indexWhere((a) => a.id == actionId);
    if (actionIndex == -1) return this;

    final updatedInProgress = List<AgentAction>.from(inProgressActions)
      ..removeAt(actionIndex);
    final updatedCompleted = List<ActionResult>.from(completedActions)
      ..add(result);

    return copyWith(
      inProgressActions: updatedInProgress,
      completedActions: updatedCompleted,
    );
  }

  /// Get next action to process
  AgentAction? getNextAction() {
    if (inProgressActions.length >= maxConcurrentActions) return null;
    if (pendingActions.isEmpty) return null;

    // Sort by priority and return highest priority action
    pendingActions.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      return priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!);
    });

    return pendingActions.first;
  }

  /// Check if queue has capacity
  bool get hasCapacity => inProgressActions.length < maxConcurrentActions;

  /// Get queue statistics
  Map<String, int> getStatistics() {
    return {
      'pending': pendingActions.length,
      'in_progress': inProgressActions.length,
      'completed': completedActions.length,
      'total': pendingActions.length +
          inProgressActions.length +
          completedActions.length,
    };
  }

  ActionQueue copyWith({
    List<AgentAction>? pendingActions,
    List<AgentAction>? inProgressActions,
    List<ActionResult>? completedActions,
    int? maxConcurrentActions,
  }) {
    return ActionQueue(
      pendingActions: pendingActions ?? this.pendingActions,
      inProgressActions: inProgressActions ?? this.inProgressActions,
      completedActions: completedActions ?? this.completedActions,
      maxConcurrentActions: maxConcurrentActions ?? this.maxConcurrentActions,
    );
  }
}
