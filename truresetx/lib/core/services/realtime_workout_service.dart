import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Helper service to sync AR workout set/session/reps with Supabase realtime.
class RealtimeWorkoutService {
  RealtimeWorkoutService._();
  static RealtimeWorkoutService? _instance;
  static RealtimeWorkoutService get instance =>
      _instance ??= RealtimeWorkoutService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Create a new live session in Supabase and return the session id (uuid).
  /// If Supabase or insert fails, returns null.
  Future<String?> createSession(
      {String? userId, required String exerciseName}) async {
    try {
      final resp = await _client
          .from('sessions')
          .insert({
            'user_id': userId,
            'exercise_name': exerciseName,
            'current_rep': 0,
            'last_form_score': 100.0,
            'last_errors': <String>[],
            'status': 'active',
          })
          .select()
          .single();

      final map = resp as Map<String, dynamic>?;
      if (map != null && map['id'] != null) {
        return map['id'].toString();
      }
    } catch (e) {
      // ignore errors in offline / no-supabase scenarios
      debugPrint('createSession failed: $e');
    }
    return null;
  }

  /// Subscribe to session changes. Emits the payload.newRecord (map) when rows
  /// change for the provided session id. Caller must cancel the returned
  /// subscription when done.
  Stream<Map<String, dynamic>> subscribeToSession(String sessionId) {
    // Use Supabase realtime channel for sessions
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      final channel = _client
          .channel('session:$sessionId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'sessions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: sessionId,
            ),
            callback: (payload) {
              try {
                final map = Map<String, dynamic>.from(payload.newRecord);
                controller.add(map);
              } catch (e) {
                debugPrint('subscribeToSession callback error: $e');
              }
            },
          )
          .subscribe();

      controller.onCancel = () async {
        try {
          await channel.unsubscribe();
        } catch (_) {}
      };
    } catch (e) {
      controller.addError(e);
    }

    return controller.stream;
  }

  /// Push rep data to the backend: insert into reps and update session summary.
  Future<void> pushRepData({
    required String sessionId,
    required int repNo,
    required double formScore,
    required List<String> errors,
  }) async {
    try {
      await _client.from('reps').insert({
        'session_id': sessionId,
        'rep_no': repNo,
        'form_score': formScore,
        'errors': errors,
      });

      await _client.from('sessions').update({
        'current_rep': repNo,
        'last_form_score': formScore,
        'last_errors': errors,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);
    } catch (e) {
      debugPrint('pushRepData failed: $e');
    }
  }

  /// Update set status (upsert into sets table)
  Future<void> updateSetStatus(
      String sessionId, int setNo, bool completed) async {
    try {
      await _client.from('sets').upsert({
        'session_id': sessionId,
        'set_no': setNo,
        'completed': completed,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('updateSetStatus failed: $e');
    }
  }
}
