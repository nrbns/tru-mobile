import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';
import '../services/realtime_service.dart';

class MetricsRepository {
  MetricsRepository._();
  static MetricsRepository? _instance;
  static MetricsRepository get instance => _instance ??= MetricsRepository._();

  final _client = SupabaseService.instance.client;

  /// Add a weight metric for a user. Returns the created row id or null.
  Future<String?> addWeight({
    required String userId,
    required double kg,
    double? bodyFat,
    int? waistCm,
    DateTime? recordedAt,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'kg': kg,
        if (bodyFat != null) 'body_fat': bodyFat,
        if (waistCm != null) 'waist_cm': waistCm,
        'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
        'source': 'manual',
      };

      final resp =
          await _client.from('metrics_weight').insert(data).select().single();
      // Supabase returns the inserted row as a Map; cast and return the id if present.
      final row = resp as Map<String, dynamic>?;
      if (row != null && row.containsKey('id')) return row['id']?.toString();
    } catch (e) {
      // ignore errors
      debugPrint('MetricsRepository.addWeight failed: $e');
    }
    return null;
  }

  /// Fetch recent weights for a user (most recent first).
  Future<List<Map<String, dynamic>>> fetchWeights(String userId,
      {int limit = 50}) async {
    try {
      final resp = await _client
          .from('metrics_weight')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(limit);
      // Supabase returns a List of maps for select; cast and normalize the rows.
      final rows = resp as List<dynamic>?;
      if (rows != null) {
        return List<Map<String, dynamic>>.from(
            rows.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) {
      debugPrint('MetricsRepository.fetchWeights failed: $e');
    }
    return [];
  }

  /// Stream that emits updated snapshots when realtime events for metrics arrive.
  /// This is a convenience wrapper — it returns a broadcast stream.
  Stream<List<Map<String, dynamic>>> streamWeights(String userId) async* {
    // emit initial snapshot
    final initial = await fetchWeights(userId);
    yield initial;

    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    // forward realtime changes by re-fetching snapshot on weight events
    final sub = RealtimeService.instance.dataStream.listen((event) async {
      try {
        final type = event['type'] as String?;
        if (type == 'metrics_weight' || type == 'weight') {
          final updated = await fetchWeights(userId);
          controller.add(updated);
        }
      } catch (_) {}
    });

    // yield values from controller
    yield* controller.stream;

    // cleanup when stream closed
    await sub.cancel();
    await controller.close();
  }
}

final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository.instance;
});

// Riverpod helpers
final metricsStreamProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, userId) {
  final repo = ref.watch(metricsRepositoryProvider);
  return repo.streamWeights(userId);
});

final addWeightProvider = FutureProvider.autoDispose.family<
    String?,
    ({
      String userId,
      double kg,
      double? bodyFat,
      int? waistCm
    })>((ref, args) async {
  final repo = ref.read(metricsRepositoryProvider);
  return repo.addWeight(
      userId: args.userId,
      kg: args.kg,
      bodyFat: args.bodyFat,
      waistCm: args.waistCm);
});
