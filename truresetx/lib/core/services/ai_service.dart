import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// AI Service for handling OpenAI API calls and tool-calling
class AIService {
  AIService({required String apiKey}) : _apiKey = apiKey;
  final String _apiKey;
  final String _baseUrl = 'https://api.openai.com/v1';
  final http.Client _client = http.Client();

  /// Chat completion with tool calling support
  Future<String> chatCompletion(
    String prompt, {
    List<Map<String, dynamic>>? tools,
    Map<String, dynamic>? toolChoice,
    String model = 'gpt-4',
    double temperature = 0.7,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            '''You are the TruResetX AI Assistant. You help users with their holistic wellness journey including:
        - Workout planning and form coaching
        - Nutrition guidance and meal planning
        - Mood tracking and mental health support
        - Spiritual growth and meditation guidance
        - Community accountability and motivation
        
        Always prioritize user safety, provide evidence-based recommendations, and maintain a supportive, encouraging tone.'''
      },
      {
        'role': 'user',
        'content': prompt,
      }
    ];

    final requestBody = {
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': 2000,
      'stream': false,
    };

    if (tools != null) {
      requestBody['tools'] = tools;
    }

    if (toolChoice != null) {
      requestBody['tool_choice'] = toolChoice;
    }

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['choices'][0]['message'];

        // Check if tool calls were made
        if (message['tool_calls'] != null) {
          return await _handleToolCalls(message['tool_calls']);
        }

