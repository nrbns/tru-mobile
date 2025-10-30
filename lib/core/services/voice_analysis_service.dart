import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for analyzing voice transcripts using AI (ChatGPT/Gemini)
/// Extracts mood, emotions, thoughts, and CBT insights
class VoiceAnalysisService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('VoiceAnalysisService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Analyze voice transcript for CBT journal entry
  Future<Map<String, dynamic>> analyzeTranscript({
    required String transcript,
    String? audioUrl,
  }) async {
    try {
      final callable = _functions.httpsCallable('analyze-voice-transcript');
      final result = await callable.call({
        'transcript': transcript,
        'audio_url': audioUrl,
      });

      final analysis = result.data as Map<String, dynamic>;

      // Save analysis to Firestore
      await _saveAnalysisToFirestore(transcript, analysis, audioUrl);

      return analysis;
    } catch (e) {
      throw Exception('Failed to analyze transcript: $e');
    }
  }

  /// Save voice analysis to Firestore
  Future<void> _saveAnalysisToFirestore(
    String transcript,
    Map<String, dynamic> analysis,
    String? audioUrl,
  ) async {
    final uid = _requireUid();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('voice_analyses')
        .add({
      'transcript': transcript,
      'audio_url': audioUrl,
      'analysis': analysis,
      'created_at': FieldValue.serverTimestamp(),
      'mood_score': analysis['mood_score'] ?? 5,
      'emotions': analysis['emotions'] ?? [],
      'thoughts': analysis['thoughts'] ?? [],
      'cbt_insights': analysis['cbt_insights'] ?? [],
      'situation': analysis['situation'] ?? '',
      'alternative_perspective': analysis['alternative_perspective'] ?? '',
    });
  }

  /// Get voice analysis history
  Future<List<Map<String, dynamic>>> getAnalysisHistory(
      {int limit = 20}) async {
    final uid = _requireUid();

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('voice_analyses')
        .orderBy('created_at', descending: true)
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

  /// Stream voice analyses for real-time updates
  Stream<List<Map<String, dynamic>>> streamAnalyses({int limit = 20}) {
    final uid = _requireUid();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('voice_analyses')
        .orderBy('created_at', descending: true)
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
