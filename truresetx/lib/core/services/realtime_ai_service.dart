import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/models/chat_message.dart';

/// Real-time AI Service with streaming capabilities
class RealtimeAIService {
  RealtimeAIService({required String apiKey}) : _apiKey = apiKey;
  final String _apiKey;
  final String _baseUrl = 'https://api.openai.com/v1';
  final http.Client _client = http.Client();

  // Stream controllers for real-time updates
  final StreamController<ChatMessage> _messageStreamController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<String> _typingStreamController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _actionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of incoming messages
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  /// Expose controller to publish messages from external services
  StreamController<ChatMessage> get messageStreamController =>
      _messageStreamController;

  /// Stream of typing indicators
  Stream<String> get typingStream => _typingStreamController.stream;

  /// Stream of AI actions
  Stream<Map<String, dynamic>> get actionStream =>
      _actionStreamController.stream;

  /// Send message with real-time streaming response
  Future<void> sendMessage({
    required String userId,
    required String message,
    required String persona,
    String? sessionId,
  }) async {
    try {
      // Add user message to stream
      final userMessage = ChatMessage.create(
        userId: userId,
        role: 'user',
        message: message,
        persona: persona,
        sessionId: sessionId,
      );
      _messageStreamController.add(userMessage);

      // Start typing indicator
      _typingStreamController.add(persona);

      // Get streaming AI response
      await _getStreamingResponse(
        userId: userId,
        message: message,
        persona: persona,
        sessionId: sessionId,
      );
    } catch (e) {
      // Send error message
      final errorMessage = ChatMessage.create(
        userId: userId,
        role: 'assistant',
        message: 'I apologize, but I encountered an error. Please try again.',
        persona: persona,
        sessionId: sessionId,
      );
      _messageStreamController.add(errorMessage);
    }
  }

  /// Get streaming AI response
  Future<void> _getStreamingResponse({
    required String userId,
    required String message,
    required String persona,
    String? sessionId,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content': _buildSystemPrompt(persona),
      },
      {
        'role': 'user',
        'content': message,
      }
    ];

    final requestBody = {
      'model': 'gpt-4',
      'messages': messages,
      'temperature': 0.7,
      'stream': true,
    };

