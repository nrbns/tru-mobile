import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import '../models/affirmation.dart';
import '../utils/firestore_keys.dart';

/// Service for Reiki & Healing Practices
/// Guided visualizations, affirmations, sound healing
class AffirmationsHealingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('AffirmationsHealingService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _affirmationsRef =>
      _firestore.collection(FirestoreKeys.affirmations);
  CollectionReference get _soundHealingRef =>
      _firestore.collection(FirestoreKeys.soundHealing);

  /// Stream affirmations library (real-time)
  Stream<List<Affirmation>> streamAffirmations({
    String? type, // 'healing', 'confidence', 'abundance', etc.
    String? category,
    int limit = 50,
  }) {
    Query query = _affirmationsRef.limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Affirmation.fromMap(
            doc.id, doc.data() as Map<String, dynamic>? ?? {}))
        .toList());
  }

  /// Get affirmation by ID
  Future<Map<String, dynamic>?> getAffirmationById(String affirmationId) async {
    final doc = await _affirmationsRef.doc(affirmationId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      ...data,
    };
  }

  /// Play affirmation audio
  Future<void> playAffirmation(String audioUrl) async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play affirmation: $e');
    }
  }

  /// Stop affirmation audio
  Future<void> stopAffirmation() async {
    await _audioPlayer.stop();
  }

  /// Log affirmation session
  Future<void> logAffirmationSession({
    required String affirmationId,
    required int repeatCount,
    int? focusScore,
  }) async {
    final uid = _requireUid();
    await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.affirmationSessions)
        .add({
      'affirmation_id': affirmationId,
      'repeat_count': repeatCount,
      'focus_score': focusScore,
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Stream sound healing tracks (real-time)
  Stream<List<Map<String, dynamic>>> streamSoundHealingTracks({
    String? frequency, // '432Hz', '528Hz', 'Solfeggio', etc.
    String? purpose, // 'meditation', 'healing', 'sleep', etc.
    int limit = 30,
  }) {
    Query query = _soundHealingRef.limit(limit);

    if (frequency != null) {
      query = query.where('frequency', isEqualTo: frequency);
    }
    if (purpose != null) {
      query = query.where('purpose', isEqualTo: purpose);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Play sound healing track
  Future<void> playSoundHealing(String audioUrl) async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play sound healing: $e');
    }
  }

  /// Get guided visualization scripts
  Future<List<Map<String, dynamic>>> getGuidedVisualizations({
    String? theme, // 'chakra', 'nature', 'healing', etc.
    int limit = 20,
  }) async {
    Query query = _firestore.collection('guided_visualizations').limit(limit);

    if (theme != null) {
      query = query.where('theme', isEqualTo: theme);
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

  /// Get affirmation types
  Future<List<String>> getAffirmationTypes() async {
    final snapshot = await _affirmationsRef.get();
    final types = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final type = data['type'] as String?;
      if (type != null) types.add(type);
    }
    return types.toList()..sort();
  }

  /// Get recent affirmation sessions
  Stream<List<Map<String, dynamic>>> streamRecentAffirmationSessions(
      {int limit = 20}) {
    final uid = _requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.affirmationSessions)
        .orderBy('completed_at', descending: true)
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

  void dispose() {
    _audioPlayer.dispose();
  }
}
