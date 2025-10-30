import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_log_model.dart';
import 'today_service.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TodayService _todayService = TodayService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('MoodService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _moodLogsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('mood_logs');
  }

  Future<void> logMood({
    required int score,
    required List<String> emotions,
    String? note,
    String? voiceUrl,
  }) async {
    final moodLog = MoodLogModel(
      id: '', // Will be set by Firestore
      uid: _requireUid(),
      at: DateTime.now(),
      score: score,
      emotions: emotions,
      note: note,
      voiceUrl: voiceUrl,
    );

    await _moodLogsRef.add(moodLog.toFirestore());

    // Update today's mood status
    await _todayService.updateMood(score: score);

    // Trigger aggregate function
    await _todayService.callAggregateToday();
  }

  Stream<List<MoodLogModel>> streamMoodLogs({int limit = 30}) {
    return _moodLogsRef
        .orderBy('at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodLogModel.fromFirestore(doc))
            .toList());
  }

  Future<List<MoodLogModel>> getMoodLogs({int limit = 30}) async {
    final snapshot =
        await _moodLogsRef.orderBy('at', descending: true).limit(limit).get();

    return snapshot.docs.map((doc) => MoodLogModel.fromFirestore(doc)).toList();
  }

  Future<List<MoodLogModel>> getMoodLogsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _moodLogsRef
        .where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('at', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('at', descending: false)
        .get();

    return snapshot.docs.map((doc) => MoodLogModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteMoodLog(String moodLogId) async {
    await _moodLogsRef.doc(moodLogId).delete();
  }
}
