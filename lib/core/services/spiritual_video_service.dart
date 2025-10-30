import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for Spiritual Video Hub (Gaia/Soulvana-style)
/// Hosts and streams yoga, healing, meditation, and philosophy videos
class SpiritualVideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('SpiritualVideoService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _videoLibraryRef =>
      _firestore.collection(FirestoreKeys.videoLibrary);

  /// Stream video library with filters (real-time)
  Stream<List<Map<String, dynamic>>> streamVideoLibrary({
    String? category,
    String? teacher,
    List<String>? tags,
    int limit = 50,
  }) {
    Query query = _videoLibraryRef.limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (teacher != null) {
      query = query.where('teacher', isEqualTo: teacher);
    }
    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Get video by ID
  Future<Map<String, dynamic>?> getVideoById(String videoId) async {
    final doc = await _videoLibraryRef.doc(videoId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Get featured videos
  Future<List<Map<String, dynamic>>> getFeaturedVideos({int limit = 10}) async {
    final snapshot = await _videoLibraryRef
        .where('featured', isEqualTo: true)
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

  /// Get videos by teacher
  Stream<List<Map<String, dynamic>>> streamVideosByTeacher(String teacher,
      {int limit = 20}) {
    return _videoLibraryRef
        .where('teacher', isEqualTo: teacher)
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

  /// Get video categories
  Future<List<String>> getVideoCategories() async {
    final snapshot = await _videoLibraryRef.get();
    final categories = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final category = data['category'] as String?;
      if (category != null) categories.add(category);
    }
    return categories.toList()..sort();
  }

  /// Track video watch progress
  Future<void> logVideoWatch({
    required String videoId,
    required int durationWatched, // seconds
    int? totalDuration,
    bool completed = false,
  }) async {
    final uid = _requireUid();
    await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.videoWatches)
        .add({
      'video_id': videoId,
      'duration_watched': durationWatched,
      'total_duration': totalDuration,
      'completed': completed,
      'watched_at': FieldValue.serverTimestamp(),
    });
  }

  /// Stream user's watch history
  Stream<List<Map<String, dynamic>>> streamWatchHistory({int limit = 30}) {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.videoWatches)
        .orderBy('watched_at', descending: true)
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
}
