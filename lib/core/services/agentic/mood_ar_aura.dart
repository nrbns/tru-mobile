import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../agentic/energy_pulse_system.dart';

/// Mood AR Aura: Visualize emotional energy around avatar in AR
class MoodARAura {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final EnergyPulseSystem _energyPulse;

  MoodARAura(this._db, this._auth) : _energyPulse = EnergyPulseSystem(_db, _auth);

  String? get _uid => _auth.currentUser?.uid;

  /// Generate AR aura visualization data based on emotional state
  Future<AuraVisualization> generateAura({
    required double stressLevel,
    required double energyLevel,
    required double emotionalState,
    Map<String, dynamic>? chakraState,
  }) async {
    // Calculate overall aura color based on energy and stress
    final auraColor = _calculateAuraColor(stressLevel, energyLevel, emotionalState);
    final auraIntensity = _calculateIntensity(stressLevel, energyLevel);
    final auraPattern = _calculatePattern(emotionalState, chakraState);

    return AuraVisualization(
      primaryColor: auraColor,
      intensity: auraIntensity,
      pattern: auraPattern,
      pulsing: stressLevel > 0.6, // High stress = pulsing/chaotic
      size: energyLevel.clamp(0.5, 1.5), // Aura size reflects energy
      timestamp: DateTime.now(),
    );
  }

  /// Calculate aura color from emotional state
  String _calculateAuraColor(double stress, double energy, double emotion) {
    // Color mapping based on emotional spectrum
    if (stress > 0.7) {
      return 'red_orange'; // High stress = red/orange
    }
    if (emotion > 0.7 && energy > 0.7) {
      return 'gold_yellow'; // High positive emotion + energy = gold
    }
    if (emotion > 0.6) {
      return 'green_blue'; // Calm/content = green-blue
    }
    if (energy > 0.7) {
      return 'purple_violet'; // High energy = purple
    }
    if (energy < 0.3) {
      return 'gray_blue'; // Low energy = muted
    }
    return 'white_soft'; // Neutral = soft white
  }

  /// Calculate aura intensity (brightness)
  double _calculateIntensity(double stress, double energy) {
    // Higher energy = brighter, but high stress can also increase intensity
    if (stress > 0.7) return 0.9; // Stress can make aura intense/chaotic
    return energy.clamp(0.3, 0.8); // Normal energy range
  }

  /// Calculate aura pattern (flow, swirl, static, chaotic)
  String _calculatePattern(double emotion, Map<String, dynamic>? chakra) {
    if (chakra != null) {
      // Balanced chakras = smooth flow
      final chakraBalance = _checkChakraBalance(chakra);
      if (chakraBalance) return 'flow';
    }

    if (emotion > 0.7) return 'swirl'; // Positive emotion = swirling
    if (emotion < 0.3) return 'static'; // Low emotion = static
    return 'flow'; // Default = flowing
  }

  bool _checkChakraBalance(Map<String, dynamic> chakra) {
    // Check if all chakras are relatively balanced
    final values = chakra.values.map((v) => (v as num).toDouble()).toList();
    if (values.isEmpty) return true;

    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - avg).abs()).reduce((a, b) => a + b) / values.length;
    
    return variance < 0.2; // Low variance = balanced
  }

  /// Get chakra colors for AR overlay
  Future<Map<String, String>> getChakraColors(ChakraState chakras) async {
    return {
      'root': _chakraColorToHex('red', chakras.root),
      'sacral': _chakraColorToHex('orange', chakras.sacral),
      'solar_plexus': _chakraColorToHex('yellow', chakras.solarPlexus),
      'heart': _chakraColorToHex('green', chakras.heart),
      'throat': _chakraColorToHex('blue', chakras.throat),
      'third_eye': _chakraColorToHex('indigo', chakras.thirdEye),
      'crown': _chakraColorToHex('violet', chakras.crown),
    };
  }

  String _chakraColorToHex(String baseColor, double intensity) {
    // Map chakra colors with intensity
    final colors = {
      'red': 'FF0000',
      'orange': 'FF7F00',
      'yellow': 'FFFF00',
      'green': '00FF00',
      'blue': '0000FF',
      'indigo': '4B0082',
      'violet': '9400D3',
    };

    final baseHex = colors[baseColor] ?? 'FFFFFF';
    final alpha = (intensity * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$alpha$baseHex';
  }
}

class AuraVisualization {
  final String primaryColor; // Color name or hex
  final double intensity; // 0.0 to 1.0
  final String pattern; // 'flow', 'swirl', 'static', 'chaotic'
  final bool pulsing;
  final double size; // Relative size multiplier
  final DateTime timestamp;

  AuraVisualization({
    required this.primaryColor,
    required this.intensity,
    required this.pattern,
    required this.pulsing,
    required this.size,
    required this.timestamp,
  });
}

