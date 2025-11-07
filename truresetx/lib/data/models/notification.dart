import 'package:uuid/uuid.dart';

/// Notification model for TruResetX v1.0
class Notification {

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.scheduledTime,
    this.sentTime,
    this.isRead = false,
    this.actionUrl,
    required this.createdAt,
  });

  /// Create a new notification
  factory Notification.create({
    required String userId,
    required String title,
    required String body,
    required String type,
    DateTime? scheduledTime,
    String? actionUrl,
  }) {
    return Notification(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      body: body,
      type: type,
      scheduledTime: scheduledTime,
      actionUrl: actionUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      scheduledTime: json['scheduled_time'] != null 
          ? DateTime.parse(json['scheduled_time'])
          : null,
      sentTime: json['sent_time'] != null 
          ? DateTime.parse(json['sent_time'])
          : null,
      isRead: json['is_read'] ?? false,
      actionUrl: json['action_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final DateTime? scheduledTime;
  final DateTime? sentTime;
  final bool isRead;
  final String? actionUrl;
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'sent_time': sentTime?.toIso8601String(),
      'is_read': isRead,
      'action_url': actionUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    DateTime? scheduledTime,
    DateTime? sentTime,
    bool? isRead,
    String? actionUrl,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      sentTime: sentTime ?? this.sentTime,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case 'reminder':
        return 'Reminder';
      case 'achievement':
        return 'Achievement';
      case 'motivation':
        return 'Motivation';
      case 'system':
        return 'System';
      default:
        return type;
    }
  }

  /// Get type emoji
  String get typeEmoji {
    switch (type) {
      case 'reminder':
        return '⏰';
      case 'achievement':
        return '🏆';
      case 'motivation':
        return '💪';
      case 'system':
        return '🔔';
      default:
        return '📱';
    }
  }

  /// Check if notification is scheduled
  bool get isScheduled => scheduledTime != null && sentTime == null;

  /// Check if notification is sent
  bool get isSent => sentTime != null;

  /// Check if notification is pending
  bool get isPending => !isSent && !isRead;

  /// Check if notification is overdue
  bool get isOverdue {
    if (scheduledTime == null || isSent) return false;
    return DateTime.now().isAfter(scheduledTime!);
  }

  /// Get time until scheduled
  Duration? get timeUntilScheduled {
    if (scheduledTime == null || isSent) return null;
    return scheduledTime!.difference(DateTime.now());
  }

  /// Get time until scheduled display text
  String get timeUntilScheduledDisplayText {
    final duration = timeUntilScheduled;
    if (duration == null) return 'Not scheduled';
    
    if (duration.isNegative) return 'Overdue';
    
    if (duration.inMinutes < 1) return 'Now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m';
    if (duration.inHours < 24) return '${duration.inHours}h';
    return '${duration.inDays}d';
  }

  /// Get time since sent
  Duration? get timeSinceSent {
    if (sentTime == null) return null;
    return DateTime.now().difference(sentTime!);
  }

  /// Get time since sent display text
  String get timeSinceSentDisplayText {
    final duration = timeSinceSent;
    if (duration == null) return 'Not sent';
    
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }

  /// Get notification priority
  String get priority {
    if (type == 'achievement') return 'High';
    if (type == 'system') return 'High';
    if (type == 'reminder') return 'Medium';
    if (type == 'motivation') return 'Low';
    return 'Medium';
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case 'High':
        return 'red';
      case 'Medium':
        return 'orange';
      case 'Low':
        return 'blue';
      default:
        return 'gray';
    }
  }

  /// Get notification status
  String get status {
    if (isRead) return 'Read';
    if (isSent) return 'Sent';
    if (isOverdue) return 'Overdue';
    if (isScheduled) return 'Scheduled';
    return 'Pending';
  }

  /// Get status emoji
  String get statusEmoji {
    switch (status) {
      case 'Read':
        return '✅';
      case 'Sent':
        return '📤';
      case 'Overdue':
        return '⚠️';
      case 'Scheduled':
        return '⏰';
      case 'Pending':
        return '⏳';
      default:
        return '❓';
    }
  }

  /// Get notification category
  String get category {
    switch (type) {
      case 'reminder':
        return 'Reminders';
      case 'achievement':
        return 'Achievements';
      case 'motivation':
        return 'Motivation';
      case 'system':
        return 'System';
      default:
        return 'Other';
    }
  }

  /// Get notification importance
  String get importance {
    if (type == 'achievement') return 'Important';
    if (type == 'system') return 'Important';
    if (type == 'reminder') return 'Normal';
    if (type == 'motivation') return 'Low';
    return 'Normal';
  }

  /// Check if notification has action
  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;

  /// Get action type
  String get actionType {
    if (actionUrl == null) return 'none';
    if (actionUrl!.contains('workout')) return 'workout';
    if (actionUrl!.contains('meditation')) return 'meditation';
    if (actionUrl!.contains('nutrition')) return 'nutrition';
    if (actionUrl!.contains('mood')) return 'mood';
    if (actionUrl!.contains('profile')) return 'profile';
    return 'other';
  }

  /// Get action display text
  String get actionDisplayText {
    switch (actionType) {
      case 'workout':
        return 'Start Workout';
      case 'meditation':
        return 'Begin Meditation';
      case 'nutrition':
        return 'Log Food';
      case 'mood':
        return 'Check Mood';
      case 'profile':
        return 'View Profile';
      case 'other':
        return 'View Details';
      default:
        return 'No Action';
    }
  }

  /// Get notification preview (first 50 characters)
  String get preview {
    if (body.length <= 50) return body;
    return '${body.substring(0, 50)}...';
  }

  /// Mark as read
  Notification markAsRead() {
    return copyWith(isRead: true);
  }

  /// Mark as sent
  Notification markAsSent() {
    return copyWith(sentTime: DateTime.now());
  }

  /// Schedule notification
  Notification schedule(DateTime scheduledTime) {
    return copyWith(scheduledTime: scheduledTime);
  }

  /// Cancel notification
  Notification cancel() {
    return copyWith(scheduledTime: null);
  }

  /// Get notification data for display
  Map<String, dynamic> get displayData {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'typeDisplayName': typeDisplayName,
      'typeEmoji': typeEmoji,
      'status': status,
      'statusEmoji': statusEmoji,
      'priority': priority,
      'priorityColor': priorityColor,
      'isRead': isRead,
      'isSent': isSent,
      'isScheduled': isScheduled,
      'isOverdue': isOverdue,
      'hasAction': hasAction,
      'actionType': actionType,
      'actionDisplayText': actionDisplayText,
      'timeUntilScheduled': timeUntilScheduledDisplayText,
      'timeSinceSent': timeSinceSentDisplayText,
      'preview': preview,
    };
  }

  /// Validate notification data
  bool get isValid {
    return title.trim().isNotEmpty &&
           body.trim().isNotEmpty &&
           ['reminder', 'achievement', 'motivation', 'system'].contains(type) &&
           (scheduledTime == null || scheduledTime!.isAfter(createdAt));
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (title.trim().isEmpty) {
      errors.add('Title cannot be empty');
    }
    
    if (body.trim().isEmpty) {
      errors.add('Body cannot be empty');
    }
    
    if (!['reminder', 'achievement', 'motivation', 'system'].contains(type)) {
      errors.add('Invalid notification type');
    }
    
    if (scheduledTime != null && scheduledTime!.isBefore(createdAt)) {
      errors.add('Scheduled time cannot be in the past');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'Notification(id: $id, type: $type, title: $title, status: $status, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
