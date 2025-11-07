import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Crisis & Support Resources Service - Stay Alive/7 Cups-style
/// Full implementation with real-time Firebase integration
class CrisisSupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('CrisisSupportService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _helplinesRef => _firestore.collection('helplines');

  CollectionReference get _safetyPlansRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('safety_plans');
  }

  CollectionReference get _peerSupportChatsRef {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('peer_support_chats');
  }

  /// Get helplines by country
  Future<List<Map<String, dynamic>>> getHelplines({
    String? country,
    bool available24x7 = false,
  }) async {
    Query query = _helplinesRef.limit(100);

    if (country != null) {
      query = query.where('country', isEqualTo: country);
    }

    if (available24x7) {
      query = query.where('available24x7', isEqualTo: true);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'country': data['country'] ?? 'Global',
        'number': data['number'] ?? '',
        'organization': data['organization'] ?? '',
        'available24x7': data['available24x7'] ?? false,
        'type': data['type'] ?? 'crisis', // crisis, support, mental_health
        'description': data['description'],
        ...data,
      };
    }).toList();
  }

  /// Stream helplines for real-time updates
  Stream<List<Map<String, dynamic>>> streamHelplines({
    String? country,
  }) {
    Query query = _helplinesRef.limit(100);

    if (country != null) {
      query = query.where('country', isEqualTo: country);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Call helpline
  Future<void> callHelpline(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch phone call');
    }
  }

  /// Text helpline (SMS)
  Future<void> textHelpline(String phoneNumber, {String? message}) async {
    final uri = Uri.parse(
        'sms:$phoneNumber${message != null ? '?body=${Uri.encodeComponent(message)}' : ''}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch SMS');
    }
  }

  /// Create or update safety plan
  Future<String> saveSafetyPlan({
    required List<String> warningSigns,
    required List<String> contacts,
    required List<String> stepsToStaySafe,
    List<String>? copingStrategies,
    String? emergencyContact,
  }) async {
    // Only allow one active safety plan per user
    final existingPlans =
        await _safetyPlansRef.where('active', isEqualTo: true).get();

    // Deactivate old plans
    for (var doc in existingPlans.docs) {
      await doc.reference.update({'active': false});
    }

    // Create new plan
    final planDoc = await _safetyPlansRef.add({
      'warning_signs': warningSigns,
      'contacts': contacts,
      'steps_to_stay_safe': stepsToStaySafe,
      'coping_strategies': copingStrategies ?? [],
      'emergency_contact': emergencyContact,
      'active': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return planDoc.id;
  }

  /// Get active safety plan
  Stream<Map<String, dynamic>?> streamActiveSafetyPlan() {
    return _safetyPlansRef
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    });
  }

  /// Start peer support chat session
  Future<String> startPeerSupportChat({
    String? topic,
    bool anonymous = false,
  }) async {
    final chatDoc = await _peerSupportChatsRef.add({
      'topic': topic,
      'anonymous': anonymous,
      'status': 'active',
      'started_at': FieldValue.serverTimestamp(),
      'messages': [],
    });

    return chatDoc.id;
  }

  /// Send peer support message
  Future<void> sendPeerSupportMessage({
    required String chatId,
    required String message,
    bool isUser = true,
  }) async {
    await _peerSupportChatsRef.doc(chatId).update({
      'messages': FieldValue.arrayUnion([
        {
          'message': message,
          'is_user': isUser,
          'timestamp': FieldValue.serverTimestamp(),
        }
      ]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Stream peer support chats (real-time)
  Stream<List<Map<String, dynamic>>> streamPeerSupportChats() {
    return _peerSupportChatsRef
        .where('status', isEqualTo: 'active')
        .orderBy('started_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                ...data,
              };
            }).toList());
  }

  /// AI check-in for distress detection
  Future<Map<String, dynamic>> getAICheckin({
    required List<Map<String, dynamic>> recentMoods,
    required List<Map<String, dynamic>> recentJournals,
    String? userMessage,
  }) async {
    try {
      final callable = _functions.httpsCallable('aiCrisisCheckin');
      final result = await callable.call({
        'recent_moods': recentMoods,
        'recent_journals': recentJournals,
        'user_message': userMessage,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Failed to get AI check-in: $e');
    }
  }

  /// Get breathing SOS exercise
  Future<Map<String, dynamic>> getBreathingSOSExercise() async {
    return {
      'type': 'box_breathing',
      'instructions': [
        'Breathe in for 4 counts',
        'Hold for 4 counts',
        'Breathe out for 4 counts',
        'Hold for 4 counts',
        'Repeat 4-5 cycles',
      ],
      'duration_seconds': 60,
      'animation_pattern': 'box', // box, triangle, circle
    };
  }

  /// Get grounding SOS exercise (5-4-3-2-1 method)
  Future<Map<String, dynamic>> getGroundingSOSExercise() async {
    return {
      'type': '54321_grounding',
      'steps': [
        'Name 5 things you can see',
        'Name 4 things you can touch',
        'Name 3 things you can hear',
        'Name 2 things you can smell',
        'Name 1 thing you can taste',
      ],
      'duration_minutes': 5,
    };
  }
}
