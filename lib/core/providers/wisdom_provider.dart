import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wisdom_service.dart';
import '../models/wisdom_model.dart';

/// Provider for WisdomService
final wisdomServiceProvider = Provider((ref) => WisdomService());

/// Provider for daily wisdom
final dailyWisdomProvider = FutureProvider.family<WisdomModel, Map<String, String?>>((ref, params) async {
  final service = ref.watch(wisdomServiceProvider);
  try {
    return await service.getDailyWisdom(
      userMood: params['mood'],
      spiritualPath: params['spiritualPath'],
      category: params['category'],
    );
  } catch (e) {
    // Return a default wisdom if error
    return const WisdomModel(
      id: 'default',
      source: 'Wisdom',
      category: 'General',
      translation: 'Every moment is a new beginning.',
    );
  }
});

/// StreamProvider for wisdom library
final wisdomLibraryStreamProvider = StreamProvider.family<List<WisdomModel>, Map<String, dynamic>>((ref, params) {
  final service = ref.watch(wisdomServiceProvider);
  return service.streamWisdomLibrary(
    source: params['source'] as String?,
    category: params['category'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// FutureProvider for wisdom library with filters
final wisdomLibraryProvider = FutureProvider.family<List<WisdomModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(wisdomServiceProvider);
  return service.getWisdomLibrary(
    source: params['source'] as String?,
    category: params['category'] as String?,
    tags: params['tags'] as List<String>?,
    moodFit: params['moodFit'] as String?,
    tradition: params['tradition'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

/// Provider for legends wisdom
final legendsWisdomProvider = FutureProvider.family<List<WisdomModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(wisdomServiceProvider);
  return service.getLegendsWisdom(
    author: params['author'] as String?,
    limit: params['limit'] as int? ?? 20,
  );
});

/// StreamProvider for saved wisdom
final savedWisdomStreamProvider = StreamProvider<List<WisdomModel>>((ref) {
  final service = ref.watch(wisdomServiceProvider);
  return service.streamSavedWisdom();
});

/// StreamProvider for wisdom reflections
final wisdomReflectionsStreamProvider = StreamProvider.family<List<WisdomReflectionModel>, int>((ref, limit) {
  final service = ref.watch(wisdomServiceProvider);
  return service.streamWisdomReflections(limit: limit);
});

/// Provider for wisdom streak
final wisdomStreakProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(wisdomServiceProvider);
  return service.getWisdomStreak();
});

/// Provider for available sources
final wisdomSourcesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(wisdomServiceProvider);
  return service.getAvailableSources();
});

/// Provider for available categories
final wisdomCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(wisdomServiceProvider);
  return service.getAvailableCategories();
});

