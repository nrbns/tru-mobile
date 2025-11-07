import 'package:json_annotation/json_annotation.dart';

part 'workout_models.g.dart';

@JsonSerializable()
class Workout {
  Workout({
    required this.id,
    required this.userId,
    required this.date,
    this.title,
    required this.planJson,
    this.createdAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

  final int id;
  final String userId;
  final DateTime date;
  final String? title;
  final Map<String, dynamic> planJson;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  /// Get workout plan
  WorkoutPlan get plan => WorkoutPlan.fromJson(planJson);

  /// Get workout title or default
  String get displayTitle => title ?? 'Workout ${date.toString().split(' ')[0]}';

  /// Get total estimated duration
  int get estimatedDuration {
    return plan.exercises.fold(0, (total, exercise) => 
      total + (exercise.sets * exercise.reps * 3)); // 3 seconds per rep estimate
  }

  /// Get total sets
  int get totalSets {
    return plan.exercises.fold(0, (total, exercise) => total + exercise.sets);
  }

  /// Get total reps
  int get totalReps {
    return plan.exercises.fold(0, (total, exercise) => 
      total + (exercise.sets * exercise.reps));
  }
}

@JsonSerializable()
class WorkoutPlan {
  WorkoutPlan({
    required this.exercises,
    this.duration,
    this.difficulty,
    this.focus,
    this.notes,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);

  final List<WorkoutExercise> exercises;
  final int? duration; // in minutes
  final String? difficulty; // 'beginner', 'intermediate', 'advanced'
  final String? focus; // 'strength', 'cardio', 'flexibility', 'balance'
  final String? notes;

  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);

  /// Get exercises by muscle group
  List<WorkoutExercise> getExercisesByMuscle(String muscle) {
    return exercises.where((exercise) => 
      exercise.primaryMuscle.toLowerCase() == muscle.toLowerCase()).toList();
  }

  /// Get total estimated calories
  int get estimatedCalories {
    return exercises.fold(0, (total, exercise) => 
      total + (exercise.sets * exercise.reps * 2)); // 2 calories per rep estimate
  }
}

@JsonSerializable()
class WorkoutExercise {
  WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.primaryMuscle,
    required this.sets,
    required this.reps,
    this.weight,
    this.restTime,
    this.notes,
    this.arTargets,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);

  final int exerciseId;
  final String name;
  final String primaryMuscle;
  final int sets;
  final int reps;
  final double? weight;
  final int? restTime; // in seconds
  final String? notes;
  final Map<String, dynamic>? arTargets;

  Map<String, dynamic> toJson() => _$WorkoutExerciseToJson(this);

  /// Get formatted weight string
  String get weightString {
    if (weight == null) return 'Bodyweight';
    return '${weight!.toStringAsFixed(weight! % 1 == 0 ? 0 : 1)} kg';
  }

  /// Get formatted rest time
  String get restTimeString {
    if (restTime == null) return 'No rest';
    if (restTime! < 60) return '${restTime}s';
    return '${(restTime! / 60).toStringAsFixed(1)}m';
  }

  /// Get total reps for this exercise
  int get totalReps => sets * reps;
}

@JsonSerializable()
class SetLog {
  SetLog({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.setNo,
    required this.reps,
    required this.repMetrics,
    required this.arScores,
    required this.painFlag,
    this.createdAt,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);

  final int id;
  final int workoutId;
  final int exerciseId;
  final int setNo;
  final int reps;
  final List<RepMetric> repMetrics;
  final Map<String, dynamic> arScores;
  final bool painFlag;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$SetLogToJson(this);

  /// Get overall form score (0-100)
  int get formScore {
    final score = arScores['overall_score'] as num?;
    return score?.toInt() ?? 0;
  }

  /// Get error count
  int get errorCount {
    final errors = arScores['errors'] as Map<String, dynamic>?;
    if (errors == null) return 0;
    return errors.values.fold(0, (total, count) => total + (count as int));
  }

  /// Get specific error count
  int getErrorCount(String errorType) {
    final errors = arScores['errors'] as Map<String, dynamic>?;
    return errors?[errorType] as int? ?? 0;
  }

  /// Get form feedback
  List<String> get formFeedback {
    final feedback = <String>[];
    final errors = arScores['errors'] as Map<String, dynamic>?;
    
    if (errors != null) {
      errors.forEach((errorType, count) {
        if (count > 0) {
          feedback.add('${_getErrorDescription(errorType)}: $count times');
        }
      });
    }
    
    return feedback;
  }

  String _getErrorDescription(String errorType) {
    switch (errorType) {
      case 'depth_low':
        return 'Insufficient depth';
      case 'knee_valgus':
        return 'Knee valgus';
      case 'hip_shift':
        return 'Hip shift';
      case 'tempo_fast':
        return 'Too fast tempo';
      case 'rom_short':
        return 'Short range of motion';
      case 'hips_sag':
        return 'Hips sagging';
      case 'scap_wing':
        return 'Scapular winging';
      case 'knee_travel':
        return 'Knee traveling forward';
      case 'balance_loss':
        return 'Loss of balance';
      case 'hip_drop':
        return 'Hip dropping';
      default:
        return errorType.replaceAll('_', ' ').toUpperCase();
    }
  }
}

@JsonSerializable()
class RepMetric {
  RepMetric({
    required this.repNumber,
    required this.timestamp,
    required this.metrics,
    this.quality,
    this.errors,
  });

