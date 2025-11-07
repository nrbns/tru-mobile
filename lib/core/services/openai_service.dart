import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Small wrapper for OpenAI HTTP API using the API key from dotenv
class OpenAIService {
  OpenAIService();

  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];

  /// Perform a chat completion (gpt-3.5-turbo style)
  Future<Map<String, dynamic>> chatCompletion(
    String prompt, {
    String model = 'gpt-3.5-turbo',
    int maxTokens = 500,
  }) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set. Add it to your .env file.');
    }

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = {
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': maxTokens,
    };

    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }

    throw Exception(
        'OpenAI API request failed (${resp.statusCode}): ${resp.body}');
  }

  /// Convenience method to return the assistant text output
  Future<String> generateText(String prompt) async {
    final result = await chatCompletion(prompt);
    final choices = result['choices'] as List<dynamic>?;
    if (choices != null && choices.isNotEmpty) {
      final message = choices[0]['message'] as Map<String, dynamic>?;
      if (message != null) return message['content'] as String? ?? '';
    }
    return '';
  }
}
