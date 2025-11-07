import 'package:uuid/uuid.dart';

/// User Streak model for TruResetX v1.0
class UserStreak {
  UserStreak({
    required this.id,
    required this.userId,
    required this.category,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.updatedAt,
  });

  /// Create a new user streak
  factory UserStreak.create({
    required String userId,
    required String category,
  }) {
    final now = DateTime.now();
    return UserStreak(
      id: const Uuid().v4(),
      userId: userId,
      category: category,
      currentStreak: 0,
      longestStreak: 0,
      lastActivityDate: null,
      updatedAt: now,
    );
  }

  /// Create from JSON
  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  final String id;
  final String userId;
  final String category;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final DateTime updatedAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate?.toIso8601String().split('T')[0],
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with new values
  UserStreak copyWith({
    String? id,
    String? userId,
    String? category,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    DateTime? updatedAt,
  }) {
    return UserStreak(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'workouts':
        return 'Workouts';
      case 'meditation':
        return 'Meditation';
      case 'mood_logging':
        return 'Mood Logging';
      case 'nutrition_logging':
        return 'Nutrition Logging';
      default:
        return category;
    }
  }

  /// Get category emoji
  String get categoryEmoji {
    switch (category) {
      case 'workouts':
        return '💪';
      case 'meditation':
        return '🧘';
      case 'mood_logging':
        return '😊';
      case 'nutrition_logging':
        return '🍎';
      default:
        return '🔥';
    }
  }

  /// Get streak status
  String get streakStatus {
    if (currentStreak == 0) return 'No Streak';
    if (currentStreak == 1) return '1 Day';
    if (currentStreak < 7) return '$currentStreak Days';
    if (currentStreak < 30) return '${(currentStreak / 7).ceil()} Weeks';
    return '${(currentStreak / 30).ceil()} Months';
  }

  /// Get streak display text
  String get streakDisplayText {
    if (currentStreak == 0) return 'Start your streak!';
    if (currentStreak == 1) return '1 day streak 🔥';
    if (currentStreak < 7) return '$currentStreak day streak 🔥';
    if (currentStreak < 30) {
      return '${(currentStreak / 7).ceil()} week streak 🔥';
    }
    return '${(currentStreak / 30).ceil()} month streak 🔥';
  }

  /// Get longest streak display text
  String get longestStreakDisplayText {
    if (longestStreak == 0) return 'No record';
    if (longestStreak == 1) return '1 day';
    if (longestStreak < 7) return '$longestStreak days';
    if (longestStreak < 30) return '${(longestStreak / 7).ceil()} weeks';
    return '${(longestStreak / 30).ceil()} months';
  }

