/// Represents a live agent-coached session (workout, breath, meditation, etc.)
class AgentSession {
  final String sessionId;
  final String type; // 'workout', 'breath', 'meditation', 'contract', etc.
  final String title;
  final double progress; // 0.0 to 1.0
  final Duration? duration;
  final Duration? elapsed;
  final Map<String, dynamic>? config; // Session-specific settings
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isPaused;

  AgentSession({
    required this.sessionId,
    required this.type,
    required this.title,
    required this.progress,
    this.duration,
    this.elapsed,
    this.config,
    DateTime? startedAt,
    this.completedAt,
    this.isPaused = false,
  }) : startedAt = startedAt ?? DateTime.now();

  /// Create empty/idle session
  factory AgentSession.idle() {
    return AgentSession(
      sessionId: '',
      type: 'idle',
      title: '',
      progress: 0.0,
    );
  }

  bool get isActive => sessionId.isNotEmpty && completedAt == null;
  bool get isComplete => completedAt != null;

  AgentSession copyWith({
    String? sessionId,
    String? type,
    String? title,
    double? progress,
    Duration? duration,
    Duration? elapsed,
    Map<String, dynamic>? config,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isPaused,
  }) {
    return AgentSession(
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
      elapsed: elapsed ?? this.elapsed,
      config: config ?? this.config,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'type': type,
      'title': title,
      'progress': progress,
      'duration': duration?.inSeconds,
      'elapsed': elapsed?.inSeconds,
      'config': config,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'isPaused': isPaused,
    };
  }

  factory AgentSession.fromJson(Map<String, dynamic> json) {
    return AgentSession(
      sessionId: json['sessionId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      progress: (json['progress'] as num).toDouble(),
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      elapsed: json['elapsed'] != null
          ? Duration(seconds: json['elapsed'] as int)
          : null,
      config: json['config'] as Map<String, dynamic>?,
      startedAt: json['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startedAt'] as int)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
      isPaused: json['isPaused'] as bool? ?? false,
    );
  }
}

