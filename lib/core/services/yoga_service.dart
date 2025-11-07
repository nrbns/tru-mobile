import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../utils/firestore_keys.dart';

/// Service for Yoga Practice (Down Dog/Yoga for Beginners-style)
/// AI suggests daily sequences based on body pain, stress, and time
class YogaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('YogaService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _yogaSessionsRef =>
      _firestore.collection(FirestoreKeys.yogaSessions);
  CollectionReference get _yogaPosesRef =>
      _firestore.collection(FirestoreKeys.yogaPoses);

  /// Generate AI yoga sequence
  Future<Map<String, dynamic>> generateYogaSequence({
    String? goal, // 'flexibility', 'strength', 'relaxation', 'pain_relief'
    List<String>? bodyParts, // ['lower_back', 'neck', 'shoulders']
    int? durationMinutes,
    String? level, // 'beginner', 'intermediate', 'advanced'
    List<String>? availableEquipment, // ['mat', 'blocks', 'strap']
    int? stressLevel, // 1-10
  }) async {
    try {
      final callable = _functions.httpsCallable('generateYogaSequence');
      final result = await callable.call({
        'goal': goal,
        'body_parts': bodyParts,
        'duration_minutes': durationMinutes,
        'level': level,
        'available_equipment': availableEquipment,
        'stress_level': stressLevel,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to generate yoga sequence: $e');
    }
  }

  /// Stream yoga sessions library (real-time)
  Stream<List<Map<String, dynamic>>> streamYogaSessions({
    String? level,
    String? focus,
    int limit = 50,
  }) {
    Query query = _yogaSessionsRef.limit(limit);

    if (level != null) {
      query = query.where('level', isEqualTo: level);
    }
    if (focus != null) {
      query = query.where('focus', isEqualTo: focus);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Get yoga pose by ID
  Future<Map<String, dynamic>?> getYogaPoseById(String poseId) async {
    final doc = await _yogaPosesRef.doc(poseId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Stream yoga poses library (real-time)
  Stream<List<Map<String, dynamic>>> streamYogaPoses({
    String? category, // 'standing', 'seated', 'backbend', etc.
    List<String>? targetMuscles,
    int limit = 100,
  }) {
    Query query = _yogaPosesRef.limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (targetMuscles != null && targetMuscles.isNotEmpty) {
      query = query.where('target_muscles', arrayContainsAny: targetMuscles);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Log yoga session completion
  Future<void> logYogaSession({
    required String sessionId,
    required int durationMinutes,
    int? difficultyRating,
    String? notes,
    List<String>? completedPoses,
  }) async {
    final uid = _requireUid();
    await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.yogaSessions)
        .add({
      'session_id': sessionId,
      'duration_minutes': durationMinutes,
      'difficulty_rating': difficultyRating,
      'notes': notes,
      'completed_poses': completedPoses ?? [],
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Stream user's yoga session history (real-time)
  Stream<List<Map<String, dynamic>>> streamYogaSessionHistory(
      {int limit = 30}) {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.yogaSessions)
        .orderBy('completed_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// Get yoga practice streak
  Future<int> getYogaStreak() async {
    final uid = _requireUid();
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final sessions = await _firestore
          .collection('users')
          .doc(uid)
          .collection('yoga_sessions')
          .where('completed_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('completed_at', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (sessions.docs.isEmpty) break;
      streak++;
    }

    return streak;
  }

  /// Get recommended yoga session based on user state
  Future<Map<String, dynamic>?> getRecommendedYogaSession({
    int? currentMood,
    int? stressLevel,
    List<String>? bodyPain,
    int? availableMinutes,
  }) async {
    try {
      final sequence = await generateYogaSequence(
        goal: bodyPain != null && bodyPain.isNotEmpty ? 'pain_relief' : null,
        bodyParts: bodyPain,
        durationMinutes: availableMinutes ?? 20,
        stressLevel: stressLevel,
        level: 'beginner', // Can be made dynamic based on user history
      );

      return sequence;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getYogaSessions(
      {String? level, String? focus, int limit = 20}) async {
    Query query = _yogaSessionsRef.limit(limit);
    if (level != null) query = query.where('level', isEqualTo: level);
    if (focus != null) query = query.where('focus', isEqualTo: focus);
    final snap = await query.get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>? ?? {}})
        .toList();
  }
}
