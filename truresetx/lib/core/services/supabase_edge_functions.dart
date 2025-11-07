import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

/// Service for interacting with Supabase Edge Functions
class SupabaseEdgeFunctionsService {
  SupabaseEdgeFunctionsService._();
  static SupabaseEdgeFunctionsService? _instance;
  static SupabaseEdgeFunctionsService get instance =>
      _instance ??= SupabaseEdgeFunctionsService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final http.Client _client = http.Client();
  RealtimeChannel? _moodChannel;

  String get _baseUrl => '${Environment.supabaseUrl}/functions/v1';
  String get _accessToken => _supabase.auth.currentSession?.accessToken ?? '';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      };

  /// Food Search - Search foods (local cache → USDA if miss)
  Future<Map<String, dynamic>> searchFoods({
    required String query,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/food-search?q=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Food search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching foods: $e');
      rethrow;
    }
  }

  /// Food Scan - Scan barcode or analyze dish photo
  Future<Map<String, dynamic>> scanFood({
    String? imageUrl,
    String? barcode,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (barcode != null) body['barcode'] = barcode;
      if (notes != null) body['notes'] = notes;

      final response = await _client.post(
        Uri.parse('$_baseUrl/food-scan'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Food scan failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error scanning food: $e');
      rethrow;
    }
  }

  /// Food Log - Log a food with quantity & overrides
  Future<Map<String, dynamic>> logFood({
    required Map<String, dynamic> foodData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/food-log'),
        headers: _headers,
        body: json.encode(foodData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Food logging failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error logging food: $e');
      rethrow;
    }
  }

  /// Log a detected food (from realtime device detection)
  Future<Map<String, dynamic>> logDetectedFood(
      Map<String, dynamic> detected) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/food-detected'),
        headers: _headers,
        body: json.encode(detected),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Detected food logging failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error logging detected food: $e');
      rethrow;
    }
  }

  /// Food Manual - Create a custom food item
  Future<Map<String, dynamic>> createManualFood({
    required Map<String, dynamic> foodData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/food-manual'),
        headers: _headers,
        body: json.encode(foodData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Manual food creation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating manual food: $e');
      rethrow;
    }
  }

  /// Food Day - Get daily nutrition totals & logs
  Future<Map<String, dynamic>> getDailyNutrition({
    String? date,
  }) async {
    try {
      final queryParams = date != null ? '?date=$date' : '';
      final response = await _client.get(
        Uri.parse('$_baseUrl/food-day$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Daily nutrition fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily nutrition: $e');
      rethrow;
    }
  }

  /// Exercises - List exercises (optionally filter by muscle)
  Future<Map<String, dynamic>> getExercises({
    String? muscle,
  }) async {
    try {
      final queryParams = muscle != null ? '?muscle=$muscle' : '';
      final response = await _client.get(
        Uri.parse('$_baseUrl/exercises$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Exercises fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exercises: $e');
      rethrow;
    }
  }

  /// Workouts Today - Get today's workout plan for the user
  Future<Map<String, dynamic>> getTodaysWorkout() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/workouts-today'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Today\'s workout fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching today\'s workout: $e');
      rethrow;
    }
  }

  /// Workouts Start Set - Begin a set; returns AR targets/tempo
  Future<Map<String, dynamic>> startWorkoutSet({
    required Map<String, dynamic> setData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/workouts-start-set'),
        headers: _headers,
        body: json.encode(setData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Start workout set failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error starting workout set: $e');
      rethrow;
    }
  }

  /// Workouts Rep - Submit per-rep metrics from on-device CV
  Future<Map<String, dynamic>> submitRepMetrics({
    required Map<String, dynamic> repData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/workouts-rep'),
        headers: _headers,
        body: json.encode(repData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Rep metrics submission failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting rep metrics: $e');
      rethrow;
    }
  }

  /// Workouts End Set - End set; aggregates scores and suggestions
  Future<Map<String, dynamic>> endWorkoutSet({
    required Map<String, dynamic> setData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/workouts-end-set'),
        headers: _headers,
        body: json.encode(setData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('End workout set failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error ending workout set: $e');
      rethrow;
    }
  }

  /// Mood WHO-5 - Get WHO-5 items
  Future<Map<String, dynamic>> getWho5Items() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/mood-who5'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('WHO-5 items fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching WHO-5 items: $e');
      rethrow;
    }
  }

  /// Mood WHO-5 Submit - Submit WHO-5 answers for a date
  Future<Map<String, dynamic>> submitWho5Answers({
    required Map<String, dynamic> answers,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/mood-who5'),
        headers: _headers,
        body: json.encode(answers),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('WHO-5 submission failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting WHO-5 answers: $e');
      rethrow;
    }
  }

  /// Mood Summary - Weekly mood summary & recommendations
  Future<Map<String, dynamic>> getMoodSummary({
    String? week,
  }) async {
    try {
      final queryParams = week != null ? '?week=$week' : '';
      final response = await _client.get(
        Uri.parse('$_baseUrl/mood-summary$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Mood summary fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching mood summary: $e');
      rethrow;
    }
  }

  /// Spiritual Gita Verse - Fetch a Gita verse by chapter/verse
  Future<Map<String, dynamic>> getGitaVerse({
    required int chapter,
    required int verse,
    String language = 'en',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '$_baseUrl/spiritual-gita-verse?chapter=$chapter&verse=$verse&lang=$language'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gita verse fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Gita verse: $e');
      rethrow;
    }
  }

  /// Wisdom Daily - Daily wisdom item
  Future<Map<String, dynamic>> getDailyWisdom() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/wisdom-daily'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Daily wisdom fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily wisdom: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }

  /// Subscribe to realtime mood_logs for a given user. Returns a Stream that
  /// emits raw realtime payloads from Supabase. The stream closes/unsubscribes
  /// when the listener cancels the subscription.
  Stream<dynamic> subscribeToMoodLogs(String userId) {
    final controller = StreamController<dynamic>();

    try {
      _moodChannel = _supabase.channel('user:mood_logs:$userId');

      _moodChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'mood_logs',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              try {
                controller.add(payload);
              } catch (e) {
                // ignore
              }
            },
          )
          .subscribe();
    } catch (e) {
      // If realtime subscription cannot be created, expose the error via the
      // controller so callers can handle it.
      controller.addError(e);
    }

    controller.onCancel = () {
      try {
        _moodChannel?.unsubscribe();
        _moodChannel = null;
      } catch (_) {}
    };

    return controller.stream;
  }

  /// Optional: explicit unsubscribe helper
  void unsubscribeFromMoodLogs(String userId) {
    try {
      _moodChannel?.unsubscribe();
      _moodChannel = null;
    } catch (_) {}
  }
}

/// Provider for SupabaseEdgeFunctionsService
final supabaseEdgeFunctionsProvider =
    Provider<SupabaseEdgeFunctionsService>((ref) {
  return SupabaseEdgeFunctionsService.instance;
});