  /// Check if streak is active
  bool get isActive {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
        lastActivityDate!.year, lastActivityDate!.month, lastActivityDate!.day);
    return today.difference(lastActivity).inDays <= 1;
  }

  /// Check if streak is broken
  bool get isBroken {
    if (lastActivityDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
        lastActivityDate!.year, lastActivityDate!.month, lastActivityDate!.day);
    return today.difference(lastActivity).inDays > 1;
  }

  /// Get days since last activity
  int get daysSinceLastActivity {
    if (lastActivityDate == null) return 999; // Large number for no activity
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
        lastActivityDate!.year, lastActivityDate!.month, lastActivityDate!.day);
    return today.difference(lastActivity).inDays;
  }

  /// Get days since last activity display text
  String get daysSinceLastActivityDisplayText {
    final days = daysSinceLastActivity;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).ceil()} weeks ago';
    return '${(days / 30).ceil()} months ago';
  }

  /// Get next milestone
  String get nextMilestone {
    if (currentStreak == 0) return '1 day';
    if (currentStreak < 7) return '7 days (1 week)';
    if (currentStreak < 30) return '30 days (1 month)';
    if (currentStreak < 100) return '100 days';
    if (currentStreak < 365) return '365 days (1 year)';
    return 'Keep going!';
  }

  /// Get next milestone progress
  double get nextMilestoneProgress {
    if (currentStreak == 0) return 0.0;
    if (currentStreak < 7) return currentStreak / 7.0;
    if (currentStreak < 30) return currentStreak / 30.0;
    if (currentStreak < 100) return currentStreak / 100.0;
    if (currentStreak < 365) return currentStreak / 365.0;
    return 1.0;
  }

  /// Get streak level
  String get streakLevel {
    if (currentStreak == 0) return 'Beginner';
    if (currentStreak < 7) return 'Novice';
    if (currentStreak < 30) return 'Intermediate';
    if (currentStreak < 100) return 'Advanced';
    if (currentStreak < 365) return 'Expert';
    return 'Master';
  }

  /// Get streak level emoji
  String get streakLevelEmoji {
    switch (streakLevel) {
      case 'Beginner':
        return '🌱';
      case 'Novice':
        return '🔥';
      case 'Intermediate':
        return '⚡';
      case 'Advanced':
        return '💎';
      case 'Expert':
        return '👑';
      case 'Master':
        return '🏆';
      default:
        return '🎯';
    }
  }

  /// Get streak motivation message
  String get motivationMessage {
    if (currentStreak == 0) return 'Start your journey today! 🌟';
    if (currentStreak == 1) return 'Great start! Keep it going! 💪';
    if (currentStreak < 7) return 'You\'re building momentum! 🚀';
    if (currentStreak < 30) return 'Amazing consistency! 🔥';
    if (currentStreak < 100) return 'You\'re unstoppable! ⚡';
    if (currentStreak < 365) return 'Legendary dedication! 👑';
    return 'You\'re a true master! 🏆';
  }

  /// Get streak warning message
  String get warningMessage {
    final days = daysSinceLastActivity;
    if (days == 1) return 'Don\'t break your streak! Keep going! 💪';
    if (days == 2) return 'Your streak is at risk! Get back on track! ⚠️';
    if (days >= 3) {
      return 'Your streak has been broken. Time to start fresh! 🔄';
    }
    return '';
  }

  /// Check if streak needs attention
  bool get needsAttention {
    final days = daysSinceLastActivity;
    return days >= 1 && currentStreak > 0;
  }

  /// Get streak color
  String get streakColor {
    if (currentStreak == 0) return 'gray';
    if (currentStreak < 7) return 'orange';
    if (currentStreak < 30) return 'blue';
    if (currentStreak < 100) return 'purple';
    if (currentStreak < 365) return 'gold';
    return 'rainbow';
  }

  /// Get streak intensity
  String get streakIntensity {
    if (currentStreak == 0) return 'Cold';
    if (currentStreak < 7) return 'Warm';
    if (currentStreak < 30) return 'Hot';
    if (currentStreak < 100) return 'Blazing';
    if (currentStreak < 365) return 'Inferno';
    return 'Legendary';
  }

  /// Get streak intensity emoji
  String get streakIntensityEmoji {
    switch (streakIntensity) {
      case 'Cold':
        return '❄️';
      case 'Warm':
        return '🔥';
      case 'Hot':
        return '🔥🔥';
      case 'Blazing':
        return '🔥🔥🔥';
      case 'Inferno':
        return '🔥🔥🔥🔥';
      case 'Legendary':
        return '🔥🔥🔥🔥🔥';
      default:
        return '🔥';
    }
  }

  /// Update streak with new activity
  UserStreak updateWithActivity(DateTime activityDate) {
    final now = DateTime.now();
    // final today = DateTime(now.year, now.month, now.day); // TODO: Use this for streak logic
    final activityDay =
        DateTime(activityDate.year, activityDate.month, activityDate.day);

    // If no previous activity, start streak at 1
    if (lastActivityDate == null) {
      return copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastActivityDate: activityDate,
        updatedAt: now,
      );
    }

    final lastActivity = DateTime(
        lastActivityDate!.year, lastActivityDate!.month, lastActivityDate!.day);
    final daysDifference = activityDay.difference(lastActivity).inDays;

    // If activity is on the same day, don't change streak
    if (daysDifference == 0) {
      return copyWith(updatedAt: now);
    }

    // If activity is the next day, increment streak
    if (daysDifference == 1) {
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastActivityDate: activityDate,
        updatedAt: now,
      );
    }

    // If there's a gap, reset streak to 1
    return copyWith(
      currentStreak: 1,
      longestStreak: 1 > longestStreak ? 1 : longestStreak,
      lastActivityDate: activityDate,
      updatedAt: now,
    );
  }

  /// Reset streak
  UserStreak reset() {
    final now = DateTime.now();
    return copyWith(
      currentStreak: 0,
      lastActivityDate: null,
      updatedAt: now,
    );
  }

  /// Get streak statistics
  Map<String, dynamic> get statistics {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'streak_status': streakStatus,
      'streak_level': streakLevel,
      'streak_intensity': streakIntensity,
      'is_active': isActive,
      'is_broken': isBroken,
      'days_since_last_activity': daysSinceLastActivity,
      'next_milestone': nextMilestone,
      'next_milestone_progress': nextMilestoneProgress,
    };
  }

  /// Validate streak data
  bool get isValid {
    return currentStreak >= 0 &&
        longestStreak >= 0 &&
        currentStreak <= longestStreak &&
        ['workouts', 'meditation', 'mood_logging', 'nutrition_logging']
            .contains(category);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (currentStreak < 0) {
      errors.add('Current streak cannot be negative');
    }

    if (longestStreak < 0) {
      errors.add('Longest streak cannot be negative');
    }

    if (currentStreak > longestStreak) {
      errors.add('Current streak cannot be greater than longest streak');
    }

    if (!['workouts', 'meditation', 'mood_logging', 'nutrition_logging']
        .contains(category)) {
      errors.add('Invalid category');
    }

    return errors;
  }

  @override
  String toString() {
    return 'UserStreak(id: $id, category: $category, current: $currentStreak, longest: $longestStreak, status: $streakStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStreak && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
