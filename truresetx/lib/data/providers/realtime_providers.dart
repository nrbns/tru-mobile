import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/realtime_ws_service.dart';
import '../models/realtime_models.dart';

// Configure these to your real endpoint and token retrieval
final realtimeWsUrlProvider = Provider<String>((ref) {
  return 'wss://your-realtime-server.example/ws';
});

final realtimeAuthTokenProvider = Provider<String?>((ref) {
  // Optional: read from auth provider
  return null;
});

// Singleton RealtimeWsService
final realtimeWsServiceProvider = Provider<RealtimeWsService>((ref) {
  final url = ref.watch(realtimeWsUrlProvider);
  final token = ref.watch(realtimeAuthTokenProvider);
  final svc = RealtimeWsService(wsUrl: url, token: token);
  // connect immediately
  svc.connect();
  ref.onDispose(() => svc.dispose());
  return svc;
});

// Stream provider that emits incoming detected foods
final liveDetectedFoodProvider =
    StreamProvider.autoDispose<RealtimeDetectedFood>((ref) {
  final svc = ref.watch(realtimeWsServiceProvider);
  return svc.detections;
});
