import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Client for TruResetX Blade API
class BladeApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Configure your Blade base URL here or via Remote Config in future
  final String baseUrl;

  BladeApiService({required this.baseUrl});

  Future<Map<String, dynamic>> coach({
    required String message,
    String? goal,
    int? currentWeight,
    int? mood,
  }) async {
    final token = await _requireIdToken();
    final uri = Uri.parse('$baseUrl/ai/coach');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
        'goal': goal,
        'currentWeight': currentWeight,
        'mood': mood,
      }),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Blade coach failed: ${res.statusCode} ${res.body}');
  }

  Future<void> ingest({required String type, required Map<String, dynamic> payload}) async {
    final token = await _requireIdToken();
    final uri = Uri.parse('$baseUrl/progress/ingest');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'type': type, 'payload': payload}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Blade ingest failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<String> _requireIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('BladeApiService: no authenticated user');
    }
    return await user.getIdToken();
  }
}


