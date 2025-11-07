import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spiritual_service.dart';
import '../services/spiritual_content_service.dart';

/// Provider for SpiritualService
final spiritualServiceProvider = Provider((ref) => SpiritualService());

/// Provider for SpiritualContentService
final spiritualContentServiceProvider =
    Provider((ref) => SpiritualContentService());

/// StreamProvider for practices
final practicesStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  final service = ref.watch(spiritualServiceProvider);
  return service.streamPractices(
    traditions: params['traditions'] as List<String>?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// FutureProvider for mantras with filters
final mantrasProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.getMantras(
    traditions: params['traditions'] as List<String>?,
    category: params['category'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// StreamProvider for mantras (real-time)
final mantrasStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.streamMantras(
    traditions: params['traditions'] as List<String>?,
    category: params['category'] as String?,
  );
});

/// FutureProvider for daily wisdom
final dailyWisdomProvider = FutureProvider((ref) async {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.getDailyWisdom();
});

/// FutureProvider for sacred verses
final sacredVersesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.getSacredVerses(
    traditions: params['traditions'] as List<String>?,
    limit: params['limit'] as int? ?? 20,
  );
});

/// StreamProvider for practice logs
final practiceLogsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(spiritualServiceProvider);
  return service.streamPracticeLogs();
});
