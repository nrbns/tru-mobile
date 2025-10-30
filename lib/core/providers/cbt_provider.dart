import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cbt_service.dart';

/// Provider for CBTService
final cbtServiceProvider = Provider((ref) => CBTService());

/// StreamProvider for CBT exercises (real-time)
final cbtExercisesStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) {
  final service = ref.watch(cbtServiceProvider);
  return service.streamCBTExercises(
    type: params['type'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// StreamProvider for CBT journals (real-time)
final cbtJournalsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(cbtServiceProvider);
  return service.streamCBTJournals();
});

/// StreamProvider for therapy chats (real-time)
final therapyChatsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(cbtServiceProvider);
  return service.streamTherapyChats();
});

/// FutureProvider for CBT statistics
final cbtStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(cbtServiceProvider);
  return service.getCBTStats();
});

