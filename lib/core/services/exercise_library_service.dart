import 'package:cloud_firestore/cloud_firestore.dart';

/// Exercise Library Service - 1000+ exercises with filtering
/// MuscleWiki-style comprehensive exercise database
class ExerciseLibraryService {
  // Keep Firestore instance available for future use; suppress analyzer
  // unused-field warnings here as this file is read by several callers.
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _exercisesRef => _firestore.collection('exercises');

  /// Get all exercises with optional filters
  Future<List<Map<String, dynamic>>> getExercises({
    List<String>? muscleGroups,
    List<String>? equipment,
    List<String>? difficulty,
    bool? compoundOnly,
    bool? isolationOnly,
    String? searchQuery,
    int limit = 100,
  }) async {
    Query query = _exercisesRef.limit(limit);

    if (muscleGroups != null && muscleGroups.isNotEmpty) {
      query = query.where('muscle_groups', arrayContainsAny: muscleGroups);
    }

    if (equipment != null && equipment.isNotEmpty) {
      query = query.where('equipment', whereIn: equipment);
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', whereIn: difficulty);
    }

    final snapshot = await query.get();
    var exercises = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'muscle_groups': List<String>.from(data['muscle_groups'] ?? []),
        'equipment': List<String>.from(data['equipment'] ?? []),
        'difficulty': data['difficulty'] ?? 'intermediate',
        'is_compound': data['is_compound'] ?? false,
        'video_url': data['video_url'],
        'instructions': data['instructions'] ?? '',
        'tips': List<String>.from(data['tips'] ?? []),
        ...data,
      };
    }).toList();

    // Apply additional filters
    if (compoundOnly == true) {
      exercises = exercises.where((e) => e['is_compound'] == true).toList();
    }

    if (isolationOnly == true) {
      exercises = exercises.where((e) => e['is_compound'] == false).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      exercises = exercises.where((e) {
        final name = (e['name'] as String? ?? '').toLowerCase();
        final muscleGroups = (e['muscle_groups'] as List<String>? ?? [])
            .map((m) => m.toLowerCase())
            .toList();
        return name.contains(queryLower) ||
            muscleGroups.any((m) => m.contains(queryLower));
      }).toList();
    }

    return exercises;
  }

  /// Get exercise by ID
  Future<Map<String, dynamic>?> getExerciseById(String exerciseId) async {
    final doc = await _exercisesRef.doc(exerciseId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Get exercises by muscle group
  Future<List<Map<String, dynamic>>> getExercisesByMuscleGroup(
    String muscleGroup,
  ) async {
    final snapshot = await _exercisesRef
        .where('muscle_groups', arrayContains: muscleGroup)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Stream exercises for real-time updates
  Stream<List<Map<String, dynamic>>> streamExercises({
    List<String>? muscleGroups,
    List<String>? equipment,
    int limit = 100,
  }) {
    Query query = _exercisesRef.limit(limit);

    if (muscleGroups != null && muscleGroups.isNotEmpty) {
      query = query.where('muscle_groups', arrayContainsAny: muscleGroups);
    }

    if (equipment != null && equipment.isNotEmpty) {
      query = query.where('equipment', whereIn: equipment);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Get available muscle groups
  Future<List<String>> getAvailableMuscleGroups() async {
    // Could be cached in Firestore or hardcoded
    return [
      'chest',
      'back',
      'shoulders',
      'biceps',
      'triceps',
      'forearms',
      'abs',
      'obliques',
      'quads',
      'hamstrings',
      'glutes',
      'calves',
      'cardio',
      'full body',
    ];
  }

  /// Get available equipment types
  Future<List<String>> getAvailableEquipment() async {
    return [
      'bodyweight',
      'dumbbells',
      'barbell',
      'kettlebell',
      'resistance bands',
      'machine',
      'cable',
      'medicine ball',
      'yoga mat',
      'pull-up bar',
    ];
  }
}
