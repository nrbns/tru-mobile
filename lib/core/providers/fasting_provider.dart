import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fasting_service.dart';

/// Provider for FastingService
final fastingServiceProvider = Provider((ref) => FastingService());

/// StreamProvider for active fasting session (real-time)
final activeFastingSessionProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(fastingServiceProvider);
  return service.streamActiveSession();
});

/// StreamProvider for fasting history
final fastingHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(fastingServiceProvider);
  return service.streamFastingHistory();
});

