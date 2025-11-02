import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agent_engines/spirit_engine.dart';

/// Spiritual Fitness Mode - Workout while chanting/mantra-guided breathing
class SpiritualFitnessService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final SpiritEngine? _spiritEngine;
  final String? _uid;

  SpiritualFitnessService(this._db, this._auth, [this._spiritEngine])
      : _uid = _auth.currentUser?.uid;
  
  SpiritEngine get spiritEngine => _spiritEngine ?? SpiritEngine(_db, _auth);

  /// Generate spiritual fitness routine
  Future<SpiritualFitnessRoutine> generateRoutine({
    required String workoutType,
    required int duration, // minutes
  }) async {
    final engine = spiritEngine;
    final spiritualPath = await engine.getSpiritualPath();
    final philosophy = spiritualPath.philosophy;

    // Get mantras/guidance based on philosophy
    final content = await engine.getPhilosophyContent(philosophy);
    final selectedMantra = content.isNotEmpty ? content[0] : 'Breathe deeply and move mindfully.';

    // Create synchronized workout + spiritual practice
    final segments = _createSegments(workoutType, duration, selectedMantra, philosophy);

    return SpiritualFitnessRoutine(
      workoutType: workoutType,
      duration: duration,
      mantra: selectedMantra,
      philosophy: philosophy,
      segments: segments,
    );
  }

  List<SpiritualFitnessSegment> _createSegments(
    String workoutType,
    int duration,
    String mantra,
    PhilosophyMode philosophy,
  ) {
    final segments = <SpiritualFitnessSegment>[];
    final segmentDuration = 5; // minutes per segment
    final numSegments = (duration / segmentDuration).ceil();

    for (int i = 0; i < numSegments; i++) {
      String instruction = '';
      String spiritualGuidance = '';

      switch (philosophy) {
        case PhilosophyMode.vedic:
          instruction = 'Inhale: "Om", Exhale: "Namah Shivaya"';
          spiritualGuidance = 'Sync each rep with the mantra. Feel the prana (life force) flowing.';
          break;
        case PhilosophyMode.stoic:
          instruction = 'With each movement: "This is in my control"';
          spiritualGuidance = 'Practice discipline. The body follows the mind.';
          break;
        case PhilosophyMode.zen:
          instruction = 'Move without thought. Just movement.';
          spiritualGuidance = 'Let the body move naturally. No judgment, just presence.';
          break;
        case PhilosophyMode.buddhist:
          instruction = 'Breathe: "May all beings be free from suffering"';
          spiritualGuidance = 'Dedicate this practice to the benefit of all.';
          break;
        case PhilosophyMode.atheist:
          instruction = 'Focus on the physical sensation of each movement.';
          spiritualGuidance = 'Practice mindfulness through body awareness.';
          break;
        case PhilosophyMode.neutral:
          instruction = 'Breathe deeply and move with intention.';
          spiritualGuidance = 'Connect movement with breath.';
          break;
      }

      segments.add(SpiritualFitnessSegment(
        segmentNumber: i + 1,
        duration: segmentDuration,
        exerciseType: workoutType,
        instruction: instruction,
        spiritualGuidance: spiritualGuidance,
        mantra: mantra,
      ));
    }

    return segments;
  }

  /// Save spiritual fitness session
  Future<void> saveSession(SpiritualFitnessRoutine routine, {bool completed = true}) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('spiritual_fitness_sessions').add({
      'workout_type': routine.workoutType,
      'duration': routine.duration,
      'philosophy': routine.philosophy.name,
      'mantra': routine.mantra,
      'completed': completed,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class SpiritualFitnessRoutine {
  final String workoutType;
  final int duration; // minutes
  final String mantra;
  final PhilosophyMode philosophy;
  final List<SpiritualFitnessSegment> segments;

  SpiritualFitnessRoutine({
    required this.workoutType,
    required this.duration,
    required this.mantra,
    required this.philosophy,
    required this.segments,
  });
}

class SpiritualFitnessSegment {
  final int segmentNumber;
  final int duration; // minutes
  final String exerciseType;
  final String instruction;
  final String spiritualGuidance;
  final String mantra;

  SpiritualFitnessSegment({
    required this.segmentNumber,
    required this.duration,
    required this.exerciseType,
    required this.instruction,
    required this.spiritualGuidance,
    required this.mantra,
  });
}

