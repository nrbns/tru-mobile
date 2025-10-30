import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_keys.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Spiritual Content Service - Real mantras, practices, and wisdom
/// Integrated with voice/TTS for audio playback
class SpiritualContentService {
  // These instances are intentionally kept for feature expansion; suppress
  // analyzer unused-field warnings until they're fully referenced.
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ignore: unused_field
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  // ignore: unused_field
  final FlutterTts _tts = FlutterTts();

  CollectionReference get _mantrasRef =>
      _firestore.collection(FirestoreKeys.mantras);
  CollectionReference get _practicesRef =>
      _firestore.collection(FirestoreKeys.practices);
  CollectionReference get _wisdomRef =>
      _firestore.collection(FirestoreKeys.wisdomPosts);
  CollectionReference get _versesRef =>
      _firestore.collection(FirestoreKeys.sacredVerses);

  /// Initialize TTS
  Future<void> initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Get mantras by tradition/category
  Future<List<Map<String, dynamic>>> getMantras({
    List<String>? traditions,
    String? category,
    int limit = 50,
  }) async {
    Query query = _mantrasRef.limit(limit);

    if (traditions != null && traditions.isNotEmpty) {
      query = query.where('tradition', whereIn: traditions);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'text': data['text'] ?? '',
        'translation': data['translation'] ?? '',
        'meaning': data['meaning'] ?? '',
        'tradition': data['tradition'] ?? '',
        'category': data['category'] ?? '',
        'repetitions': data['repetitions'] ?? 108,
        'audio_url': data['audio_url'],
        ...data,
      };
    }).toList();
  }

  /// Play mantra using TTS
  Future<void> playMantra(String mantraText) async {
    await initializeTTS();
    await _tts.speak(mantraText);
  }

  /// Stop TTS playback
  Future<void> stopPlayback() async {
    await _tts.stop();
  }

  /// Get practices by tradition
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
        'name': data['name'] ?? '',
        'description': data['description'] ?? '',
        'steps': List<String>.from(data['steps'] ?? []),
        'duration_min': data['duration_min'] ?? 15,
        'tradition': data['tradition'] ?? '',
        'difficulty': data['difficulty'] ?? 'beginner',
        ...data,
      };
    }).toList();
  }

  /// Get daily wisdom post
  Future<Map<String, dynamic>?> getDailyWisdom() async {
    final snapshot =
        await _wisdomRef.orderBy('date', descending: true).limit(1).get();

    if (snapshot.docs.isEmpty) {
      // Generate new wisdom if none exists
      return await generateDailyWisdom();
    }

    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Generate daily wisdom using AI
  Future<Map<String, dynamic>> generateDailyWisdom({
    List<String>? traditions,
  }) async {
    try {
      final callable = _functions.httpsCallable('generate-daily-wisdom');
      final result = await callable.call({
        'traditions': traditions ?? [],
      });

      final wisdom = Map<String, dynamic>.from(result.data as Map);

      // Save to Firestore
      await _wisdomRef.add({
        ...wisdom,
        'date': FieldValue.serverTimestamp(),
      });

      return wisdom;
    } catch (e) {
      throw Exception('Failed to generate daily wisdom: $e');
    }
  }

  /// Get sacred verses by tradition
  Future<List<Map<String, dynamic>>> getSacredVerses({
    List<String>? traditions,
    int limit = 20,
  }) async {
    Query query = _versesRef.limit(limit);

    if (traditions != null && traditions.isNotEmpty) {
      query = query.where('tradition', whereIn: traditions);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'verse': data['verse'] ?? '',
        'translation': data['translation'] ?? '',
        'source': data['source'] ?? '',
        'tradition': data['tradition'] ?? '',
        'chapter': data['chapter'],
        'verse_number': data['verse_number'],
        ...data,
      };
    }).toList();
  }

  /// Play verse using TTS
  Future<void> playVerse(String verseText) async {
    await initializeTTS();
    await _tts.speak(verseText);
  }

  /// Search mantras or practices
  Future<List<Map<String, dynamic>>> searchContent({
    required String query,
    String? type, // 'mantra', 'practice', 'verse'
    List<String>? traditions,
  }) async {
    var searchQuery = query.toLowerCase();
    List<Map<String, dynamic>> results = [];

    if (type == null || type == 'mantra') {
      final mantras = await getMantras(traditions: traditions);
      results.addAll(mantras.where(
        (m) =>
            (m['text'] as String).toLowerCase().contains(searchQuery) ||
            (m['translation'] as String).toLowerCase().contains(searchQuery) ||
            (m['meaning'] as String).toLowerCase().contains(searchQuery),
      ));
    }

    if (type == null || type == 'practice') {
      final practices = await getPractices(traditions: traditions);
      results.addAll(practices.where(
        (p) =>
            (p['name'] as String).toLowerCase().contains(searchQuery) ||
            (p['description'] as String).toLowerCase().contains(searchQuery),
      ));
    }

    if (type == null || type == 'verse') {
      final verses = await getSacredVerses(traditions: traditions);
      results.addAll(verses.where(
        (v) =>
            (v['verse'] as String).toLowerCase().contains(searchQuery) ||
            (v['translation'] as String).toLowerCase().contains(searchQuery),
      ));
    }

    return results;
  }

  /// Stream mantras for real-time updates
  Stream<List<Map<String, dynamic>>> streamMantras({
    List<String>? traditions,
    String? category,
  }) {
    Query query = _mantrasRef;

    if (traditions != null && traditions.isNotEmpty) {
      query = query.where('tradition', whereIn: traditions);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }
}
