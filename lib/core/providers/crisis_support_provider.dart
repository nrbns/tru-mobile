import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/crisis_support_service.dart';

/// Provider for CrisisSupportService
final crisisSupportServiceProvider = Provider((ref) => CrisisSupportService());

/// StreamProvider for helplines (real-time)
final helplinesStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) {
  final service = ref.watch(crisisSupportServiceProvider);
  return service.streamHelplines(
    country: params['country'] as String?,
  );
});

/// StreamProvider for active safety plan (real-time)
final activeSafetyPlanStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(crisisSupportServiceProvider);
  return service.streamActiveSafetyPlan();
});

/// StreamProvider for peer support chats (real-time)
final peerSupportChatsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(crisisSupportServiceProvider);
  return service.streamPeerSupportChats();
});

