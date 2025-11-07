import 'package:uuid/uuid.dart';

/// Workout model for TruResetX v1.0
class Workout {

  Workout({
    required this.id,
    required this.userId,
    this.planId,
    required this.date,
    required this.title,
    this.duration,
    this.caloriesBurned,
    this.arScore,
    this.moodBefore,
    this.moodAfter,
    this.notes,
    required this.createdAt,
    this.exercises = const [],
  });

  /// Create a new workout
  factory Workout.create({
    required String userId,
    String? planId,
    DateTime? date,
    required String title,
    int? duration,
    int? caloriesBurned,
    double? arScore,
    int? moodBefore,
    int? moodAfter,
    String? notes,
    List<Exercise> exercises = const [],
  }) {
    return Workout(
      id: const Uuid().v4(),
      userId: userId,
      planId: planId,
      date: date ?? DateTime.now(),
      title: title,
      duration: duration,
      caloriesBurned: caloriesBurned,
      arScore: arScore,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      notes: notes,
      createdAt: DateTime.now(),
      exercises: exercises,
    );
  }

  /// Create from JSON
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      duration: json['duration'],
      caloriesBurned: json['calories_burned'],
      arScore: json['ar_score']?.toDouble(),
      moodBefore: json['mood_before'],
      moodAfter: json['mood_after'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      exercises: const [], // Exercises loaded separately
    );
  }
  final String id;
  final String userId;
  final String? planId;
  final DateTime date;
  final String title;
  final int? duration; // in minutes
  final int? caloriesBurned;
  final double? arScore; // 0.00 to 1.00
  final int? moodBefore; // 1-10
  final int? moodAfter; // 1-10
  final String? notes;
  final DateTime createdAt;
  final List<Exercise> exercises;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'title': title,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'ar_score': arScore,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  Workout copyWith({
    String? id,
    String? userId,
    String? planId,
    DateTime? date,
    String? title,
    int? duration,
    int? caloriesBurned,
    double? arScore,
    int? moodBefore,
    int? moodAfter,
    String? notes,
    DateTime? createdAt,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      arScore: arScore ?? this.arScore,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
    );
  }

  /// Get workout duration in minutes
  int get durationMinutes => duration ?? 0;

  /// Get workout duration display text
  String get durationDisplayText {
    if (duration == null) return 'Not set';
    if (duration! < 60) return '${duration}m';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }

  /// Get AR score display text
  String get arScoreDisplayText {
    if (arScore == null) return 'Not scored';
    return '${(arScore! * 100).toInt()}%';
  }

  /// Get mood change
  int? get moodChange {
    if (moodBefore == null || moodAfter == null) return null;
    return moodAfter! - moodBefore!;
  }

  /// Get mood change display text
  String get moodChangeDisplayText {
    final change = moodChange;
    if (change == null) return 'No change';
    if (change > 0) return '+$change';
    return change.toString();
  }

  /// Get total exercises
  int get totalExercises => exercises.length;

  /// Get total sets
  int get totalSets => exercises.fold(0, (sum, exercise) => sum + (exercise.sets ?? 0));

  /// Get total reps
  int get totalReps => exercises.fold(0, (sum, exercise) => sum + (exercise.reps ?? 0));

  /// Get average form score
  double? get averageFormScore {
    if (exercises.isEmpty) return null;
    final scores = exercises.where((e) => e.formScore != null).map((e) => e.formScore!).toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Get workout intensity level
  String get intensityLevel {
    if (duration == null) return 'Unknown';
    if (duration! < 15) return 'Low';
    if (duration! < 45) return 'Moderate';
    return 'High';
  }

  /// Check if workout is completed
  bool get isCompleted => duration != null && duration! > 0;

  /// Get workout type based on title
  String get workoutType {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('strength') || titleLower.contains('weight')) return 'Strength';
    if (titleLower.contains('cardio') || titleLower.contains('run')) return 'Cardio';
    if (titleLower.contains('yoga') || titleLower.contains('stretch')) return 'Flexibility';
    if (titleLower.contains('hiit') || titleLower.contains('interval')) return 'HIIT';
    return 'General';
  }

  @override
  String toString() {
    return 'Workout(id: $id, title: $title, date: $date, duration: $durationMinutes min, exercises: $totalExercises)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Exercise model for workouts
class Exercise {

  Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    this.reps,
    this.sets,
    this.weight,
    this.duration,
    this.formScore,
    this.restTime,
    this.orderIndex,
    required this.createdAt,
  });

  /// Create a new exercise
  factory Exercise.create({
    required String workoutId,
    required String name,
    int? reps,
    int? sets,
    double? weight,
    int? duration,
    double? formScore,
    int? restTime,
    int? orderIndex,
  }) {
    return Exercise(
      id: const Uuid().v4(),
      workoutId: workoutId,
      name: name,
      reps: reps,
      sets: sets,
      weight: weight,
      duration: duration,
      formScore: formScore,
      restTime: restTime,
      orderIndex: orderIndex,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      workoutId: json['workout_id'],
      name: json['name'],
      reps: json['reps'],
      sets: json['sets'],
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      formScore: json['form_score']?.toDouble(),
      restTime: json['rest_time'],
      orderIndex: json['order_index'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String workoutId;
  final String name;
  final int? reps;
  final int? sets;
  final double? weight; // in kg
  final int? duration; // in seconds
  final double? formScore; // 0.00 to 1.00
  final int? restTime; // in seconds
  final int? orderIndex;
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'reps': reps,
      'sets': sets,
      'weight': weight,
      'duration': duration,
      'form_score': formScore,
      'rest_time': restTime,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  Exercise copyWith({
    String? id,
    String? workoutId,
    String? name,
    int? reps,
    int? sets,
    double? weight,
    int? duration,
    double? formScore,
    int? restTime,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      formScore: formScore ?? this.formScore,
      restTime: restTime ?? this.restTime,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get total volume (sets * reps)
  int get totalVolume => (sets ?? 0) * (reps ?? 0);

  /// Get form score display text
  String get formScoreDisplayText {
    if (formScore == null) return 'Not scored';
    return '${(formScore! * 100).toInt()}%';
  }

  /// Get duration display text
  String get durationDisplayText {
    if (duration == null) return 'Not set';
    if (duration! < 60) return '${duration}s';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
  }

  /// Get rest time display text
  String get restTimeDisplayText {
    if (restTime == null) return 'No rest';
    if (restTime! < 60) return '${restTime}s';
    final minutes = restTime! ~/ 60;
    final seconds = restTime! % 60;
    return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
  }

  /// Get weight display text
  String get weightDisplayText {
    if (weight == null) return 'Body weight';
    return '${weight!.toStringAsFixed(1)} kg';
  }

  /// Check if exercise is completed
  bool get isCompleted => (sets ?? 0) > 0 && (reps ?? 0) > 0;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, sets: $sets, reps: $reps, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
