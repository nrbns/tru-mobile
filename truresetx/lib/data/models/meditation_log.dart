import 'package:uuid/uuid.dart';

/// Meditation Log model for TruResetX v1.0
class MeditationLog {
  MeditationLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.duration,
    required this.type,
    this.sessionName,
    this.moodBefore,
    this.moodAfter,
    this.notes,
    required this.createdAt,
  });

  /// Create a new meditation log
  factory MeditationLog.create({
    required String userId,
    DateTime? date,
    required int duration,
    required String type,
    String? sessionName,
    int? moodBefore,
    int? moodAfter,
    String? notes,
  }) {
    return MeditationLog(
      id: const Uuid().v4(),
      userId: userId,
      date: date ?? DateTime.now(),
      duration: duration,
      type: type,
      sessionName: sessionName,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory MeditationLog.fromJson(Map<String, dynamic> json) {
    return MeditationLog(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      type: json['type'],
      sessionName: json['session_name'],
      moodBefore: json['mood_before'],
      moodAfter: json['mood_after'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String userId;
  final DateTime date;
  final int duration; // in minutes
  final String type;
  final String? sessionName;
  final int? moodBefore; // 1-10
  final int? moodAfter; // 1-10
  final String? notes;
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'duration': duration,
      'type': type,
      'session_name': sessionName,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  MeditationLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? duration,
    String? type,
    String? sessionName,
    int? moodBefore,
    int? moodAfter,
    String? notes,
    DateTime? createdAt,
  }) {
    return MeditationLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      sessionName: sessionName ?? this.sessionName,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get duration in minutes
  int get durationMinutes => duration;

  /// Get duration display text
  String get durationDisplayText {
    if (duration < 60) return '${duration}m';
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }

  /// Get type display text
  String get typeDisplayText {
    switch (type) {
      case 'meditation':
        return 'Meditation';
      case 'breathwork':
        return 'Breathwork';
      case 'mindfulness':
        return 'Mindfulness';
      case 'visualization':
        return 'Visualization';
      default:
        return type;
    }
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

  /// Check if mood improved
  bool get moodImproved => (moodChange ?? 0) > 0;

  /// Check if mood stayed same
  bool get moodStayedSame => (moodChange ?? 0) == 0;

  /// Check if mood decreased
  bool get moodDecreased => (moodChange ?? 0) < 0;

  /// Get session intensity level
  String get intensityLevel {
    if (duration <= 5) return 'Light';
    if (duration <= 15) return 'Moderate';
    if (duration <= 30) return 'Intense';
    return 'Deep';
  }

  /// Get session category
  String get sessionCategory {
    switch (type) {
      case 'meditation':
        return 'Mindfulness';
      case 'breathwork':
        return 'Breathing';
      case 'mindfulness':
        return 'Awareness';
      case 'visualization':
        return 'Imagery';
      default:
        return 'Other';
    }
  }

  /// Get session emoji
  String get sessionEmoji {
    switch (type) {
      case 'meditation':
        return '🧘‍♀️';
      case 'breathwork':
        return '🫁';
      case 'mindfulness':
        return '🌱';
      case 'visualization':
        return '🌈';
      default:
        return '🧘';
    }
  }

  /// Get mood before emoji
  String get moodBeforeEmoji {
    if (moodBefore == null) return '❓';
    if (moodBefore! >= 8) return '😊';
    if (moodBefore! >= 6) return '🙂';
    if (moodBefore! >= 4) return '😐';
    if (moodBefore! >= 2) return '😕';
    return '😔';
  }

  /// Get mood after emoji
  String get moodAfterEmoji {
    if (moodAfter == null) return '❓';
    if (moodAfter! >= 8) return '😊';
    if (moodAfter! >= 6) return '🙂';
    if (moodAfter! >= 4) return '😐';
    if (moodAfter! >= 2) return '😕';
    return '😔';
  }

  /// Get effectiveness score (0-100)
  int get effectivenessScore {
    int score = 0;

    // Duration score (0-40 points)
    if (duration >= 30) {
      score += 40;
    } else if (duration >= 15) {
      score += 30;
    } else if (duration >= 10) {
      score += 20;
    } else if (duration >= 5) {
      score += 10;
    }

    // Mood improvement score (0-40 points)
    if (moodImproved) {
      final improvement = moodChange!;
      if (improvement >= 3) {
        score += 40;
      } else if (improvement >= 2) {
        score += 30;
      } else if (improvement >= 1) {
        score += 20;
      }
    }

    // Consistency score (0-20 points)
    if (notes != null && notes!.isNotEmpty) {
      score += 10;
    }
    if (sessionName != null && sessionName!.isNotEmpty) {
      score += 10;
    }

    return score;
  }

  /// Get effectiveness level
  String get effectivenessLevel {
    final score = effectivenessScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  /// Check if session is completed
  bool get isCompleted => duration > 0;

  /// Get session quality
  String get sessionQuality {
    if (duration < 5) return 'Too Short';
    if (duration > 60) return 'Very Long';
    if (moodImproved) return 'Effective';
    if (moodStayedSame) return 'Neutral';
    return 'Needs Improvement';
  }

  /// Get recommended next session duration
  int get recommendedNextDuration {
    if (duration < 5) return 10;
    if (duration < 15) return 20;
    if (duration < 30) return 30;
    return 45;
  }

  /// Get recommended next session type
  String get recommendedNextType {
    if (moodDecreased) return 'breathwork';
    if (moodImproved) return 'meditation';
    if (duration < 10) return 'mindfulness';
    return 'visualization';
  }

  /// Validate meditation log data
  bool get isValid {
    return duration > 0 &&
        duration <= 180 && // Max 3 hours
        ['meditation', 'breathwork', 'mindfulness', 'visualization']
            .contains(type) &&
        (moodBefore == null || (moodBefore! >= 1 && moodBefore! <= 10)) &&
        (moodAfter == null || (moodAfter! >= 1 && moodAfter! <= 10));
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (duration <= 0) {
      errors.add('Duration must be greater than 0');
    }

    if (duration > 180) {
      errors.add('Duration cannot exceed 180 minutes');
    }

    if (!['meditation', 'breathwork', 'mindfulness', 'visualization']
        .contains(type)) {
      errors.add('Invalid session type');
    }

    if (moodBefore != null && (moodBefore! < 1 || moodBefore! > 10)) {
      errors.add('Mood before must be between 1 and 10');
    }

    if (moodAfter != null && (moodAfter! < 1 || moodAfter! > 10)) {
      errors.add('Mood after must be between 1 and 10');
    }

    return errors;
  }

  @override
  String toString() {
    return 'MeditationLog(id: $id, type: $type, duration: ${duration}m, date: $date, moodChange: $moodChange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeditationLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
