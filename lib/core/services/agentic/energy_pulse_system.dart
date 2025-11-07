import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Energy Pulse System: Visual representation of mind-body balance (chakra-like)
class EnergyPulseSystem {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  EnergyPulseSystem(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  /// Calculate energy pulse from all domains
  Future<EnergyPulse> calculateEnergyPulse({
    double? physicalEnergy,
    double? mentalEnergy,
    double? emotionalEnergy,
    double? spiritualEnergy,
  }) async {
    if (_uid == null) {
      return EnergyPulse(
        physical: 0.5,
        mental: 0.5,
        emotional: 0.5,
        spiritual: 0.5,
        overall: 0.5,
      );
    }

    // Fetch or calculate from biometrics
    final physical = physicalEnergy ?? await _calculatePhysicalEnergy();
    final mental = mentalEnergy ?? await _calculateMentalEnergy();
    final emotional = emotionalEnergy ?? await _calculateEmotionalEnergy();
    final spiritual = spiritualEnergy ?? await _calculateSpiritualEnergy();

    final overall = (physical + mental + emotional + spiritual) / 4.0;

    return EnergyPulse(
      physical: physical,
      mental: mental,
      emotional: emotional,
      spiritual: spiritual,
      overall: overall,
    );
  }

  /// Get chakra representation (7 chakras mapping to domains)
  Future<ChakraState> getChakraState(EnergyPulse pulse) async {
    return ChakraState(
      root: pulse.physical, // Physical grounding
      sacral: pulse.physical * 0.8, // Creativity/flow
      solarPlexus: pulse.physical * 0.9, // Willpower
      heart: pulse.emotional, // Love/connection
      throat: pulse.mental * 0.7, // Communication
      thirdEye: pulse.mental, // Intuition
      crown: pulse.spiritual, // Spirituality/connection
    );
  }

  /// Visualize as battery-style or chakra-style
  String getVisualizationStyle(EnergyPulse pulse) {
    if (pulse.overall > 0.8) return 'high_energy';
    if (pulse.overall > 0.6) return 'balanced';
    if (pulse.overall > 0.4) return 'low_energy';
    return 'depleted';
  }

  Future<double> _calculatePhysicalEnergy() async {
    // Based on recent workouts, sleep, HRV
    final recentWorkouts = await _db
        .collection('users')
        .doc(_uid)
        .collection('workout_sessions')
        .where('completed', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    if (recentWorkouts.docs.isEmpty) return 0.5;

    // More workouts = higher physical energy (simplified)
    return (recentWorkouts.docs.length / 3).clamp(0.3, 1.0);
  }

  Future<double> _calculateMentalEnergy() async {
    // Based on mood logs, journal entries, cognitive load
    final recentMoods = await _db
        .collection('users')
        .doc(_uid)
        .collection('mood_logs')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .get();

    if (recentMoods.docs.isEmpty) return 0.5;

    // Average mood score (assuming 1-10 scale)
    final moods = recentMoods.docs
        .map((doc) => (doc.data()['mood_score'] as num?)?.toDouble() ?? 5.0)
        .toList();
    final avg = moods.reduce((a, b) => a + b) / moods.length;

    return (avg / 10).clamp(0.0, 1.0);
  }

  Future<double> _calculateEmotionalEnergy() async {
    // Based on stress, gratitude, social connections
    final recentStress = await _db
        .collection('users')
        .doc(_uid)
        .collection('stress_logs')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .get();

    if (recentStress.docs.isEmpty) return 0.5;

    final stressLevels = recentStress.docs
        .map((doc) => (doc.data()['stress'] as num?)?.toDouble() ?? 0.5)
        .toList();
    final avgStress = stressLevels.reduce((a, b) => a + b) / stressLevels.length;

    return (1.0 - avgStress).clamp(0.0, 1.0);
  }

  Future<double> _calculateSpiritualEnergy() async {
    // Based on meditation, gratitude, rituals
    final recentPractices = await _db
        .collection('users')
        .doc(_uid)
        .collection('spiritual_practices')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .get();

    if (recentPractices.docs.isEmpty) return 0.5;

    return (recentPractices.docs.length / 7).clamp(0.3, 1.0);
  }
}

class EnergyPulse {
  final double physical; // 0.0 to 1.0
  final double mental; // 0.0 to 1.0
  final double emotional; // 0.0 to 1.0
  final double spiritual; // 0.0 to 1.0
  final double overall; // Average

  EnergyPulse({
    required this.physical,
    required this.mental,
    required this.emotional,
    required this.spiritual,
    required this.overall,
  });
}

class ChakraState {
  final double root;
  final double sacral;
  final double solarPlexus;
  final double heart;
  final double throat;
  final double thirdEye;
  final double crown;

  ChakraState({
    required this.root,
    required this.sacral,
    required this.solarPlexus,
    required this.heart,
    required this.throat,
    required this.thirdEye,
    required this.crown,
  });
}

