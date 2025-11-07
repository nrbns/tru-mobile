import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agent_engines/mind_engine.dart';
import 'agent_engines/body_engine.dart';

/// Energy Pulse System - Visual bar showing mind-body balance (chakra-like)
class EnergyPulseService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final MindEngine _mindEngine;
  final BodyEngine _bodyEngine;
  final String? _uid;

  EnergyPulseService(this._db, this._auth, this._mindEngine, this._bodyEngine)
      : _uid = _auth.currentUser?.uid;

  /// Calculate daily energy pulse (mind-body balance)
  Future<EnergyPulse> calculateDailyPulse() async {
    // Get mind energy
    final emotionalState = await _mindEngine.analyzeEmotionalState();
    final mindEnergy = (1.0 - emotionalState.stressLevel) * emotionalState.energyLevel;

    // Get body energy
    final bodyState = await _bodyEngine.getCurrentBodyState();
    final bodyEnergy = _calculateBodyEnergy(bodyState);

    // Overall balance
    final overallBalance = (mindEnergy + bodyEnergy) / 2;

    // Determine pulse state
    final pulseState = _determinePulseState(overallBalance, mindEnergy, bodyEnergy);

    return EnergyPulse(
      mindEnergy: mindEnergy,
      bodyEnergy: bodyEnergy,
      overallBalance: overallBalance,
      state: pulseState,
      timestamp: DateTime.now(),
    );
  }

  double _calculateBodyEnergy(BodyState bodyState) {
    // Normalize body metrics
    final stepsNormalized = (bodyState.steps / 10000).clamp(0.0, 1.0);
    final waterNormalized = (bodyState.waterMl / 3000).clamp(0.0, 1.0);
    final calorieBalance = bodyState.caloriesConsumed > 0
        ? (bodyState.caloriesConsumed / (bodyState.caloriesBurned + 1000)).clamp(0.0, 1.0)
        : 0.5;

    // Recovery factor
    double recoveryFactor = 1.0;
    switch (bodyState.recoveryStatus) {
      case RecoveryStatus.needRest:
        recoveryFactor = 0.3;
        break;
      case RecoveryStatus.recovering:
        recoveryFactor = 0.6;
        break;
      case RecoveryStatus.recovered:
        recoveryFactor = 1.0;
        break;
      case RecoveryStatus.maintaining:
        recoveryFactor = 0.8;
        break;
      case RecoveryStatus.unknown:
        recoveryFactor = 0.5;
    }

    return ((stepsNormalized + waterNormalized + calorieBalance) / 3) * recoveryFactor;
  }

  PulseState _determinePulseState(double overall, double mind, double body) {
    if (overall >= 0.8 && mind >= 0.7 && body >= 0.7) {
      return PulseState.peak;
    }
    if (overall >= 0.6) {
      return PulseState.balanced;
    }
    if (overall >= 0.4) {
      return PulseState.low;
    }
    return PulseState.critical;
  }

  /// Get pulse history for visualization
  Future<List<EnergyPulse>> getPulseHistory({int days = 7}) async {
    if (_uid == null) return [];
    
    final since = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('energy_pulse')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return EnergyPulse(
        mindEnergy: (data['mindEnergy'] as num?)?.toDouble() ?? 0.5,
        bodyEnergy: (data['bodyEnergy'] as num?)?.toDouble() ?? 0.5,
        overallBalance: (data['overallBalance'] as num?)?.toDouble() ?? 0.5,
        state: PulseState.values.firstWhere(
          (s) => s.name == data['state'],
          orElse: () => PulseState.balanced,
        ),
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  /// Save daily pulse
  Future<void> saveDailyPulse(EnergyPulse pulse) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('energy_pulse').add({
      'mindEnergy': pulse.mindEnergy,
      'bodyEnergy': pulse.bodyEnergy,
      'overallBalance': pulse.overallBalance,
      'state': pulse.state.name,
      'timestamp': Timestamp.fromDate(pulse.timestamp),
    });
  }
}

class EnergyPulse {
  final double mindEnergy; // 0.0 to 1.0
  final double bodyEnergy; // 0.0 to 1.0
  final double overallBalance; // 0.0 to 1.0
  final PulseState state;
  final DateTime timestamp;

  EnergyPulse({
    required this.mindEnergy,
    required this.bodyEnergy,
    required this.overallBalance,
    required this.state,
    required this.timestamp,
  });
}

enum PulseState {
  peak,      // Green - High energy, balanced
  balanced,  // Yellow - Moderate, stable
  low,       // Orange - Needs attention
  critical,  // Red - Intervention needed
}

