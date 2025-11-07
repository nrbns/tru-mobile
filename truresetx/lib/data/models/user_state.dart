/// User State model for tracking comprehensive user wellness data
class UserState {
  UserState({
    required this.userId,
    required this.timestamp,
    required this.recentWorkouts,
    required this.recentMeals,
    required this.recentMood,
    required this.recentSpiritual,
    required this.availableTime,
    required this.sleepQuality,
    required this.stressLevel,
    required this.energyLevel,
    required this.communityEngagement,
    required this.currentGoals,
    required this.preferences,
  });

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      userId: json['user_id'],
      timestamp: DateTime.parse(json['timestamp']),
      recentWorkouts: (json['recent_workouts'] as List)
          .map((w) => Workout.fromJson(w))
          .toList(),
      recentMeals:
          (json['recent_meals'] as List).map((m) => Meal.fromJson(m)).toList(),
      recentMood: (json['recent_mood'] as List)
          .map((m) => MoodCheck.fromJson(m))
          .toList(),
      recentSpiritual: (json['recent_spiritual'] as List)
          .map((s) => SpiritualSession.fromJson(s))
          .toList(),
      availableTime: json['available_time'],
      sleepQuality: json['sleep_quality'].toDouble(),
      stressLevel: json['stress_level'].toDouble(),
      energyLevel: json['energy_level'].toDouble(),
      communityEngagement: json['community_engagement'].toDouble(),
      currentGoals:
          (json['current_goals'] as List).map((g) => Goal.fromJson(g)).toList(),
      preferences: UserPreferences.fromJson(json['preferences']),
    );
  }
  final String userId;
  final DateTime timestamp;
  final List<Workout> recentWorkouts;
  final List<Meal> recentMeals;
  final List<MoodCheck> recentMood;
  final List<SpiritualSession> recentSpiritual;
  final int availableTime; // minutes
  final double sleepQuality;
  final double stressLevel;
  final double energyLevel;
  final double communityEngagement;
  final List<Goal> currentGoals;
  final UserPreferences preferences;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'recent_workouts': recentWorkouts.map((w) => w.toJson()).toList(),
      'recent_meals': recentMeals.map((m) => m.toJson()).toList(),
      'recent_mood': recentMood.map((m) => m.toJson()).toList(),
      'recent_spiritual': recentSpiritual.map((s) => s.toJson()).toList(),
      'available_time': availableTime,
      'sleep_quality': sleepQuality,
      'stress_level': stressLevel,
      'energy_level': energyLevel,
      'community_engagement': communityEngagement,
      'current_goals': currentGoals.map((g) => g.toJson()).toList(),
      'preferences': preferences.toJson(),
    };
  }
}

/// Workout model
class Workout {
  Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.duration,
    required this.date,
    required this.exercises,
    this.type,
    this.intensity,
    this.metrics,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      duration: json['duration'],
      date: DateTime.parse(json['date']),
      exercises: List<String>.from(json['exercises']),
      type: json['type'],
      intensity: json['intensity']?.toDouble(),
      metrics: json['metrics'],
    );
  }
  final String id;
  final String userId;
  final String name;
  final int duration;
  final DateTime date;
  final List<String> exercises;
  final String? type;
  final double? intensity;
  final Map<String, dynamic>? metrics;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'duration': duration,
      'date': date.toIso8601String(),
      'exercises': exercises,
      'type': type,
      'intensity': intensity,
      'metrics': metrics,
    };
  }
}

/// Meal model
class Meal {
  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.date,
    required this.foods,
    this.macros,
    this.mealType,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      calories: json['calories'].toDouble(),
      date: DateTime.parse(json['date']),
      foods: List<String>.from(json['foods']),
      macros: json['macros'] != null
          ? Map<String, double>.from(json['macros'])
          : null,
      mealType: json['meal_type'],
    );
  }
  final String id;
  final String userId;
  final String name;
  final double calories;
  final DateTime date;
  final List<String> foods;
  final Map<String, double>? macros;
  final String? mealType;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'calories': calories,
      'date': date.toIso8601String(),
      'foods': foods,
      'macros': macros,
      'meal_type': mealType,
    };
  }
}

/// Mood check model
class MoodCheck {
  MoodCheck({
    required this.id,
    required this.userId,
    required this.energyLevel,
    required this.stressLevel,
    required this.mood,
    required this.date,
    this.additionalData,
  });

  factory MoodCheck.fromJson(Map<String, dynamic> json) {
    return MoodCheck(
      id: json['id'],
      userId: json['user_id'],
      energyLevel: json['energy_level'].toDouble(),
      stressLevel: json['stress_level'].toDouble(),
      mood: json['mood'],
      date: DateTime.parse(json['date']),
      additionalData: json['additional_data'],
    );
  }
  final String id;
  final String userId;
  final double energyLevel;
  final double stressLevel;
  final String mood;
  final DateTime date;
  final Map<String, dynamic>? additionalData;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'energy_level': energyLevel,
      'stress_level': stressLevel,
      'mood': mood,
      'date': date.toIso8601String(),
      'additional_data': additionalData,
    };
  }
}

/// Spiritual session model
class SpiritualSession {
  SpiritualSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.date,
    this.metadata,
  });

  factory SpiritualSession.fromJson(Map<String, dynamic> json) {
    return SpiritualSession(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      duration: json['duration'],
      date: DateTime.parse(json['date']),
      metadata: json['metadata'],
    );
  }
  final String id;
  final String userId;
  final String type;
  final int duration;
  final DateTime date;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'duration': duration,
      'date': date.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Goal model
class Goal {
  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.targetDate,
    required this.progress,
    this.metadata,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      category: json['category'],
      targetDate: DateTime.parse(json['target_date']),
      progress: json['progress'].toDouble(),
      metadata: json['metadata'],
    );
  }
  final String id;
  final String userId;
  final String title;
  final String category;
  final DateTime targetDate;
  final double progress;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'target_date': targetDate.toIso8601String(),
      'progress': progress,
      'metadata': metadata,
    };
  }
}

/// User preferences model
class UserPreferences {
  UserPreferences({
    required this.userId,
    required this.equipment,
    required this.dietary,
    required this.workoutTime,
    required this.goals,
    this.additionalPreferences,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'],
      equipment: List<String>.from(json['equipment']),
      dietary: List<String>.from(json['dietary']),
      workoutTime: json['workout_time'],
      goals: List<String>.from(json['goals']),
      additionalPreferences: json['additional_preferences'],
    );
  }
  final String userId;
  final List<String> equipment;
  final List<String> dietary;
  final String workoutTime;
  final List<String> goals;
  final Map<String, dynamic>? additionalPreferences;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'equipment': equipment,
      'dietary': dietary,
      'workout_time': workoutTime,
      'goals': goals,
      'additional_preferences': additionalPreferences,
    };
  }
}
