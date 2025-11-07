import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/today_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class TodayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('TodayService: no authenticated user');
    }
    return currentUser.uid;
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get todayKey => _getTodayKey();

  DocumentReference get _todayRef {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('today')
        .doc(todayKey);
  }

  Stream<TodayModel> streamToday() {
    return _todayRef.snapshots().map((doc) {
      if (!doc.exists) {
        return _getDefaultToday();
      }
      return TodayModel.fromFirestore(doc);
    });
  }

  Future<TodayModel> getToday() async {
    final doc = await _todayRef.get();
    if (!doc.exists) {
      return _getDefaultToday();
    }
    return TodayModel.fromFirestore(doc);
  }

  Future<void> updateWaterIntake(int ml) async {
    // Use set with merge to create today's doc if it doesn't exist yet
    await _todayRef.set({
      // Ensure a usable date field exists for analytics
      'date': FieldValue.serverTimestamp(),
      'water_ml': ml,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateCalories(int calories) async {
    await _todayRef.set({
      'date': FieldValue.serverTimestamp(),
      'calories': FieldValue.increment(calories),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateWorkoutStatus(
      {required int done, required int target}) async {
    await _todayRef.set({
      'date': FieldValue.serverTimestamp(),
      'workouts': {
        'done': done,
        'target': target,
      },
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateMood({required int score}) async {
    await _todayRef.set({
      'date': FieldValue.serverTimestamp(),
      'mood': {
        'latest': score,
        'last_logged_at': FieldValue.serverTimestamp(),
      },
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateSadhana(
      {required int done,
      required int target,
      List<String>? completedPractices}) async {
    final sadhanaData = <String, dynamic>{
      'done': done,
      'target': target,
      'completed_practices': completedPractices ?? [],
    };
    await _todayRef.set({
      'date': FieldValue.serverTimestamp(),
      'sadhana': sadhanaData,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateStreak(int streak) async {
    await _todayRef.set({
      'date': FieldValue.serverTimestamp(),
      'streak': streak,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> callAggregateToday() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Obtain ID token for auth header
      final idToken = await user.getIdToken();

      // Attempt to build Functions v2 HTTPS URL from Firebase options
      // Project ID may be configured via GOOGLE_CLOUD_PROJECT env var as fallback
      final projectId = Platform.environment['GOOGLE_CLOUD_PROJECT'] ??
          _firestore.app.options.projectId;

      final uri = Uri.parse(
          'https://asia-south1-$projectId.cloudfunctions.net/aggregateToday');

      await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $idToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
    } catch (_) {
      // Swallow errors to avoid blocking UX; aggregates will refresh later
    }
  }

  TodayModel _getDefaultToday() {
    final uid = _auth.currentUser?.uid ?? '';
    return TodayModel(
      uid: uid,
      date: DateTime.now(),
      streak: 0,
      calories: 0,
      waterMl: 0,
      workouts: WorkoutStatus(done: 0, target: 1),
      mood: MoodStatus(),
      sadhana: SadhanaStatus(done: 0, target: 3, completedPractices: []),
      updatedAt: DateTime.now(),
    );
  }
}
