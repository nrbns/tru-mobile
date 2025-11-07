import 'package:uuid/uuid.dart';

/// User Goal model for TruResetX v1.0
class UserGoal {

  UserGoal({
    required this.id,
    required this.userId,
    required this.category,
    required this.goalText,
    this.targetValue,
    this.currentValue = 0,
    this.unit,
    this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  /// Create a new user goal
  factory UserGoal.create({
    required String userId,
    required String category,
    required String goalText,
    double? targetValue,
    String? unit,
    DateTime? targetDate,
  }) {
    return UserGoal(
      id: const Uuid().v4(),
      userId: userId,
      category: category,
      goalText: goalText,
      targetValue: targetValue,
      unit: unit,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      goalText: json['goal_text'],
      targetValue: json['target_value']?.toDouble(),
      currentValue: json['current_value']?.toDouble() ?? 0,
      unit: json['unit'],
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date']) : null,
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
  final String id;
  final String userId;
  final String category;
  final String goalText;
  final double? targetValue;
  final double currentValue;
  final String? unit;
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'goal_text': goalText,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'target_date': targetDate?.toIso8601String().split('T')[0],
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Copy with new values
  UserGoal copyWith({
    String? id,
    String? userId,
    String? category,
    String? goalText,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return UserGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      goalText: goalText ?? this.goalText,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'fitness':
        return 'Fitness';
      case 'nutrition':
        return 'Nutrition';
      case 'mental_health':
        return 'Mental Health';
      case 'spiritual':
        return 'Spiritual';
      case 'sleep':
        return 'Sleep';
      default:
        return category;
    }
  }

  /// Get category emoji
  String get categoryEmoji {
    switch (category) {
      case 'fitness':
        return '💪';
      case 'nutrition':
        return '🍎';
      case 'mental_health':
        return '🧠';
      case 'spiritual':
        return '🧘';
      case 'sleep':
        return '😴';
      default:
        return '🎯';
    }
  }

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (targetValue == null || targetValue == 0) return 0;
    final progress = (currentValue / targetValue!) * 100;
    return progress.clamp(0, 100);
  }

  /// Get progress display text
  String get progressDisplayText {
    if (targetValue == null) return '${currentValue.toStringAsFixed(1)} ${unit ?? ''}';
    return '${currentValue.toStringAsFixed(1)} / ${targetValue!.toStringAsFixed(1)} ${unit ?? ''}';
  }

  /// Get progress bar text
  String get progressBarText => '${progressPercentage.toInt()}%';

  /// Check if goal is on track
  bool get isOnTrack {
    if (targetDate == null || targetValue == null) return true;
    
    final now = DateTime.now();
    final daysSinceStart = now.difference(createdAt).inDays;
    final totalDays = targetDate!.difference(createdAt).inDays;
    
    if (totalDays <= 0) return isCompleted;
    
    final expectedProgress = (daysSinceStart / totalDays) * targetValue!;
    return currentValue >= expectedProgress * 0.8; // 80% tolerance
  }

  /// Check if goal is overdue
  bool get isOverdue {
    if (targetDate == null || isCompleted) return false;
    return DateTime.now().isAfter(targetDate!);
  }

  /// Get days remaining
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(targetDate!)) return 0;
    return targetDate!.difference(now).inDays;
  }

  /// Get days remaining display text
  String get daysRemainingDisplayText {
    final days = daysRemaining;
    if (days == null) return 'No deadline';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    if (days < 7) return '$days days left';
    if (days < 30) return '${(days / 7).ceil()} weeks left';
    return '${(days / 30).ceil()} months left';
  }

  /// Get goal status
  String get status {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (!isOnTrack) return 'Behind';
    return 'On Track';
  }

  /// Get status emoji
  String get statusEmoji {
    switch (status) {
      case 'Completed':
        return '✅';
      case 'Overdue':
        return '⚠️';
      case 'Behind':
        return '📉';
      case 'On Track':
        return '📈';
      default:
        return '🎯';
    }
  }

  /// Get goal priority
  String get priority {
    if (isOverdue) return 'High';
    if (!isOnTrack) return 'Medium';
    final days = daysRemaining;
    if (days != null && days <= 7) return 'High';
    if (days != null && days <= 30) return 'Medium';
    return 'Low';
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case 'High':
        return 'red';
      case 'Medium':
        return 'orange';
      case 'Low':
        return 'green';
      default:
        return 'blue';
    }
  }