    try {
      final request =
          http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });
      request.body = jsonEncode(requestBody);

      final streamedResponse = await _client.send(request);
      String fullResponse = '';

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              // Stop typing indicator
              _typingStreamController.add('');
              return;
            }

            try {
              final json = jsonDecode(data);
              final delta = json['choices'][0]['delta'];
              if (delta['content'] != null) {
                final content = delta['content'];
                fullResponse += content;

                // Send partial response for real-time display
                _messageStreamController.add(ChatMessage.create(
                  userId: userId,
                  role: 'assistant',
                  message: fullResponse,
                  persona: persona,
                  sessionId: sessionId,
                  isPartial: true,
                ));
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      // Stop typing indicator on error
      _typingStreamController.add('');
      rethrow;
    }
  }

  /// Build system prompt based on persona
  String _buildSystemPrompt(String persona) {
    switch (persona) {
      case 'astra':
        return '''You are Astra, a fitness and wellness coach 💪

Your expertise:
- Workout planning and form guidance
- Exercise technique and safety
- Fitness goal setting and tracking
- Motivation and accountability
- Injury prevention and recovery

Personality:
- Encouraging and supportive
- Knowledgeable about fitness science
- Focused on safe, effective training
- Motivational but realistic

Always prioritize user safety and provide evidence-based fitness advice.''';

      case 'sage':
        return '''You are Sage, a mindfulness and mental wellness mentor 🧘

Your expertise:
- Meditation and mindfulness practices
- Stress management and anxiety relief
- Mental health support and guidance
- Emotional regulation techniques
- Spiritual growth and self-discovery

Personality:
- Calm and compassionate
- Wise and insightful
- Patient and understanding
- Supportive of mental wellness

Always provide gentle, supportive guidance for mental and emotional wellbeing.''';

      case 'fuel':
        return '''You are Fuel, a nutrition and dietary expert 🍎

Your expertise:
- Nutrition science and meal planning
- Macro and micronutrient guidance
- Healthy eating habits and recipes
- Dietary restrictions and preferences
- Weight management and body composition

Personality:
- Knowledgeable about nutrition
- Practical and actionable advice
- Supportive of healthy relationships with food
- Evidence-based recommendations

Always provide balanced, sustainable nutrition advice.''';

      default:
        return '''You are a general wellness AI assistant 🤖

Your expertise:
- Holistic wellness guidance
- General health and fitness advice
- Motivation and support
- Goal setting and tracking
- Lifestyle optimization

Personality:
- Helpful and supportive
- Knowledgeable across wellness domains
- Encouraging and positive
- Practical and actionable

Provide comprehensive wellness support across all areas of health and wellbeing.''';
    }
  }

  /// Send quick action (predefined responses)
  Future<void> sendQuickAction({
    required String userId,
    required String action,
    required String persona,
    String? sessionId,
  }) async {
    final actionMessages = {
      'workout_plan':
          'I\'d be happy to help you create a workout plan! What are your fitness goals and how much time do you have available?',
      'nutrition_advice':
          'I\'m here to help with your nutrition! What specific dietary questions or goals do you have?',
      'meditation_guide':
          'I\'d love to guide you through meditation! What type of meditation are you interested in, and how much time do you have?',
      'stress_help':
          'I\'m here to help you manage stress. What\'s currently causing you the most stress, and how can I support you?',
      'motivation':
          'I\'m here to motivate and support you! What are you working towards, and how can I help you stay on track?',
    };

    final message = actionMessages[action] ?? 'How can I help you today?';

    final aiMessage = ChatMessage.create(
      userId: userId,
      role: 'assistant',
      message: message,
      persona: persona,
      sessionId: sessionId,
    );

    _messageStreamController.add(aiMessage);
  }

  /// Send AI action (tool execution)
  Future<void> sendAIAction({
    required String userId,
    required String actionType,
    required Map<String, dynamic> parameters,
    required String persona,
    String? sessionId,
  }) async {
    // Emit action to stream
    _actionStreamController.add({
      'type': actionType,
      'parameters': parameters,
      'persona': persona,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Send confirmation message
    final confirmationMessage = ChatMessage.create(
      userId: userId,
      role: 'assistant',
      message: _getActionConfirmation(actionType, parameters),
      persona: persona,
      sessionId: sessionId,
    );

    _messageStreamController.add(confirmationMessage);
  }

  String _getActionConfirmation(
      String actionType, Map<String, dynamic> parameters) {
    switch (actionType) {
      case 'create_workout':
        return 'I\'ve created a personalized workout plan for you! Check your workout tab to see the details.';
      case 'analyze_nutrition':
        return 'I\'ve analyzed your nutrition data and provided recommendations. Check your nutrition tab for insights.';
      case 'schedule_meditation':
        return 'I\'ve scheduled a meditation session for you. Check your spiritual tab to start your practice.';
      case 'mood_check':
        return 'I\'ve scheduled a mood check-in for you. Take a moment to reflect on how you\'re feeling.';
      default:
        return 'I\'ve processed your request and will help you with that.';
    }
  }

  /// Get conversation history
  Future<List<ChatMessage>> getConversationHistory({
    required String userId,
    String? sessionId,
    int limit = 50,
  }) async {
    // In a real implementation, this would fetch from database
    // For now, return empty list
    return [];
  }

  /// Save conversation to database
  Future<void> saveConversation({
    required String userId,
    required List<ChatMessage> messages,
    String? sessionId,
  }) async {
    // In a real implementation, this would save to database
    // For now, just print for debugging
    print('Saving conversation with ${messages.length} messages');
  }

  /// Clear conversation history
  Future<void> clearConversation({
    required String userId,
    String? sessionId,
  }) async {
    // In a real implementation, this would clear from database
    print('Clearing conversation history');
  }

  /// Dispose resources
  void dispose() {
    _messageStreamController.close();
    _typingStreamController.close();
    _actionStreamController.close();
    _client.close();
  }
}

/// Provider for Realtime AI Service
final realtimeAIServiceProvider = Provider<RealtimeAIService>((ref) {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY',
      defaultValue: 'your-api-key-here');
  return RealtimeAIService(apiKey: apiKey);
});

/// Extension to add isPartial field to ChatMessage
extension ChatMessageExtension on ChatMessage {
  static ChatMessage create({
    required String userId,
    required String role,
    required String message,
    String? persona,
    String? sessionId,
    bool isPartial = false,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      role: role,
      message: message,
      persona: persona,
      sessionId: sessionId,
      createdAt: DateTime.now(),
    );
  }
}