        return message['content'] ?? 'No response generated';
      } else {
        throw Exception(
            'API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('AI Service error: $e');
      return 'I apologize, but I encountered an error. Please try again.';
    }
  }

  /// Handle tool calls from AI
  Future<String> _handleToolCalls(List<dynamic> toolCalls) async {
    final results = <String>[];

    for (final toolCall in toolCalls) {
      final function = toolCall['function'];
      final functionName = function['name'];
      final functionArgs = jsonDecode(function['arguments']);

      try {
        final result = await _executeToolCall(functionName, functionArgs);
        results.add(result);
      } catch (e) {
        results.add('Error executing $functionName: $e');
      }
    }

    return results.join('\n');
  }

  /// Execute specific tool calls
  Future<String> _executeToolCall(
      String functionName, Map<String, dynamic> args) async {
    switch (functionName) {
      case 'create_workout_plan':
        return await _createWorkoutPlan(args);
      case 'analyze_food_nutrition':
        return await _analyzeFoodNutrition(args);
      case 'generate_meditation_script':
        return await _generateMeditationScript(args);
      case 'analyze_mood_patterns':
        return await _analyzeMoodPatterns(args);
      case 'create_community_challenge':
        return await _createCommunityChallenge(args);
      default:
        return 'Unknown tool: $functionName';
    }
  }

  /// Create workout plan tool
  Future<String> _createWorkoutPlan(Map<String, dynamic> args) async {
    // Implementation would create actual workout plan
    return 'Workout plan created successfully';
  }

  /// Analyze food nutrition tool
  Future<String> _analyzeFoodNutrition(Map<String, dynamic> args) async {
    // Implementation would analyze food nutrition
    return 'Food nutrition analyzed successfully';
  }

  /// Generate meditation script tool
  Future<String> _generateMeditationScript(Map<String, dynamic> args) async {
    // Implementation would generate meditation script
    return 'Meditation script generated successfully';
  }

  /// Analyze mood patterns tool
  Future<String> _analyzeMoodPatterns(Map<String, dynamic> args) async {
    // Implementation would analyze mood patterns
    return 'Mood patterns analyzed successfully';
  }

  /// Create community challenge tool
  Future<String> _createCommunityChallenge(Map<String, dynamic> args) async {
    // Implementation would create community challenge
    return 'Community challenge created successfully';
  }

  /// Get available tools for AI
  List<Map<String, dynamic>> getAvailableTools() {
    return [
      {
        'type': 'function',
        'function': {
          'name': 'create_workout_plan',
          'description':
              'Create a personalized workout plan based on user goals, constraints, and assessment results',
          'parameters': {
            'type': 'object',
            'properties': {
              'user_id': {'type': 'string', 'description': 'User ID'},
              'goals': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'User fitness goals'
              },
              'constraints': {
                'type': 'object',
                'description': 'Time, equipment, and physical constraints'
              },
              'assessment_summary': {
                'type': 'object',
                'description': 'Movement assessment results'
              },
              'calendar_availability': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'Available time slots'
              },
            },
            'required': ['user_id', 'goals']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'analyze_food_nutrition',
          'description':
              'Analyze food items for nutritional content and provide recommendations',
          'parameters': {
            'type': 'object',
            'properties': {
              'food_name': {
                'type': 'string',
                'description': 'Name of the food item'
              },
              'portion_size': {
                'type': 'string',
                'description': 'Portion size or serving amount'
              },
              'user_preferences': {
                'type': 'object',
                'description': 'User dietary preferences and restrictions'
              },
            },
            'required': ['food_name']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'generate_meditation_script',
          'description':
              'Generate a personalized meditation or breathwork script',
          'parameters': {
            'type': 'object',
            'properties': {
              'duration_minutes': {
                'type': 'integer',
                'description': 'Desired duration in minutes'
              },
              'type': {
                'type': 'string',
                'enum': [
                  'mindfulness',
                  'breathwork',
                  'loving_kindness',
                  'body_scan'
                ]
              },
              'user_state': {
                'type': 'object',
                'description': 'Current emotional and physical state'
              },
            },
            'required': ['duration_minutes', 'type']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'analyze_mood_patterns',
          'description': 'Analyze user mood data and provide insights',
          'parameters': {
            'type': 'object',
            'properties': {
              'user_id': {'type': 'string', 'description': 'User ID'},
              'timeframe_days': {
                'type': 'integer',
                'description': 'Number of days to analyze'
              },
              'mood_data': {
                'type': 'array',
                'description': 'Historical mood data'
              },
            },
            'required': ['user_id', 'timeframe_days']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'create_community_challenge',
          'description': 'Create a community wellness challenge',
          'parameters': {
            'type': 'object',
            'properties': {
              'challenge_type': {
                'type': 'string',
                'enum': ['fitness', 'nutrition', 'mindfulness', 'sleep']
              },
              'duration_days': {
                'type': 'integer',
                'description': 'Challenge duration'
              },
              'participants': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'User IDs of participants'
              },
              'goals': {
                'type': 'object',
                'description': 'Challenge goals and metrics'
              },
            },
            'required': ['challenge_type', 'duration_days']
          }
        }
      }
    ];
  }

  /// Stream chat completion for real-time responses
  Stream<String> streamChatCompletion(
    String prompt, {
    String model = 'gpt-4',
    double temperature = 0.7,
  }) async* {
    final messages = [
      {
        'role': 'system',
        'content':
            '''You are the TruResetX AI Assistant. Provide helpful, supportive responses for wellness coaching.'''
      },
      {
        'role': 'user',
        'content': prompt,
      }
    ];

    final requestBody = {
      'model': model,
      'messages': messages,
      'temperature': temperature,
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

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              return;
            }
            try {
              final json = jsonDecode(data);
              final delta = json['choices'][0]['delta'];
              if (delta['content'] != null) {
                yield delta['content'];
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  /// Generate embeddings for semantic search
  Future<List<double>> generateEmbedding(String text) async {
    final requestBody = {
      'model': 'text-embedding-ada-002',
      'input': text,
    };

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/embeddings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<double>.from(data['data'][0]['embedding']);
      } else {
        throw Exception('Embedding request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Embedding error: $e');
      return [];
    }
  }

  /// Chat completion that returns parsed JSON when possible.
  /// It will call [chatCompletion] and attempt to jsonDecode the result.
  Future<Map<String, dynamic>?> chatCompletionJson(String prompt,
      {String model = 'gpt-4',
      double temperature = 0.7,
      Duration? timeout}) async {
    try {
      final raw =
          await chatCompletion(prompt, model: model, temperature: temperature);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      // If the LLM returned a list or primitive, wrap in a map
      return {'value': decoded};
    } catch (e) {
      // If parse fails, return null to allow fallback behaviour
      print('chatCompletionJson parse error: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Provider for AI Service
final aiServiceProvider = Provider<AIService>((ref) {
  // In production, get API key from environment variables
  const apiKey = String.fromEnvironment('OPENAI_API_KEY',
      defaultValue: 'your-api-key-here');
  return AIService(apiKey: apiKey);
});

/// Tool call result
class ToolCallResult {
  ToolCallResult({
    required this.toolName,
    required this.arguments,
    required this.result,
    required this.success,
    this.error,
  });
  final String toolName;
  final Map<String, dynamic> arguments;
  final String result;
  final bool success;
  final String? error;
}