  factory RepMetric.fromJson(Map<String, dynamic> json) => _$RepMetricFromJson(json);

  final int repNumber;
  final DateTime timestamp;
  final Map<String, dynamic> metrics;
  final double? quality; // 0-1
  final List<String>? errors;

  Map<String, dynamic> toJson() => _$RepMetricToJson(this);

  /// Get rep quality as percentage
  int get qualityPercentage {
    if (quality == null) return 0;
    return (quality! * 100).round();
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

@JsonSerializable()
class WorkoutSession {
  WorkoutSession({
    required this.workout,
    required this.setLogs,
    this.startTime,
    this.endTime,
    this.totalDuration,
    this.caloriesBurned,
    this.notes,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

  final Workout workout;
  final List<SetLog> setLogs;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? totalDuration; // in minutes
  final int? caloriesBurned;
  final String? notes;

  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  /// Get completion percentage
  double get completionPercentage {
    final totalSets = workout.totalSets;
    if (totalSets == 0) return 0.0;
    return (setLogs.length / totalSets).clamp(0.0, 1.0);
  }

  /// Get average form score
  double get averageFormScore {
    if (setLogs.isEmpty) return 0.0;
    final totalScore = setLogs.fold(0, (total, setLog) => total + setLog.formScore);
    return totalScore / setLogs.length;
  }

  /// Get total errors
  int get totalErrors {
    return setLogs.fold(0, (total, setLog) => total + setLog.errorCount);
  }

  /// Get workout status
  WorkoutStatus get status {
    if (startTime == null) return WorkoutStatus.notStarted;
    if (endTime == null) return WorkoutStatus.inProgress;
    return WorkoutStatus.completed;
  }

  /// Get formatted duration
  String get formattedDuration {
    if (totalDuration == null) return 'Not started';
    final hours = totalDuration! ~/ 60;
    final minutes = totalDuration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

enum WorkoutStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}

@JsonSerializable()
class ARTargets {
  ARTargets({
    required this.exerciseId,
    required this.targets,
    this.tempo,
    this.cues,
  });

  factory ARTargets.fromJson(Map<String, dynamic> json) => _$ARTargetsFromJson(json);

  final int exerciseId;
  final Map<String, dynamic> targets;
  final Map<String, dynamic>? tempo;
  final List<String>? cues;

  Map<String, dynamic> toJson() => _$ARTargetsToJson(this);

  /// Get target depth
  double? get targetDepth => targets['depth'] as double?;

  /// Get target tempo
  Map<String, double>? get targetTempo {
    if (tempo == null) return null;
    return {
      'eccentric': (tempo!['eccentric'] as num?)?.toDouble() ?? 2.0,
      'concentric': (tempo!['concentric'] as num?)?.toDouble() ?? 1.0,
      'pause': (tempo!['pause'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// Get formatted tempo string
  String get tempoString {
    final tempoMap = targetTempo;
    if (tempoMap == null) return 'Normal tempo';
    return '${tempoMap['eccentric']?.toInt()}-${tempoMap['pause']?.toInt()}-${tempoMap['concentric']?.toInt()}';
  }
}
