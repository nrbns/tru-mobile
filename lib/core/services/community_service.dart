import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Community Service - Opt-in social features and peer support
class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('CommunityService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _postsRef => _firestore.collection('community_posts');
  CollectionReference get _groupsRef => _firestore.collection('support_groups');

  CollectionReference get _userPostsRef {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('community_posts');
  }

  /// Check if user has opted into community features
  Future<bool> isOptedIn() async {
    final uid = _requireUid();
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};
    return data['community_opt_in'] ?? false;
  }

  /// Opt in/out of community features
  Future<void> setOptIn(bool optedIn) async {
    final uid = _requireUid();
    await _firestore.collection('users').doc(uid).update({
      'community_opt_in': optedIn,
      'community_settings': {
        'share_achievements': optedIn,
        'share_progress': false, // Default to false for privacy
        'show_on_leaderboards': false,
        'anonymous_mode': true, // Default to anonymous
      },
    });
  }

  /// Create a community post (privacy-respecting)
  Future<String> createPost({
    required String content,
    String? category, // body, mind, spirit
    bool isAnonymous = true,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = _requireUid();
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};
    final userName = isAnonymous ? 'Anonymous' : (userData['name'] ?? 'User');

    final postRef = await _postsRef.add({
      'user_id': isAnonymous ? null : uid,
      'author_name': userName,
      'content': content,
      'category': category,
      'is_anonymous': isAnonymous,
      'tags': tags ?? [],
      'metadata': metadata ?? {},
      'likes_count': 0,
      'comments_count': 0,
      'created_at': FieldValue.serverTimestamp(),
      'visibility': 'public',
    });

    // Also save to user's posts
    await _userPostsRef.doc(postRef.id).set({
      'post_id': postRef.id,
      'created_at': FieldValue.serverTimestamp(),
    });

    return postRef.id;
  }

  /// Get community feed (opt-in users only)
  Stream<List<Map<String, dynamic>>> streamCommunityFeed({
    String? category,
    int limit = 20,
  }) {
    Query query = _postsRef
        .where('visibility', isEqualTo: 'public')
        .orderBy('created_at', descending: true)
        .limit(limit);

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

  /// Like a post
  Future<void> likePost(String postId) async {
    final uid = _requireUid();
    await _postsRef.doc(postId).update({
      'likes_count': FieldValue.increment(1),
    });

    // Record like in user's interactions
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('community_interactions')
        .doc(postId)
        .set({
      'post_id': postId,
      'interaction_type': 'like',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Comment on a post
  Future<void> commentPost({
    required String postId,
    required String comment,
    bool isAnonymous = true,
  }) async {
    final uid = _requireUid();
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};
    final userName = isAnonymous ? 'Anonymous' : (userData['name'] ?? 'User');

    await _postsRef.doc(postId).collection('comments').add({
      'user_id': isAnonymous ? null : uid,
      'author_name': userName,
      'content': comment,
      'is_anonymous': isAnonymous,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Update comment count
    await _postsRef.doc(postId).update({
      'comments_count': FieldValue.increment(1),
    });
  }

  /// Join a support group
  Future<void> joinSupportGroup(String groupId) async {
    final uid = _requireUid();
    await _groupsRef.doc(groupId).collection('members').doc(uid).set({
      'joined_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get available support groups
  Future<List<Map<String, dynamic>>> getSupportGroups() async {
    final snapshot = await _groupsRef.where('active', isEqualTo: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Share achievement (if opted in)
  Future<void> shareAchievement({
    required String achievementId,
    required String achievementName,
  }) async {
    if (!await isOptedIn()) return;

    final settings = await getCommunitySettings();
    if (settings['share_achievements'] != true) return;

    await createPost(
      content: 'I just unlocked: $achievementName! 🎉',
      category: 'milestone',
      isAnonymous: settings['anonymous_mode'] ?? true,
      tags: ['achievement', achievementId],
    );
  }

  /// Get community settings
  Future<Map<String, dynamic>> getCommunitySettings() async {
    final uid = _requireUid();
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};
    return data['community_settings'] as Map<String, dynamic>? ?? {};
  }

  /// Update community settings
  Future<void> updateCommunitySettings(Map<String, dynamic> settings) async {
    final uid = _requireUid();
    await _firestore.collection('users').doc(uid).update({
      'community_settings': settings,
    });
  }
}
