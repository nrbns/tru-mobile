import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Fasting Service - Tracks intermittent fasting sessions
class FastingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('FastingService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _fastingSessionsRef {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('fasting_sessions');
  }

  /// Start a fasting session
  Future<String> startFasting({
    required String planType, // '16:8', '18:6', 'OMAD', etc.
    required int fastingHours,
  }) async {
    final now = DateTime.now();
    final doc = await _fastingSessionsRef.add({
      'plan_type': planType,
      'fasting_hours': fastingHours,
      'start_time': Timestamp.fromDate(now),
      'end_time': Timestamp.fromDate(now.add(Duration(hours: fastingHours))),
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Stop/Complete a fasting session
  Future<void> stopFasting(String sessionId) async {
    await _fastingSessionsRef.doc(sessionId).update({
      'status': 'completed',
      'stopped_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get active fasting session
  Future<Map<String, dynamic>?> getActiveSession() async {
    final snapshot = await _fastingSessionsRef
        .where('status', isEqualTo: 'active')
        .orderBy('start_time', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Stream active fasting session for real-time updates
  Stream<Map<String, dynamic>?> streamActiveSession() {
    return _fastingSessionsRef
        .where('status', isEqualTo: 'active')
        .orderBy('start_time', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    });
  }

  /// Get fasting history
  Stream<List<Map<String, dynamic>>> streamFastingHistory({int limit = 30}) {
    return _fastingSessionsRef
        .orderBy('start_time', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }
}

