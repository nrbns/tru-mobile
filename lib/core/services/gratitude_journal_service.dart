import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/gratitude_journal_entry.dart';
import '../utils/firestore_keys.dart';

/// Service for Gratitude & Reflection Journal
/// Morning gratitude + night reflection with AI summarizer
class GratitudeJournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  CollectionReference get _journalEntriesRef {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('GratitudeJournalService: no authenticated user');
    }
    final uid = currentUser.uid;
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.gratitudeJournals);
  }

  /// Save journal entry (gratitude or reflection)
  Future<void> saveJournalEntry({
    required String type, // 'gratitude' or 'reflection'
    required String text,
    List<String>? emotionTags,
    DateTime? date,
  }) async {
    final entryDate = date ?? DateTime.now();
    final dateKey =
        '${entryDate.year}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}';

    await _journalEntriesRef.doc('${dateKey}_$type').set({
      'type': type,
      'text': text,
      'emotion_tags': emotionTags ?? [],
      'date': Timestamp.fromDate(entryDate),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream journal entries (real-time)
  Stream<List<Map<String, dynamic>>> streamJournalEntries({
    String? type,
    int limit = 50,
  }) {
    Query query =
        _journalEntriesRef.orderBy('date', descending: true).limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Compatibility: older callers expect `streamEntries` returning model objects
  Stream<List<GratitudeJournalEntry>> streamEntries(
      {int limit = 50, String? type}) {
    Query query =
        _journalEntriesRef.orderBy('date', descending: true).limit(limit);
    if (type != null) query = query.where('type', isEqualTo: type);
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => GratitudeJournalEntry.fromDoc(doc))
        .toList());
  }

  /// Compatibility: older callers expect `addEntry` method
  Future<void> addEntry({
    required String type,
    required String text,
    List<String> emotionTags = const [],
    DateTime? date,
  }) async {
    await saveJournalEntry(
        type: type, text: text, emotionTags: emotionTags, date: date);
  }

  /// Get today's gratitude entry
  Future<Map<String, dynamic>?> getTodayGratitude() async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final doc = await _journalEntriesRef.doc('${dateKey}_gratitude').get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Get today's reflection entry
  Future<Map<String, dynamic>?> getTodayReflection() async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final doc = await _journalEntriesRef.doc('${dateKey}_reflection').get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Get AI summary for soul growth log (weekly/monthly)
  Future<Map<String, dynamic>> getAISoulGrowthSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateSoulGrowthSummary');
      final result = await callable.call({
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'user_id': _auth.currentUser?.uid,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to generate soul growth summary: $e');
    }
  }

  /// Get gratitude streak
  Future<int> getGratitudeStreak() async {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _journalEntriesRef.doc('${dateKey}_gratitude').get();
      if (!doc.exists) break;
      streak++;
    }

    return streak;
  }

  /// Get reflection prompt for today
  Future<String?> getTodayReflectionPrompt() async {
    try {
      final callable = _functions.httpsCallable('getReflectionPrompt');
      final result = await callable.call({
        'user_mood': null, // Can pass user's current mood
        'date': DateTime.now().toIso8601String(),
      });

      final data = Map<String, dynamic>.from(result.data);
      return data['prompt'] as String?;
    } catch (e) {
      return null; // Fallback to default prompt
    }
  }
}
