import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Challenge Service - Community challenges for body, mind, spirit
class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _challengesRef => _firestore.collection('challenges');

  CollectionReference get _userChallengesRef {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('ChallengeService: no authenticated user');
    }
    final uid = currentUser.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('challenge_progress');
  }

  /// Get available challenges
  Future<List<Map<String, dynamic>>> getAvailableChallenges({
    String? category, // body, mind, spirit, combined
    String? difficulty,
    int limit = 20,
  }) async {
    Query query = _challengesRef.where('active', isEqualTo: true).limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
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

  /// Stream available challenges
  Stream<List<Map<String, dynamic>>> streamChallenges(
      {String? category, int limit = 20}) {
    Query query = _challengesRef.where('active', isEqualTo: true).limit(limit);

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

  /// Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    await _userChallengesRef.doc(challengeId).set({
      'challenge_id': challengeId,
      'joined_at': FieldValue.serverTimestamp(),
      'status': 'active',
      'progress': 0,
      'completed_days': [],
    });
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress({
    required String challengeId,
    required int progress,
    bool? dayCompleted,
  }) async {
    final updates = <String, dynamic>{
      'progress': progress,
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (dayCompleted == true) {
      final today = DateTime.now();
      final dayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      updates['completed_days'] = FieldValue.arrayUnion([dayKey]);
    }

    await _userChallengesRef.doc(challengeId).update(updates);
  }

  /// Get user's active challenges
  Stream<List<Map<String, dynamic>>> streamUserChallenges() {
    return _userChallengesRef
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snapshot) async {
      final challenges = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final progressData = doc.data() as Map<String, dynamic>? ?? {};
        final challengeId = progressData['challenge_id'] as String?;

        if (challengeId == null) continue;

        final challengeDoc = await _challengesRef.doc(challengeId).get();
        if (challengeDoc.exists) {
          final challengeData =
              challengeDoc.data() as Map<String, dynamic>? ?? {};
          challenges.add({
            'id': challengeId,
            'progress': progressData['progress'] ?? 0,
            'joined_at': progressData['joined_at'],
            'completed_days': progressData['completed_days'] ?? [],
            ...challengeData,
          });
        }
      }

      return challenges;
    });
  }

  /// Complete challenge
  Future<void> completeChallenge(String challengeId) async {
    await _userChallengesRef.doc(challengeId).update({
      'status': 'completed',
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get challenge leaderboard (optional, with privacy)
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId, {
    int limit = 50,
  }) async {
    // Only show users who opted into leaderboards
    // Note: This query may need an index in Firestore
    final snapshot = await _firestore
        .collectionGroup('challenge_progress')
        .where('challenge_id', isEqualTo: challengeId)
        .where('status', isEqualTo: 'active')
        .orderBy('progress', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'user_id': doc.reference.parent.parent!.id,
        ...data,
      };
    }).toList();
  }

  /// Stream challenge leaderboard for real-time updates
  Stream<List<Map<String, dynamic>>> streamChallengeLeaderboard(
    String challengeId, {
    int limit = 50,
  }) {
    return _firestore
        .collectionGroup('challenge_progress')
        .where('challenge_id', isEqualTo: challengeId)
        .where('status', isEqualTo: 'active')
        .orderBy('progress', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'user_id': doc.reference.parent.parent!.id,
                'rank': snapshot.docs.indexOf(doc) + 1,
                ...data,
              };
            }).toList());
  }

  /// Create custom challenge (user-created)
  Future<String> createCustomChallenge({
    required String title,
    required String description,
    required int durationDays,
    required String category,
    required Map<String, dynamic> metrics, // What to track
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('ChallengeService: no authenticated user');
    }
    final uid = currentUser.uid;
    final docRef = await _challengesRef.add({
      'title': title,
      'description': description,
      'duration_days': durationDays,
      'category': category,
      'metrics': metrics,
      'created_by': uid,
      'active': true,
      'is_community': true,
      'participants_count': 1,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Auto-join creator
    await joinChallenge(docRef.id);

    return docRef.id;
  }
}
