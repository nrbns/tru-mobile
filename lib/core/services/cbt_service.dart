import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// CBT & Mental Health Support Service - Wysa/MindShift-style
/// Full implementation with real-time Firebase integration
class CBTService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('CBTService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _cbtExercisesRef =>
      _firestore.collection('cbt_exercises');

  CollectionReference get _therapyChatsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('therapy_chats');
  }

  CollectionReference get _cbtJournalsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('cbt_journals');
  }

  /// Get CBT exercises library
  Future<List<Map<String, dynamic>>> getCBTExercises({
    String? type, // journal, reframing, grounding, breathing
    List<String>? tags,
    int limit = 50,
  }) async {
    Query query = _cbtExercisesRef.limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
        'type': data['type'] ?? 'journal',
        'duration': data['duration'] ?? 15,
        'tags': List<String>.from(data['tags'] ?? []),
        'instructions': data['instructions'] ?? [],
        ...data,
      };
    }).toList();
  }

  /// Stream CBT exercises for real-time updates
  Stream<List<Map<String, dynamic>>> streamCBTExercises({
    String? type,
    int limit = 50,
  }) {
    Query query = _cbtExercisesRef.limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Save CBT journal entry
  Future<String> saveCBTJournal({
    required String situation,
    required String thoughts,
    required String feelings,
    String? evidence,
    String? alternativePerspective,
    String? voiceUrl,
    Map<String, dynamic>? aiAnalysis,
  }) async {
    final journalDoc = await _cbtJournalsRef.add({
      'situation': situation,
      'thoughts': thoughts,
      'feelings': feelings,
      'evidence': evidence,
      'alternative_perspective': alternativePerspective,
      'voice_url': voiceUrl,
      'ai_analysis': aiAnalysis,
      'created_at': FieldValue.serverTimestamp(),
      'date':
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    });

    return journalDoc.id;
  }

  /// Get CBT journal entries (real-time)
  Stream<List<Map<String, dynamic>>> streamCBTJournals({int limit = 30}) {
    return _cbtJournalsRef
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

  /// Get AI therapy response (CBT-guided chat)
  Future<Map<String, dynamic>> getAITherapyResponse({
    required String userMessage,
    String? context, // Previous conversation context
    List<Map<String, dynamic>>? recentJournals, // For context
  }) async {
    try {
      final callable = _functions.httpsCallable('aiTherapyChat');
      final result = await callable.call({
        'message': userMessage,
        'context': context,
        'recent_journals': recentJournals,
      });

      final response = Map<String, dynamic>.from(result.data);

      // Save therapy chat to Firestore
      await _therapyChatsRef.add({
        'user_message': userMessage,
        'ai_response': response['response'] ?? '',
        'suggestions': response['suggestions'] ?? [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      return response;
    } catch (e) {
      throw Exception('Failed to get therapy response: $e');
    }
  }

  /// Stream therapy chats (real-time)
  Stream<List<Map<String, dynamic>>> streamTherapyChats({int limit = 50}) {
    return _therapyChatsRef
        .orderBy('timestamp', descending: true)
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

  /// Get breathing exercises
  Future<List<Map<String, dynamic>>> getBreathingExercises() async {
    return getCBTExercises(
      type: 'breathing',
      tags: ['breathing', 'grounding'],
    );
  }

  /// Get grounding exercises
  Future<List<Map<String, dynamic>>> getGroundingExercises() async {
    return getCBTExercises(
      type: 'grounding',
      tags: ['grounding', 'anxiety'],
    );
  }

  /// Get CBT statistics
  Future<Map<String, dynamic>> getCBTStats() async {
    final journalsSnapshot = await _cbtJournalsRef.get();
    final chatsSnapshot = await _therapyChatsRef.get();

    String? lastJournalDate;
    if (journalsSnapshot.docs.isNotEmpty) {
      final firstData =
          journalsSnapshot.docs.first.data() as Map<String, dynamic>? ?? {};
      lastJournalDate = firstData['date'] as String?;
    } else {
      lastJournalDate = null;
    }

    return {
      'total_journals': journalsSnapshot.docs.length,
      'total_therapy_sessions': chatsSnapshot.docs.length,
      'last_journal_date': lastJournalDate,
    };
  }
}
