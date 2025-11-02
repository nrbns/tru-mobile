import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/agent_intent.dart';
import '../models/agent_inbox.dart';
import '../models/discipline_contract.dart';
import 'telemetry_channel.dart';

/// Service for agent operations (intents, chat, contracts)
class AgentService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final TelemetryChannel _telemetry;

  AgentService(this._db, this._auth) : _telemetry = TelemetryChannel();

  String? get _uid => _auth.currentUser?.uid;

  /// Get agent intents (suggestions) based on context
  /// This would typically call a backend function or use local rules
  Future<List<AgentIntent>> getIntents({
    DateTime? timeOfDay,
    double? stressLevel,
    int? missedSessions,
    int? currentStreak,
  }) async {
    // TODO: Replace with real backend call or rules engine
    // For now, return mock intents based on context
    final now = DateTime.now();
    final hour = now.hour;
    final intents = <AgentIntent>[];

    // Morning rule: Low sleep + High stress → Breath reset
    if (hour >= 6 && hour < 10 && (stressLevel ?? 0.5) > 0.7) {
      intents.add(AgentIntent(
        intentId: 'breath_reset_10',
        title: '10-min Breath Reset',
        subtitle: 'Start your day with calm',
        cta: 'Begin',
        icon: 'self_improvement',
        priority: 0.92,
        expiresInSec: 900,
        metadata: {'route': '/agent/overlay', 'type': 'breath'},
      ));
    }

    // Evening rule: High steps + Low calories → Protein dinner
    if (hour >= 18 && hour < 22) {
      intents.add(AgentIntent(
        intentId: 'protein_dinner',
        title: 'Protein Dinner Plan',
        subtitle: 'Fuel recovery with smart nutrition',
        cta: 'Explore',
        icon: 'restaurant',
        priority: 0.75,
        expiresInSec: 3600,
        metadata: {'route': '/home/meal-planner'},
      ));
    }

    // Accountability check-in
    if ((missedSessions ?? 0) >= 2) {
      intents.add(AgentIntent(
        intentId: 'accountability_check',
        title: 'Accountability Check-in',
        subtitle: 'Let\'s realign your goals',
        cta: 'Talk',
        icon: 'chat',
        priority: 0.95,
        expiresInSec: null,
        metadata: {'route': '/agent/chat'},
      ));
    }

    // Sort by priority
    intents.sort((a, b) => b.priority.compareTo(a.priority));
    return intents.take(3).toList();
  }

  /// Send message to agent and get response
  Future<String> sendMessage(String text, {String? persona}) async {
    if (_uid == null) throw Exception('Not authenticated');

    // TODO: Call backend AI function
    // For now, return mock response
    await Future.delayed(const Duration(milliseconds: 500));
    return 'I understand. Let\'s work through this together.';
  }

  /// Save message to inbox
  Future<void> saveMessage(AgentMessage message) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('agent_inbox')
        .add(message.toJson());
  }

  /// Get inbox messages
  Stream<List<AgentMessage>> streamInbox() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('agent_inbox')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AgentMessage.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Save discipline contract
  Future<void> saveContract(DisciplineContract contract) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('contracts')
        .doc(contract.id)
        .set(contract.toJson());
    _telemetry.contractSigned(contract);
  }

  /// Get active contracts
  Stream<List<DisciplineContract>> streamContracts() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('contracts')
        .where('signedAt', isNotEqualTo: null)
        .where('violatedAt', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DisciplineContract.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Accept an intent (user taps "Start")
  void acceptIntent(AgentIntent intent) {
    _telemetry.intentAccepted(intent);
  }

  /// Dismiss an intent
  void dismissIntent(String intentId) {
    _telemetry.intentDismissed(intentId);
  }
}

