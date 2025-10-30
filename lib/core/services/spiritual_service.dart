import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'today_service.dart';

class SpiritualService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final TodayService _todayService = TodayService();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('SpiritualService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _practicesRef =>
      _firestore.collection(FirestoreKeys.practices);
  CollectionReference get _practiceLogsRef {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.practiceLogs);
  }

  CollectionReference get _dailyCardsRef {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.dailyCards);
  }

  Stream<List<Map<String, dynamic>>> streamPractices({
    List<String>? traditions,
    int limit = 50,
  }) {
    Query query = _practicesRef.limit(limit);

    if (traditions != null && traditions.isNotEmpty) {
      query = query.where('tradition', whereIn: traditions);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  Future<List<Map<String, dynamic>>> getPractices({
    List<String>? traditions,
    int limit = 50,
  }) async {
    Query query = _practicesRef.limit(limit);

    if (traditions != null && traditions.isNotEmpty) {
      query = query.where('tradition', whereIn: traditions);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Future<void> logPractice({
    required String practiceId,
    required int durationMin,
    int? focusScore,
    String? notes,
  }) async {
    await _practiceLogsRef.add({
      'at': FieldValue.serverTimestamp(),
      'practice_id': practiceId,
      'duration_min': durationMin,
      'focus_score': focusScore,
      'notes': notes,
    });

    // Update today's sadhana status
    final today = await _todayService.getToday();
    final completedPractices = [
      ...today.sadhana.completedPractices,
      practiceId
    ];
    await _todayService.updateSadhana(
      done: today.sadhana.done + 1,
      target: today.sadhana.target,
      completedPractices: completedPractices,
    );

    await _todayService.callAggregateToday();
  }

  Future<Map<String, dynamic>?> getDailyCard(String dateKey) async {
    final doc = await _dailyCardsRef.doc(dateKey).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  Future<Map<String, dynamic>> generateDailyCard() async {
    try {
      final callable = _functions.httpsCallable('daily-card');
      final result = await callable.call();
      return result.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate daily card: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamPracticeLogs({int limit = 50}) {
    return _practiceLogsRef
        .orderBy('at', descending: true)
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

  /// Get recent practice logs as a one-off list
  Future<List<Map<String, dynamic>>> getPracticeLogs({int limit = 50}) async {
    final snapshot = await _practiceLogsRef
        .orderBy('at', descending: true)
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

  Future<int> getStreakDays() async {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));

      final practiceLog = await _practiceLogsRef
          .where('at',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .where('at',
              isLessThan: Timestamp.fromDate(
                  DateTime(date.year, date.month, date.day + 1)))
          .limit(1)
          .get();

      if (practiceLog.docs.isEmpty) {
        break;
      }
      streak++;
    }

    return streak;
  }
}
