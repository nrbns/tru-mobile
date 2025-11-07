/// Workout Plan model for comprehensive workout planning
class WorkoutPlan {

  WorkoutPlan({
    required this.planId,
    required this.userId,
    required this.goals,
    required this.durationWeeks,
    required this.blocks,
    required this.assessmentSchedule,
    required this.safetyGuidelines,
    required this.metadata,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      planId: json['plan_id'],
      userId: json['user_id'],
      goals: List<String>.from(json['goals']),
      durationWeeks: json['duration_weeks'],
      blocks: (json['blocks'] as List)
          .map((b) => ProgramBlock.fromJson(b))
          .toList(),
      assessmentSchedule: Map<String, dynamic>.from(json['assessment_schedule']),
      safetyGuidelines: Map<String, dynamic>.from(json['safety_guidelines']),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
  final String planId;
  final String userId;
  final List<String> goals;
  final int durationWeeks;
  final List<ProgramBlock> blocks;
  final Map<String, dynamic> assessmentSchedule;
  final Map<String, dynamic> safetyGuidelines;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'user_id': userId,
      'goals': goals,
      'duration_weeks': durationWeeks,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'assessment_schedule': assessmentSchedule,
      'safety_guidelines': safetyGuidelines,
      'metadata': metadata,
    };
  }
}

/// Program Block model for workout periodization
class ProgramBlock {

  ProgramBlock({
    required this.week,
    required this.focus,
    required this.sessions,
  });

  factory ProgramBlock.fromJson(Map<String, dynamic> json) {
    return ProgramBlock(
      week: json['week'],
      focus: json['focus'],
      sessions: (json['sessions'] as List)
          .map((s) => WorkoutSession.fromJson(s))
          .toList(),
    );
  }
  final int week;
  final String focus;
  final List<WorkoutSession> sessions;

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'focus': focus,
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
  }
}

/// Workout Session model for individual workout sessions
class WorkoutSession {

  WorkoutSession({
    required this.day,
    required this.durationMinutes,
    required this.type,
    required this.exercises,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      day: json['day'],
      durationMinutes: json['duration_minutes'],
      type: json['type'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
  final String day;
  final int durationMinutes;
  final String type;
  final List<Exercise> exercises;

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'duration_minutes': durationMinutes,
      'type': type,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// Exercise model for individual exercises within a workout
class Exercise {

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.tempo,
    required this.restSeconds,
    required this.arGuidance,
    required this.formCues,
    required this.parameters,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      tempo: json['tempo'],
      restSeconds: json['rest_seconds'],
      arGuidance: json['ar_guidance'],
      formCues: List<String>.from(json['form_cues']),
      parameters: Map<String, dynamic>.from(json['parameters']),
    );
  }
  final String name;
  final int sets;
  final int reps;
  final String tempo;
  final int restSeconds;
  final bool arGuidance;
  final List<String> formCues;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'tempo': tempo,
      'rest_seconds': restSeconds,
      'ar_guidance': arGuidance,
      'form_cues': formCues,
      'parameters': parameters,
    };
  }
}
