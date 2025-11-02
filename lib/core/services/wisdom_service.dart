import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/daily_wisdom.dart';

/// WisdomService: provides read/write access to the wisdom collection and
/// supporting user-scoped behaviour. Implemented with conservative,
/// defensive APIs so UI screens can call these methods without crashing.
class WisdomService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final Uri? functionEndpoint;

  WisdomService(this._db, this._auth, {this.functionEndpoint});

  /// Primary API used by DailyWisdom screen. Tries a Cloud Function first
  /// (if configured), then a curated `wisdom_daily/today` doc, then a random
  /// published doc from `wisdom`. Falls back to a local in-memory sample.
  Future<DailyWisdom> getDailyWisdom({
    String? mood,
    String? spiritualPath,
    String? category,
  }) async {
    // 1) Try Cloud Function if configured
    if (functionEndpoint != null) {
      try {
        final token = await _auth.currentUser?.getIdToken();
        final res = await http.post(
          functionEndpoint!,
          headers: {
            'content-type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'mood': mood,
            'spiritualPath': spiritualPath,
            'category': category,
          }),
        );
        if (res.statusCode == 200) {
          final m = jsonDecode(res.body) as Map<String, dynamic>;
          return DailyWisdom.fromMap(m['id'] as String? ?? 'func', m);
        }
      } catch (_) {
        // ignore and fall through to Firestore
      }
    }

    // 2) Try curated daily doc
    try {
      final d = await _db.collection('wisdom_daily').doc('today').get();
      if (d.exists) {
        final data = Map<String, dynamic>.from(d.data() ?? {});
        data.putIfAbsent(
            'servedAt', () => DateTime.now().millisecondsSinceEpoch);
        return DailyWisdom.fromMap(d.id, data);
      }
    } catch (_) {
      // fall through
    }

    // 3) Random from library
    try {
      final q = await _db
          .collection('wisdom')
          .where('published', isEqualTo: true)
          .limit(50)
          .get();
      if (q.docs.isNotEmpty) {
        final doc = (q.docs..shuffle()).first;
        final data = Map<String, dynamic>.from(doc.data());
        data.putIfAbsent(
            'servedAt', () => DateTime.now().millisecondsSinceEpoch);
        return DailyWisdom.fromMap(doc.id, data);
      }
    } catch (_) {
      // fall through
    }

    // 4) Local fallback
    return DailyWisdom(
      id: 'local-fallback',
      translation: 'Start where you are. Use what you have. Do what you can.',
      verse: null,
      meaning: 'Begin your journey now with the resources at hand.',
      source: 'Wisdom',
      author: 'Arthur Ashe',
      tags: const ['discipline', 'action'],
      servedAt: DateTime.now(),
      category: 'General',
    );
  }

  /// Save a wisdom item to the user's `my_wisdom` collection.
  Future<void> saveToMyWisdom(String wisdomId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');
    final ref =
        _db.collection('users').doc(uid).collection('my_wisdom').doc(wisdomId);
    await ref.set({
      'savedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Read a wisdom document by id and convert to DailyWisdom.
  Future<DailyWisdom?> getWisdomById(String id) async {
    try {
      final d = await _db.collection('wisdom').doc(id).get();
      if (!d.exists) return null;
      final raw = d.data() ?? {};
      return DailyWisdom.fromMap(d.id, raw);
    } catch (_) {
      return null;
    }
  }

  /// Store a user's reflection on a wisdom item. Accepts named parameters for
  /// compatibility with existing callers in the UI.
  Future<void> reflectOnWisdom({
    required String wisdomId,
    String? reflectionText,
    int? moodBefore,
    int? moodAfter,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');
    final ref =
        _db.collection('users').doc(uid).collection('wisdom_reflections').doc();
    await ref.set({
      'wisdomId': wisdomId,
      if (reflectionText != null) 'reflection': reflectionText,
      if (moodBefore != null) 'moodBefore': moodBefore,
      if (moodAfter != null) 'moodAfter': moodAfter,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark that the user applied this wisdom (simple bookkeeping / streaking).
  Future<void> markWisdomApplied(String wisdomId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('applied_wisdom')
        .doc(wisdomId);
    await ref.set({
      'appliedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream user's saved wisdom items as a list.
  Stream<List<DailyWisdom>> savedWisdomStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream<List<DailyWisdom>>.empty();
    final col = _db
        .collection('users')
        .doc(uid)
        .collection('my_wisdom')
        .orderBy('savedAt', descending: true);
    return col.snapshots().asyncMap((snap) async {
      final ids = snap.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return <DailyWisdom>[];
      final docs = await Future.wait(
          ids.map((id) => _db.collection('wisdom').doc(id).get()));
      return docs.where((d) => d.exists).map((d) {
        final raw = d.data() ?? {};
        return DailyWisdom.fromMap(d.id, raw);
      }).toList();
    });
  }

  /// Stream user reflections.
  Stream<List<Map<String, dynamic>>> wisdomReflectionsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream<List<Map<String, dynamic>>>.empty();
    final col = _db
        .collection('users')
        .doc(uid)
        .collection('wisdom_reflections')
        .orderBy('createdAt', descending: true);
    return col.snapshots().map((snap) => snap.docs
        .map((d) =>
            Map<String, dynamic>.from(d.data() as Map<String, dynamic>? ?? {}))
        .toList());
  }

  /// Fetch distinct sources from the wisdom collection (best-effort query).
  Future<List<String>> getSources() async {
    try {
      final q = await _db.collection('wisdom').limit(200).get();
      final set = <String>{};
      for (final d in q.docs) {
        final s = (d.data() as Map<String, dynamic>?)?['source'];
        if (s is String && s.isNotEmpty) set.add(s);
      }
      return set.toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch distinct categories from the wisdom collection (best-effort).
  Future<List<String>> getCategories() async {
    try {
      final q = await _db.collection('wisdom').limit(200).get();
      final set = <String>{};
      for (final d in q.docs) {
        final s = (d.data() as Map<String, dynamic>?)?['category'];
        if (s is String && s.isNotEmpty) set.add(s);
      }
      return set.toList();
    } catch (_) {
      return [];
    }
  }

  /// Stream the wisdom library with optional filters.
  Stream<List<DailyWisdom>> wisdomLibraryStream(
      {String? category, String? source, int limit = 50}) {
    Query col = _db.collection('wisdom').where('published', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      col = col.where('category', isEqualTo: category);
    }
    if (source != null && source.isNotEmpty) {
      col = col.where('source', isEqualTo: source);
    }
    col = col.limit(limit);
    return col.snapshots().map((snap) => snap.docs.map((d) {
          final raw = d.data() as Map<String, dynamic>? ?? {};
          return DailyWisdom.fromMap(d.id, raw);
        }).toList());
  }
}
