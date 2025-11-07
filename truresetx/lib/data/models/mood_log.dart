import 'package:uuid/uuid.dart';

/// Mood Log model for TruResetX v1.0
class MoodLog {

  MoodLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodScore,
    required this.energyLevel,
    required this.stressLevel,
    required this.sleepQuality,
    this.notes,
    this.tags = const [],
    required this.createdAt,
  });

  /// Create a new mood log
  factory MoodLog.create({
    required String userId,
    DateTime? date,
    required int moodScore,
    required int energyLevel,
    required int stressLevel,
    required int sleepQuality,
    String? notes,
    List<String> tags = const [],
  }) {
    return MoodLog(
      id: const Uuid().v4(),
      userId: userId,
      date: date ?? DateTime.now(),
      moodScore: moodScore,
      energyLevel: energyLevel,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
      notes: notes,
      tags: tags,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      moodScore: json['mood_score'],
      energyLevel: json['energy_level'],
      stressLevel: json['stress_level'],
      sleepQuality: json['sleep_quality'],
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String userId;
  final DateTime date;
  final int moodScore; // 1-10
  final int energyLevel; // 1-10
  final int stressLevel; // 1-10
  final int sleepQuality; // 1-10
  final String? notes;
  final List<String> tags; // array of mood tags
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'mood_score': moodScore,
      'energy_level': energyLevel,
      'stress_level': stressLevel,
      'sleep_quality': sleepQuality,
      'notes': notes,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  MoodLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? moodScore,
    int? energyLevel,
    int? stressLevel,
    int? sleepQuality,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return MoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get overall wellness score (0-100)
  int get wellnessScore {
    const double moodWeight = 0.3;
    const double energyWeight = 0.25;
    const double stressWeight = 0.25;
    const double sleepWeight = 0.2;
    
    final score = (moodScore * moodWeight + 
                   energyLevel * energyWeight + 
                   (10 - stressLevel) * stressWeight + 
                   sleepQuality * sleepWeight) * 10;
    
    return score.round();
  }

  /// Get wellness level
  String get wellnessLevel {
    final score = wellnessScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  /// Get mood level
  String get moodLevel {
    if (moodScore >= 8) return 'Excellent';
    if (moodScore >= 6) return 'Good';
    if (moodScore >= 4) return 'Fair';
    return 'Poor';
  }

  /// Get energy level
  String get energyLevelText {
    if (energyLevel >= 8) return 'High';
    if (energyLevel >= 6) return 'Moderate';
    if (energyLevel >= 4) return 'Low';
    return 'Very Low';
  }

  /// Get stress level
  String get stressLevelText {
    if (stressLevel <= 3) return 'Low';
    if (stressLevel <= 5) return 'Moderate';
    if (stressLevel <= 7) return 'High';
    return 'Very High';
  }

  /// Get sleep quality
  String get sleepQualityText {
    if (sleepQuality >= 8) return 'Excellent';
    if (sleepQuality >= 6) return 'Good';
    if (sleepQuality >= 4) return 'Fair';
    return 'Poor';
  }

  /// Check if mood is trending positive
  bool isPositiveTrend(List<MoodLog> previousLogs) {
    if (previousLogs.length < 3) return false;
    
    final recentScores = previousLogs.take(3).map((log) => log.wellnessScore).toList();
    final currentScore = wellnessScore;
    
    return currentScore > recentScores.reduce((a, b) => a + b) / recentScores.length;
  }

  /// Check if mood is trending negative
  bool isNegativeTrend(List<MoodLog> previousLogs) {
    if (previousLogs.length < 3) return false;
    
    final recentScores = previousLogs.take(3).map((log) => log.wellnessScore).toList();
    final currentScore = wellnessScore;
    
    return currentScore < recentScores.reduce((a, b) => a + b) / recentScores.length;
  }

  /// Get recommended actions based on mood
  List<String> get recommendedActions {
    final actions = <String>[];
    
    if (moodScore < 5) {
      actions.add('Consider a short meditation or deep breathing');
    }
    
    if (energyLevel < 5) {
      actions.add('Take a short walk or do light stretching');
    }
    
    if (stressLevel > 7) {
      actions.add('Try progressive muscle relaxation');
    }
    
    if (sleepQuality < 5) {
      actions.add('Establish a bedtime routine');
    }
    
    if (wellnessScore < 40) {
      actions.add('Consider talking to a friend or professional');
    }
    
    return actions;
  }

  /// Get mood emoji
  String get moodEmoji {
    if (moodScore >= 9) return '😍';
    if (moodScore >= 8) return '😊';
    if (moodScore >= 7) return '🙂';
    if (moodScore >= 6) return '😐';
    if (moodScore >= 5) return '😕';
    if (moodScore >= 4) return '😔';
    if (moodScore >= 3) return '😢';
    if (moodScore >= 2) return '😭';
    return '😰';
  }

  /// Get energy emoji
  String get energyEmoji {
    if (energyLevel >= 8) return '⚡';
    if (energyLevel >= 6) return '🔋';
    if (energyLevel >= 4) return '🔌';
    return '🔋';
  }

  /// Get stress emoji
  String get stressEmoji {
    if (stressLevel <= 3) return '😌';
    if (stressLevel <= 5) return '😐';
    if (stressLevel <= 7) return '😰';
    return '😵';
  }

  /// Get sleep emoji
  String get sleepEmoji {
    if (sleepQuality >= 8) return '😴';
    if (sleepQuality >= 6) return '😑';
    if (sleepQuality >= 4) return '😪';
    return '😵';
  }

  /// Validate mood log data
  bool get isValid {
    return moodScore >= 1 && moodScore <= 10 &&
           energyLevel >= 1 && energyLevel <= 10 &&
           stressLevel >= 1 && stressLevel <= 10 &&
           sleepQuality >= 1 && sleepQuality <= 10;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (moodScore < 1 || moodScore > 10) {
      errors.add('Mood score must be between 1 and 10');
    }
    
    if (energyLevel < 1 || energyLevel > 10) {
      errors.add('Energy level must be between 1 and 10');
    }
    
    if (stressLevel < 1 || stressLevel > 10) {
      errors.add('Stress level must be between 1 and 10');
    }
    
    if (sleepQuality < 1 || sleepQuality > 10) {
      errors.add('Sleep quality must be between 1 and 10');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'MoodLog(id: $id, date: $date, mood: $moodScore, energy: $energyLevel, stress: $stressLevel, sleep: $sleepQuality, wellness: $wellnessScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
