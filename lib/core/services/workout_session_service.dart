import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final current = _auth.currentUser;
    if (current == null) {
      throw StateError('WorkoutSessionService: no authenticated user');
    }
    return current.uid;
  }

  CollectionReference get _sessionsRef {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workout_sessions');
  }

  Future<String> startSession(
      {required String name, List<Map<String, dynamic>>? exercises}) async {
    final doc = await _sessionsRef.add({
      'name': name,
      'started_at': FieldValue.serverTimestamp(),
      'exercises': exercises,
      'status': 'in_progress',
    });
    return doc.id;
  }

  Future<void> completeSession({
    required String sessionId,
    required int durationSec,
    required int estimatedCalories,
  }) async {
    await _sessionsRef.doc(sessionId).set({
      'completed_at': FieldValue.serverTimestamp(),
      'duration_sec': durationSec,
      'estimated_calories': estimatedCalories,
      'status': 'completed',
    }, SetOptions(merge: true));
  }
}
