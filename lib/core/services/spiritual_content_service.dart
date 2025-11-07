import 'dart:async';
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
    try {
      Query query = _mantrasRef.limit(limit);

      if (traditions != null && traditions.isNotEmpty) {
        query = query.where('tradition', whereIn: traditions);
      }

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Query timeout'),
      );

      if (snapshot.docs.isEmpty) {
        return _getSampleMantras(traditions: traditions, category: category, limit: limit);
      }

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
    } catch (e) {
      return _getSampleMantras(traditions: traditions, category: category, limit: limit);
    }
  }

  List<Map<String, dynamic>> _getSampleMantras({
    List<String>? traditions,
    String? category,
    int limit = 50,
  }) {
    final allMantras = [
      {
        'id': 'om-namah-shivaya',
        'text': 'Om Namah Shivaya',
        'translation': 'I bow to Shiva',
        'meaning': 'A sacred Hindu mantra invoking the consciousness of transformation and auspiciousness.',
        'tradition': 'Hinduism',
        'category': 'Prayer',
        'repetitions': 108,
      },
      {
        'id': 'om-mani-padme-hum',
        'text': 'Om Mani Padme Hum',
        'translation': 'The jewel is in the lotus',
        'meaning': 'A powerful Buddhist mantra invoking compassion and wisdom.',
        'tradition': 'Buddhism',
        'category': 'Meditation',
        'repetitions': 108,
      },
      {
        'id': 'hare-krishna',
        'text': 'Hare Krishna, Hare Krishna, Krishna Krishna, Hare Hare',
        'translation': 'O Lord, O Energy of the Lord',
        'meaning': 'A Vaishnava mantra for divine love and connection.',
        'tradition': 'Hinduism',
        'category': 'Prayer',
        'repetitions': 108,
      },
      {
        'id': 'bismillah',
        'text': 'Bismillah ir-Rahman ir-Rahim',
        'translation': 'In the name of Allah, the Most Gracious, the Most Merciful',
        'meaning': 'Islamic invocation for beginning any action with divine blessing.',
        'tradition': 'Islam',
        'category': 'Prayer',
        'repetitions': 1,
      },
      {
        'id': 'shalom',
        'text': 'Shalom Aleichem',
        'translation': 'Peace be upon you',
        'meaning': 'A Jewish greeting invoking peace and blessing.',
        'tradition': 'Judaism',
        'category': 'Peace',
        'repetitions': 1,
      },
      {
        'id': 'lord-prayer',
        'text': 'Our Father, who art in heaven, hallowed be thy name...',
        'translation': 'The Lord\'s Prayer',
        'meaning': 'The central prayer of Christianity, taught by Jesus.',
        'tradition': 'Christianity',
        'category': 'Prayer',
        'repetitions': 1,
      },
      {
        'id': 'gayatri-mantra',
        'text': 'Om Bhur Bhuvaḥ Swaḥ',
        'translation': 'We meditate on the divine light',
        'meaning': 'One of the oldest and most powerful Vedic mantras.',
        'tradition': 'Hinduism',
        'category': 'Meditation',
        'repetitions': 108,
      },
      {
        'id': 'metta',
        'text': 'May all beings be happy and free from suffering',
        'translation': 'Loving-kindness prayer',
        'meaning': 'A Buddhist practice of extending compassion to all.',
        'tradition': 'Buddhism',
        'category': 'Peace',
        'repetitions': 1,
      },
    ];

    var filtered = allMantras;
    if (traditions != null && traditions.isNotEmpty && !traditions.contains('All')) {
      filtered = filtered.where((m) => traditions.contains(m['tradition'])).toList();
    }
    if (category != null && category != 'All') {
      filtered = filtered.where((m) => m['category'] == category).toList();
    }

    return filtered.take(limit).toList();
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
    try {
      final snapshot = await _wisdomRef
          .orderBy('date', descending: true)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Query timeout'),
          );

      if (snapshot.docs.isEmpty) {
        // Return sample wisdom instead of trying to generate (requires API)
        return _getSampleDailyWisdom();
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      // Return sample wisdom on error
      return _getSampleDailyWisdom();
    }
  }

  Map<String, dynamic> _getSampleDailyWisdom() {
    final today = DateTime.now();
    final quotes = [
      {
        'quote': 'The journey of a thousand miles begins with a single step.',
        'reflection': 'Every moment is a new beginning. What small step can you take today toward your spiritual growth?',
        'practice_suggestion': 'Take 5 minutes for silent meditation to center yourself.',
      },
      {
        'quote': 'Peace comes from within. Do not seek it without.',
        'reflection': 'True peace is not found in external circumstances, but in the stillness of your own heart.',
        'practice_suggestion': 'Practice 10 minutes of breath awareness meditation.',
      },
      {
        'quote': 'You have power over your mind—not outside events. Realize this, and you will find strength.',
        'reflection': 'When we shift focus from what we cannot control to what we can, we discover our true power.',
        'practice_suggestion': 'Write down three things within your control today.',
      },
      {
        'quote': 'The wound is the place where the Light enters you.',
        'reflection': 'Your challenges and struggles can become sources of strength and wisdom.',
        'practice_suggestion': 'Reflect on a recent challenge and find one lesson it taught you.',
      },
      {
        'quote': 'Be the change you wish to see in the world.',
        'reflection': 'Transformation begins within. As you grow, you naturally inspire others.',
        'practice_suggestion': 'Perform one act of kindness today without expecting anything in return.',
      },
    ];

    final selected = quotes[today.day % quotes.length];
    return {
      'id': 'daily-wisdom-${today.year}-${today.month}-${today.day}',
      'quote': selected['quote'],
      'reflection': selected['reflection'],
      'practice_suggestion': selected['practice_suggestion'],
      'tradition': 'Universal',
      'date': today.toIso8601String(),
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
    try {
      Query query = _versesRef.limit(limit);

      if (traditions != null && traditions.isNotEmpty) {
        query = query.where('tradition', whereIn: traditions);
      }

      final snapshot = await query.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Query timeout'),
      );

      if (snapshot.docs.isEmpty) {
        return _getSampleVerses(traditions: traditions, limit: limit);
      }

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
    } catch (e) {
      return _getSampleVerses(traditions: traditions, limit: limit);
    }
  }

  List<Map<String, dynamic>> _getSampleVerses({
    List<String>? traditions,
    int limit = 20,
  }) {
    final allVerses = [
      {
        'id': 'bhagavad-gita-2-47',
        'verse': 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन',
        'translation': 'You have the right to perform your duty, but you are not entitled to the fruits of your actions.',
        'source': 'Bhagavad Gita',
        'tradition': 'Hinduism',
        'chapter': 'Chapter 2',
        'verse_number': 'Verse 47',
      },
      {
        'id': 'dhammapada-1',
        'verse': 'All that we are is the result of what we have thought.',
        'translation': 'Mind is everything. What you think, you become.',
        'source': 'Dhammapada',
        'tradition': 'Buddhism',
        'chapter': 'Chapter 1',
        'verse_number': 'Verse 1',
      },
      {
        'id': 'bible-john-3-16',
        'verse': 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        'translation': 'Divine love manifested through sacrifice.',
        'source': 'Bible',
        'tradition': 'Christianity',
        'chapter': 'John',
        'verse_number': '3:16',
      },
      {
        'id': 'quran-2-255',
        'verse': 'الله لا إله إلا هو الحي القيوم',
        'translation': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.',
        'source': 'Quran',
        'tradition': 'Islam',
        'chapter': 'Al-Baqarah',
        'verse_number': '255',
      },
      {
        'id': 'psalms-23-1',
        'verse': 'The Lord is my shepherd; I shall not want.',
        'translation': 'Divine guidance provides for all needs.',
        'source': 'Psalms',
        'tradition': 'Judaism',
        'chapter': 'Psalm 23',
        'verse_number': '1',
      },
      {
        'id': 'thirukkural-1',
        'verse': 'அகர முதல எழுத்தெல்லாம் ஆதி',
        'translation': 'All letters begin with A, and all life begins with God.',
        'source': 'Thirukkural',
        'tradition': 'Hinduism',
        'chapter': 'Chapter 1',
        'verse_number': '1',
      },
      {
        'id': 'rumi-1',
        'verse': 'The wound is the place where the Light enters you.',
        'translation': 'Suffering becomes a gateway to enlightenment.',
        'source': 'Rumi',
        'tradition': 'Sufism',
        'chapter': 'Selected Poems',
        'verse_number': null,
      },
      {
        'id': 'tao-te-ching-1',
        'verse': 'The Tao that can be told is not the eternal Tao.',
        'translation': 'True wisdom is beyond words.',
        'source': 'Tao Te Ching',
        'tradition': 'Taoism',
        'chapter': 'Chapter 1',
        'verse_number': '1',
      },
    ];

    var filtered = allVerses;
    if (traditions != null && traditions.isNotEmpty && !traditions.contains('All')) {
      filtered = filtered.where((v) => traditions.contains(v['tradition'])).toList();
    }

    return filtered.take(limit).toList();
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

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    // Create a controller to handle timeout and fallback while keeping stream alive
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    bool hasEmitted = false;
    final sampleData = _getSampleMantras(traditions: traditions, category: category);

    // Start listening to Firestore for real-time updates
    query.snapshots().listen(
      (snapshot) {
        if (!hasEmitted) {
          hasEmitted = true;
        }
        if (snapshot.docs.isEmpty && !hasEmitted) {
          // Only emit sample data if we haven't received anything yet
          controller.add(sampleData);
        } else if (snapshot.docs.isNotEmpty) {
          // Emit real data from Firestore - this will update in real-time
          final mantras = snapshot.docs.map((doc) {
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
          controller.add(mantras);
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

    // Handle timeout for initial connection only
    Timer(const Duration(seconds: 10), () {
      if (!hasEmitted) {
        hasEmitted = true;
        controller.add(sampleData);
      }
    });

    // Return stream that continues listening for real-time updates
    return controller.stream;
  }
}
