import 'package:uuid/uuid.dart';

/// Chat Message model for TruResetX v1.0 AI Coach
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.message,
    this.persona,
    this.sessionId,
    this.isPartial = false,
    required this.createdAt,
  });

  /// Create a new chat message
  factory ChatMessage.create({
    required String userId,
    required String role,
    required String message,
    String? persona,
    String? sessionId,
    bool isPartial = false,
  }) {
    return ChatMessage(
      id: const Uuid().v4(),
      userId: userId,
      role: role,
      message: message,
      persona: persona,
      sessionId: sessionId,
      isPartial: isPartial,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      userId: json['user_id'],
      role: json['role'],
      message: json['message'],
      persona: json['persona'],
      sessionId: json['session_id'],
      isPartial: json['is_partial'] == true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  final String id;
  final String userId;
  final String role;
  final String message;
  final String? persona;
  final String? sessionId;
  final bool isPartial;
  final DateTime createdAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'message': message,
      'persona': persona,
      'session_id': sessionId,
      'is_partial': isPartial,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  ChatMessage copyWith({
    String? id,
    String? userId,
    String? role,
    String? message,
    String? persona,
    String? sessionId,
    bool? isPartial,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      message: message ?? this.message,
      persona: persona ?? this.persona,
      sessionId: sessionId ?? this.sessionId,
      isPartial: isPartial ?? this.isPartial,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if message is from user
  bool get isUser => role == 'user';

  /// Check if message is from assistant
  bool get isAssistant => role == 'assistant';

  /// Check if message is from system
  bool get isSystem => role == 'system';

  /// Get persona display name
  String get personaDisplayName {
    switch (persona) {
      case 'astra':
        return 'Astra (Coach)';
      case 'sage':
        return 'Sage (Mind Mentor)';
      case 'fuel':
        return 'Fuel (Nutritionist)';
      default:
        return 'AI Assistant';
    }
  }

  /// Get persona emoji
  String get personaEmoji {
    switch (persona) {
      case 'astra':
        return '💪';
      case 'sage':
        return '🧘';
      case 'fuel':
        return '🍎';
      default:
        return '🤖';
    }
  }

  /// Get persona description
  String get personaDescription {
    switch (persona) {
      case 'astra':
        return 'Your fitness and wellness coach, focused on workouts and physical health';
      case 'sage':
        return 'Your mindfulness mentor, focused on mental health and spiritual growth';
      case 'fuel':
        return 'Your nutrition expert, focused on food, diet, and healthy eating';
      default:
        return 'Your general wellness assistant';
    }
  }

  /// Get message length
  int get messageLength => message.length;

  /// Check if message is long
  bool get isLongMessage => messageLength > 200;

  /// Check if message is short
  bool get isShortMessage => messageLength < 50;

  /// Get message preview (first 100 characters)
  String get messagePreview {
    if (messageLength <= 100) return message;
    return '${message.substring(0, 100)}...';
  }

  /// Get time display text
  String get timeDisplayText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get relative time display text
  String get relativeTimeDisplayText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';

    return '${createdAt.day}/${createdAt.month}';
  }

  /// Check if message contains workout-related keywords
  bool get isWorkoutRelated {
    final workoutKeywords = [
      'workout',
      'exercise',
      'fitness',
      'gym',
      'train',
      'strength',
      'cardio',
      'yoga',
      'pilates',
      'running',
      'cycling',
      'swimming',
      'push-up',
      'squat',
      'deadlift',
      'bench',
      'pull-up'
    ];

    final messageLower = message.toLowerCase();
    return workoutKeywords.any((keyword) => messageLower.contains(keyword));
  }

  /// Check if message contains nutrition-related keywords
  bool get isNutritionRelated {
    final nutritionKeywords = [
      'food',
      'eat',
      'diet',
      'nutrition',
      'calorie',
      'protein',
      'carb',
      'fat',
      'meal',
      'snack',
      'breakfast',
      'lunch',
      'dinner',
      'vitamin',
      'supplement',
      'water',
      'hydrate'
    ];

    final messageLower = message.toLowerCase();
    return nutritionKeywords.any((keyword) => messageLower.contains(keyword));
  }

  /// Check if message contains mental health keywords
  bool get isMentalHealthRelated {
    final mentalHealthKeywords = [
      'mood',
      'stress',
      'anxiety',
      'depression',
      'mental',
      'mind',
      'meditation',
      'mindfulness',
      'breathing',
      'relax',
      'calm',
      'sleep',
      'energy',
      'focus',
      'concentration',
      'therapy'
    ];

    final messageLower = message.toLowerCase();
    return mentalHealthKeywords
        .any((keyword) => messageLower.contains(keyword));
  }

  /// Get suggested persona based on message content
  String get suggestedPersona {
    if (isWorkoutRelated) return 'astra';
    if (isNutritionRelated) return 'fuel';
    if (isMentalHealthRelated) return 'sage';
    return 'general';
  }

  /// Check if message needs persona switch
  bool shouldSwitchPersona(String currentPersona) {
    final suggested = suggestedPersona;
    return suggested != 'general' && suggested != currentPersona;
  }

  /// Get message category
  String get messageCategory {
    if (isWorkoutRelated) return 'Workout';
    if (isNutritionRelated) return 'Nutrition';
    if (isMentalHealthRelated) return 'Mental Health';
    return 'General';
  }

  /// Check if message is a question
  bool get isQuestion => message.trim().endsWith('?');

  /// Check if message is a greeting
  bool get isGreeting {
    final greetings = [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening'
    ];
    final messageLower = message.toLowerCase().trim();
    return greetings.any((greeting) => messageLower.startsWith(greeting));
  }

  /// Check if message is a goodbye
  bool get isGoodbye {
    final goodbyes = ['bye', 'goodbye', 'see you', 'talk later', 'thanks'];
    final messageLower = message.toLowerCase().trim();
    return goodbyes.any((goodbye) => messageLower.contains(goodbye));
  }

  /// Get message sentiment (basic analysis)
  String get sentiment {
    final positiveWords = [
      'good',
      'great',
      'excellent',
      'amazing',
      'wonderful',
      'happy',
      'excited'
    ];
    final negativeWords = [
      'bad',
      'terrible',
      'awful',
      'sad',
      'angry',
      'frustrated',
      'tired'
    ];

    final messageLower = message.toLowerCase();
    final positiveCount =
        positiveWords.where((word) => messageLower.contains(word)).length;
    final negativeCount =
        negativeWords.where((word) => messageLower.contains(word)).length;

    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  /// Get sentiment emoji
  String get sentimentEmoji {
    switch (sentiment) {
      case 'positive':
        return '😊';
      case 'negative':
        return '😔';
      default:
        return '😐';
    }
  }

  /// Validate message data
  bool get isValid {
    return message.trim().isNotEmpty &&
        ['user', 'assistant', 'system'].contains(role) &&
        message.length <= 4000; // Max message length
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];

    if (message.trim().isEmpty) {
      errors.add('Message cannot be empty');
    }

    if (!['user', 'assistant', 'system'].contains(role)) {
      errors.add('Invalid role');
    }

    if (message.length > 4000) {
      errors.add('Message too long (max 4000 characters)');
    }

    if (persona != null &&
        !['astra', 'sage', 'fuel', 'general'].contains(persona)) {
      errors.add('Invalid persona');
    }

    return errors;
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, persona: $persona, message: $messagePreview, time: $timeDisplayText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
