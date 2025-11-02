import 'dart:async';
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

    // Create a controller to handle timeout and fallback
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    bool hasEmitted = false;
    final sampleData = _getSamplePractices(limit: limit);

    // Start listening to Firestore
    query.snapshots().listen(
      (snapshot) {
        if (!hasEmitted) {
          hasEmitted = true;
        }
        if (snapshot.docs.isEmpty && !hasEmitted) {
          // Only emit sample data if we haven't received anything yet
          controller.add(sampleData);
        } else if (snapshot.docs.isNotEmpty) {
          // Emit real data from Firestore
          final practices = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
          controller.add(practices);
        } else {
          // Empty snapshot but we already emitted - emit empty list
          controller.add([]);
        }
      },
      onError: (error) {
        if (!hasEmitted) {
          controller.add(sampleData);
        }
      },
      cancelOnError: false,
    );

    // Handle timeout for initial connection
    Timer(const Duration(seconds: 10), () {
      if (!hasEmitted) {
        hasEmitted = true;
        controller.add(sampleData);
      }
    });

    // Return stream and ensure cleanup
    return controller.stream;
  }

  List<Map<String, dynamic>> _getSamplePractices({int limit = 10}) {
    return [
      {
        'id': 'sample-prayer',
        'name': 'Morning Prayer',
        'duration_min': 10,
        'tradition': 'Universal',
        'difficulty': 'Beginner',
        'description': 'Start your day with gratitude and intention.',
      },
      {
        'id': 'sample-meditation',
        'name': 'Mindfulness Meditation',
        'duration_min': 15,
        'tradition': 'Buddhism',
        'difficulty': 'Beginner',
        'description': 'Focus on your breath and present moment awareness.',
      },
      {
        'id': 'sample-scripture',
        'name': 'Scripture Reading',
        'duration_min': 20,
        'tradition': 'Universal',
        'difficulty': 'Beginner',
        'description': 'Read and reflect on sacred texts.',
      },
      {
        'id': 'sample-gratitude',
        'name': 'Gratitude Journal',
        'duration_min': 5,
        'tradition': 'Universal',
        'difficulty': 'Beginner',
        'description': 'Write down three things you are grateful for today.',
      },
      {
        'id': 'sample-mantra',
        'name': 'Mantra Recitation',
        'duration_min': 10,
        'tradition': 'Hinduism',
        'difficulty': 'Beginner',
        'description': 'Repeat a sacred mantra with intention.',
      },
    ].take(limit).toList();
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