  /// Get motivation message
  String get motivationMessage {
    if (isCompleted) return 'Great job! You achieved your goal! 🎉';
    
    if (isOverdue) return 'You\'re behind schedule, but you can still catch up! 💪';
    
    if (!isOnTrack) return 'Keep pushing forward! Every step counts! 🚀';
    
    final progress = progressPercentage;
    if (progress >= 75) return 'You\'re almost there! Finish strong! 🔥';
    if (progress >= 50) return 'You\'re halfway there! Keep going! 💪';
    if (progress >= 25) return 'Great start! You\'re making progress! 🌟';
    
    return 'Every journey begins with a single step! 🚀';
  }

  /// Get next milestone
  String? get nextMilestone {
    if (targetValue == null) return null;
    
    final milestones = [0.25, 0.5, 0.75, 1.0];
    for (final milestone in milestones) {
      final target = targetValue! * milestone;
      if (currentValue < target) {
        return '${(target).toStringAsFixed(1)} ${unit ?? ''}';
      }
    }
    
    return null;
  }

  /// Get estimated completion date
  DateTime? get estimatedCompletionDate {
    if (targetValue == null || currentValue == 0) return null;
    
    final progress = currentValue / targetValue!;
    if (progress >= 1.0) return DateTime.now();
    
    final daysSinceStart = DateTime.now().difference(createdAt).inDays;
    final estimatedTotalDays = (daysSinceStart / progress).round();
    final estimatedCompletion = createdAt.add(Duration(days: estimatedTotalDays));
    
    return estimatedCompletion;
  }

  /// Check if goal is achievable
  bool get isAchievable {
    if (targetDate == null || targetValue == null) return true;
    
    final daysSinceStart = DateTime.now().difference(createdAt).inDays;
    final daysRemaining = targetDate!.difference(DateTime.now()).inDays;
    
    if (daysRemaining <= 0) return isCompleted;
    
    final remainingValue = targetValue! - currentValue;
    final dailyRequired = remainingValue / daysRemaining;
    
    // Check if daily requirement is reasonable (not more than 10x current daily average)
    final currentDailyAverage = currentValue / (daysSinceStart + 1);
    return dailyRequired <= currentDailyAverage * 10;
  }

  /// Get difficulty level
  String get difficultyLevel {
    if (targetValue == null) return 'Unknown';
    
    final progress = currentValue / targetValue!;
    if (progress >= 0.8) return 'Easy';
    if (progress >= 0.5) return 'Medium';
    if (progress >= 0.2) return 'Hard';
    return 'Very Hard';
  }

  /// Get difficulty emoji
  String get difficultyEmoji {
    switch (difficultyLevel) {
      case 'Easy':
        return '😊';
      case 'Medium':
        return '😐';
      case 'Hard':
        return '😅';
      case 'Very Hard':
        return '😰';
      default:
        return '❓';
    }
  }

  /// Update progress
  UserGoal updateProgress(double newValue) {
    return copyWith(
      currentValue: newValue,
      isCompleted: targetValue != null && newValue >= targetValue!,
      completedAt: targetValue != null && newValue >= targetValue! ? DateTime.now() : null,
    );
  }

  /// Complete goal
  UserGoal complete() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      currentValue: targetValue ?? currentValue,
    );
  }

  /// Reset goal
  UserGoal reset() {
    return copyWith(
      currentValue: 0,
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Validate goal data
  bool get isValid {
    return goalText.trim().isNotEmpty &&
           ['fitness', 'nutrition', 'mental_health', 'spiritual', 'sleep'].contains(category) &&
           (targetValue == null || targetValue! > 0) &&
           currentValue >= 0 &&
           (targetDate == null || targetDate!.isAfter(createdAt));
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (goalText.trim().isEmpty) {
      errors.add('Goal text cannot be empty');
    }
    
    if (!['fitness', 'nutrition', 'mental_health', 'spiritual', 'sleep'].contains(category)) {
      errors.add('Invalid category');
    }
    
    if (targetValue != null && targetValue! <= 0) {
      errors.add('Target value must be greater than 0');
    }
    
    if (currentValue < 0) {
      errors.add('Current value cannot be negative');
    }
    
    if (targetDate != null && targetDate!.isBefore(createdAt)) {
      errors.add('Target date cannot be in the past');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'UserGoal(id: $id, category: $category, goal: $goalText, progress: ${progressPercentage.toInt()}%, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserGoal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
