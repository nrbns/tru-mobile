import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Workout Generation Service - AI-powered workout creation
/// Supports voice input and text input for workout generation
class WorkoutGenerationService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('WorkoutGenerationService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Generate workout from voice input
  Future<Map<String, dynamic>> generateWorkoutFromVoice({
    required String transcript,
    String? goal,
    String? duration,
    String? difficulty,
  }) async {
    try {
      final callable = _functions.httpsCallable('generate-workout-from-voice');
      final result = await callable.call({
        'transcript': transcript,
        'goal': goal,
        'duration': duration,
        'difficulty': difficulty,
      });

      final workout = Map<String, dynamic>.from(result.data as Map);

      // Save generated workout to Firestore
      await _saveGeneratedWorkout(workout);

      return workout;
    } catch (e) {
      throw Exception('Failed to generate workout: $e');
    }
  }

  /// Generate workout from text input
  Future<Map<String, dynamic>> generateWorkout({
    required String description,
    String? goal, // weight_loss, muscle_gain, endurance, flexibility
    String? duration, // 15, 30, 45, 60 minutes
    String? difficulty, // beginner, intermediate, advanced
    List<String>? equipment, // none, dumbbells, resistance_bands, etc.
    List<String>? bodyParts, // chest, arms, legs, core, etc.
  }) async {
    try {
      final callable = _functions.httpsCallable('generate-workout');
      final result = await callable.call({
        'description': description,
        'goal': goal,
        'duration': duration,
        'difficulty': difficulty,
        'equipment': equipment ?? [],
        'body_parts': bodyParts ?? [],
      });

      final workout = Map<String, dynamic>.from(result.data as Map);

      // Save generated workout to Firestore
      await _saveGeneratedWorkout(workout);

      return workout;
    } catch (e) {
      throw Exception('Failed to generate workout: $e');
    }
  }

  /// Save generated workout to Firestore
  Future<void> _saveGeneratedWorkout(Map<String, dynamic> workout) async {
    final uid = _requireUid();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('generated_workouts')
        .add({
      ...workout,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'draft', // draft, in_progress, completed
    });
  }

  /// Get generated workout history
  Future<List<Map<String, dynamic>>> getWorkoutHistory({int limit = 20}) async {
    final uid = _requireUid();

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('generated_workouts')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }
}
