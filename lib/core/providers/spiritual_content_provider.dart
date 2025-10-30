import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spiritual_content_service.dart';

/// Provider for SpiritualContentService
final spiritualContentServiceProvider = Provider((ref) => SpiritualContentService());

/// StreamProvider for mantras
final mantrasProvider = StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.streamMantras(
    traditions: params['traditions'] as List<String>?,
    category: params['category'] as String?,
  );
});

/// FutureProvider for practices
final practicesProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.getPractices(
    traditions: params['traditions'] as List<String>?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// FutureProvider for daily wisdom
final dailyWisdomProvider = FutureProvider((ref) async {
  final service = ref.watch(spiritualContentServiceProvider);
  return service.getDailyWisdom();
});

