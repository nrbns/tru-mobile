import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/faith_service.dart';

final faithServiceProvider = Provider((ref) => FaithService());

final christianVersesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final service = ref.watch(faithServiceProvider);
  return service.getDailyVerses(limit: limit);
});

final christianDevotionalsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final service = ref.watch(faithServiceProvider);
  return service.getDevotionals(limit: limit);
});

final islamicAyahProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final service = ref.watch(faithServiceProvider);
  return service.getDailyAyah(limit: limit);
});

final jewishLessonsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(faithServiceProvider);
  return service.getLessons(
    category: params['category'] as String? ?? 'Torah',
    limit: params['limit'] as int? ?? 10,
  );
});
