import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wisdom_service.dart';
import '../models/daily_wisdom.dart';

const String? kWisdomFunctionUrl = null;

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final wisdomServiceProvider = Provider<WisdomService>((ref) {
  final db = ref.read(firebaseFirestoreProvider);
  final auth = ref.read(firebaseAuthProvider);
  final endpoint =
      (kWisdomFunctionUrl == null) ? null : Uri.tryParse(kWisdomFunctionUrl!);
  return WisdomService(db, auth, functionEndpoint: endpoint);
});

final dailyWisdomProvider =
    FutureProvider.family<DailyWisdom, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.read(wisdomServiceProvider);
  return service.getDailyWisdom(
    mood: params['mood'] as String?,
    spiritualPath: params['spiritualPath'] as String?,
    category: params['category'] as String?,
  );
});

/// Stream provider for the wisdom library (supports optional filters via family)
final wisdomLibraryProvider =
    StreamProvider.family<List<DailyWisdom>, Map<String, dynamic>>(
        (ref, params) {
  final svc = ref.read(wisdomServiceProvider);
  return svc.wisdomLibraryStream(
    category: params['category'] as String?,
    source: params['source'] as String?,
    limit: params['limit'] as int? ?? 50,
  );
});

final savedWisdomStreamProvider = StreamProvider<List<DailyWisdom>>((ref) {
  final svc = ref.read(wisdomServiceProvider);
  return svc.savedWisdomStream();
});

final wisdomReflectionsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final svc = ref.read(wisdomServiceProvider);
  return svc.wisdomReflectionsStream();
});

final wisdomSourcesProvider = FutureProvider<List<String>>((ref) async {
  final svc = ref.read(wisdomServiceProvider);
  return svc.getSources();
});

final wisdomCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final svc = ref.read(wisdomServiceProvider);
  return svc.getCategories();
});

final wisdomStreakProvider = StreamProvider<int>((ref) {
  // Simple streak: number of distinct applied_wisdom entries.
  final auth = ref.read(firebaseAuthProvider);
  final uid = auth.currentUser?.uid;
  if (uid == null) return Stream<int>.value(0);
  final col = ref
      .read(firebaseFirestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('applied_wisdom');
  return col.snapshots().map((s) => s.docs.length);
});

/// Legends provider: filters wisdom by author (if provided) and returns a stream.
final legendsWisdomProvider =
    StreamProvider.family<List<DailyWisdom>, Map<String, dynamic>>(
        (ref, params) {
  final author = params['author'] as String?;
  final limit = params['limit'] as int? ?? 50;
  Query col = ref
      .read(firebaseFirestoreProvider)
      .collection('wisdom')
      .where('published', isEqualTo: true)
      .limit(limit);
  if (author != null && author.isNotEmpty) {
    col = col.where('author', isEqualTo: author);
  }
  // Create controller for real-time stream with timeout handling
  final controller = StreamController<List<DailyWisdom>>.broadcast();
  bool hasEmitted = false;
  final sampleData = _getSampleWisdom(author: author, limit: limit);

  // Start listening to Firestore for real-time updates
  col.snapshots().listen(
    (snap) {
      if (!hasEmitted) {
        hasEmitted = true;
      }
      if (snap.docs.isEmpty && !hasEmitted) {
        // Only emit sample data if we haven't received anything yet
        controller.add(sampleData);
      } else if (snap.docs.isNotEmpty) {
        // Emit real data from Firestore - updates in real-time
        final wisdom = snap.docs
            .map((d) =>
                DailyWisdom.fromMap(d.id, d.data() as Map<String, dynamic>? ?? {}))
            .toList();
        controller.add(wisdom);
      } else {
        // Empty snapshot but already emitted - emit empty list
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
});

List<DailyWisdom> _getSampleWisdom({String? author, int limit = 50}) {
  final allWisdom = [
    DailyWisdom(
      id: 'sample-1',
      translation: 'The journey of a thousand miles begins with a single step.',
      verse: null,
      meaning: 'Every great accomplishment starts with taking action.',
      source: 'Tao Te Ching',
      author: 'Lao Tzu',
      tags: const ['action', 'beginning'],
      servedAt: DateTime.now(),
      category: 'Tao',
    ),
    DailyWisdom(
      id: 'sample-2',
      translation: 'The only way to do great work is to love what you do.',
      verse: null,
      meaning: 'Passion drives excellence and fulfillment.',
      source: 'Stanford Commencement',
      author: 'Steve Jobs',
      tags: const ['passion', 'work'],
      servedAt: DateTime.now(),
      category: 'Modern',
    ),
    DailyWisdom(
      id: 'sample-3',
      translation: 'Be the change you wish to see in the world.',
      verse: null,
      meaning: 'Personal transformation leads to global change.',
      source: 'Autobiography',
      author: 'Gandhi',
      tags: const ['change', 'action'],
      servedAt: DateTime.now(),
      category: 'Modern',
    ),
    DailyWisdom(
      id: 'sample-4',
      translation: 'You have power over your mind—not outside events. Realize this, and you will find strength.',
      verse: null,
      meaning: 'Inner peace comes from controlling your reactions.',
      source: 'Meditations',
      author: 'Marcus Aurelius',
      tags: const ['stoic', 'mind'],
      servedAt: DateTime.now(),
      category: 'Stoic',
    ),
    DailyWisdom(
      id: 'sample-5',
      translation: 'Excellence is never an accident. It is always the result of high intention, sincere effort, and intelligent execution.',
      verse: null,
      meaning: 'Greatness requires deliberate practice and dedication.',
      source: 'Wings of Fire',
      author: 'APJ Abdul Kalam',
      tags: const ['excellence', 'dedication'],
      servedAt: DateTime.now(),
      category: 'Modern',
    ),
  ];

  if (author != null && author.isNotEmpty) {
    final filtered = allWisdom.where((w) => w.author == author).toList();
    return filtered.take(limit).toList();
  }

  return allWisdom.take(limit).toList();
}
