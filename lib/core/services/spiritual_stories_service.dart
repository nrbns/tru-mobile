import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Service for Spiritual Stories & Parables (daily feed)
/// AI-narrated inspiring stories with reflection questions
class SpiritualStoriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('SpiritualStoriesService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _storiesRef =>
      _firestore.collection(FirestoreKeys.spiritualStories);

  /// Get daily spiritual story (personalized)
  Future<Map<String, dynamic>> getDailyStory({
    String? category,
    String? userMood,
  }) async {
    try {
      // Try to get personalized story via Cloud Function
      final callable = _functions.httpsCallable('getDailySpiritualStory');
      final result = await callable.call({
        'category': category,
        'user_mood': userMood,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      // Fallback to random story
      final snapshot = await _storiesRef.limit(10).get();
      if (snapshot.docs.isEmpty) {
        throw Exception('No stories available');
      }
      final randomDoc =
          snapshot.docs[DateTime.now().day % snapshot.docs.length];
      final data = randomDoc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': randomDoc.id,
        ...data,
      };
    }
  }

  /// Stream stories library (real-time)
  Stream<List<Map<String, dynamic>>> streamStories({
    String? category,
    String? author,
    int limit = 50,
  }) {
    Query query = _storiesRef.limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (author != null) {
      query = query.where('author', isEqualTo: author);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Save story reflection
  Future<void> saveStoryReflection({
    required String storyId,
    required String reflection,
    List<String>? insights,
  }) async {
    final uid = _requireUid();
    await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.storyReflections)
        .add({
      'story_id': storyId,
      'reflection': reflection,
      'insights': insights ?? [],
      'reflected_at': FieldValue.serverTimestamp(),
    });
  }

  /// Stream user's story reflections (real-time)
  Stream<List<Map<String, dynamic>>> streamStoryReflections({int limit = 30}) {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.storyReflections)
        .orderBy('reflected_at', descending: true)
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

  /// Get story categories
  Future<List<String>> getStoryCategories() async {
    final snapshot = await _storiesRef.get();
    final categories = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category'] as String?;
      if (category != null) categories.add(category);
    }
    return categories.toList()..sort();
  }
}
