import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/agent_mood.dart';
import '../models/agent_intent.dart';
import '../models/agent_session.dart';
import '../models/agent_inbox.dart';
import '../models/discipline_contract.dart';
import '../models/app_event.dart';
import '../services/agent_service.dart';
import '../services/agentic_service.dart';
import '../services/telemetry_channel.dart';
import '../services/dream_analyzer_service.dart';
import '../services/spiritual_fitness_service.dart';
import '../services/inner_voice_service.dart';
import '../services/energy_pulse_service.dart';
export '../services/energy_pulse_service.dart' show EnergyPulse, PulseState;
import '../services/agent_engines/mind_engine.dart';
import '../services/agent_engines/body_engine.dart';
import '../services/agent_engines/spirit_engine.dart';
import '../models/bond_level.dart';
import '../models/agent_persona.dart';

// Service Providers
final agentServiceProvider = Provider<AgentService>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return AgentService(db, auth);
});

final agenticServiceProvider = Provider<AgenticService>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return AgenticService(db, auth);
});

final dreamAnalyzerProvider = Provider<DreamAnalyzerService>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return DreamAnalyzerService(db, auth);
});

final spiritualFitnessProvider = Provider<SpiritualFitnessService>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  final spiritEngine = ref.watch(spiritEngineProvider);
  return SpiritualFitnessService(db, auth, spiritEngine);
});

final innerVoiceProvider = Provider<InnerVoiceService>((ref) {
  final spiritEngine = ref.watch(spiritEngineProvider);
  return InnerVoiceService(spiritEngine);
});

final energyPulseServiceProvider = Provider<EnergyPulseService>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  final mindEngine = ref.watch(mindEngineProvider);
  final bodyEngine = ref.watch(bodyEngineProvider);
  return EnergyPulseService(db, auth, mindEngine, bodyEngine);
});

// Engine Providers
final mindEngineProvider = Provider<MindEngine>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return MindEngine(db, auth);
});

final bodyEngineProvider = Provider<BodyEngine>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return BodyEngine(db, auth);
});

final spiritEngineProvider = Provider<SpiritEngine>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return SpiritEngine(db, auth);
});

final telemetryChannelProvider = Provider<TelemetryChannel>((ref) {
  return TelemetryChannel();
});

// Firebase Providers (if not already defined)
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Agent Mood Provider
final agentMoodProvider = StateNotifierProvider<AgentMoodNotifier, AgentMood>((ref) {
  return AgentMoodNotifier();
});

class AgentMoodNotifier extends StateNotifier<AgentMood> {
  AgentMoodNotifier() : super(AgentMood.neutral);
  
  void updateFromContext({int missedSessions = 0, int currentStreak = 0, double stressLevel = 0.5}) {
    state = AgentMoodExtension.fromContext(
      missedSessions: missedSessions,
      currentStreak: currentStreak,
      stressLevel: stressLevel,
    );
  }
}

// Agent Intent Provider (now uses Agentic Service for autonomous intents)
final agentIntentProvider = FutureProvider<List<AgentIntent>>((ref) async {
  final agenticService = ref.watch(agenticServiceProvider);
  return agenticService.generateAutonomousIntents();
});

// Bond Level Provider
final bondLevelProvider = FutureProvider<BondLevel>((ref) async {
  if (ref.watch(firebaseAuthProvider).currentUser == null) {
    return BondLevel.basic;
  }
  // Would calculate from user's account age and engagement
  const daysActive = 30; // Placeholder
    return BondLevelExtension.fromDaysActive(daysActive);
});

// Agent Persona Provider
final agentPersonaProvider = StateProvider<AgentPersona>((ref) {
  return AgentPersona.coach;
});

// Energy Pulse Provider
final energyPulseProvider = FutureProvider<EnergyPulse>((ref) async {
  final service = ref.watch(energyPulseServiceProvider);
  return service.calculateDailyPulse();
});

// Agent Session Provider
final agentSessionProvider = StateNotifierProvider<AgentSessionNotifier, AgentSession>((ref) {
  final telemetry = ref.watch(telemetryChannelProvider);
  return AgentSessionNotifier(telemetry);
});

class AgentSessionNotifier extends StateNotifier<AgentSession> {
  final TelemetryChannel _telemetry;
  
  AgentSessionNotifier(this._telemetry) : super(AgentSession.idle()) {
    // Listen to session events
    _telemetry.stream.listen((event) {
      if (event is SessionStarted) {
        state = event.session;
      } else if (event is SessionUpdated) {
        state = event.session;
      } else if (event is SessionEnded) {
        if (event.sessionId == state.sessionId) {
          state = AgentSession.idle();
        }
      }
    });
  }

  void startSession(AgentSession session) {
    _telemetry.sessionStarted(session);
    state = session;
  }

  void updateProgress(double progress) {
    if (state.isActive) {
      final updated = state.copyWith(progress: progress);
      _telemetry.sessionUpdated(updated);
      state = updated;
    }
  }

  void endSession({required bool completed}) {
    if (state.isActive) {
      _telemetry.sessionEnded(state.sessionId, completed: completed);
      state = AgentSession.idle();
    }
  }
}

// Agent Inbox Provider
final agentInboxProvider = StreamProvider<AgentInbox>((ref) {
  final service = ref.watch(agentServiceProvider);
  return service.streamInbox().map((messages) {
    // Extract insights (could be computed from messages)
    final insights = <String>[];
    if (messages.length >= 10) {
      insights.add('You\'ve had 10+ conversations with your agent');
    }
    return AgentInbox(messages: messages, insights: insights);
  });
});

// Discipline Provider
final disciplineProvider = StateNotifierProvider<DisciplineNotifier, List<DisciplineContract>>((ref) {
  final service = ref.watch(agentServiceProvider);
  return DisciplineNotifier(service);
});

class DisciplineNotifier extends StateNotifier<List<DisciplineContract>> {
  final AgentService _service;
  StreamSubscription<List<DisciplineContract>>? _subscription;

  DisciplineNotifier(this._service) : super([]) {
    _subscription = _service.streamContracts().listen((contracts) {
      state = contracts;
    });
  }

  Future<void> sign(DisciplineContract draft) async {
    final signed = draft.copyWith(signedAt: DateTime.now());
    await _service.saveContract(signed);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Biometrics Provider (placeholder - would integrate with Health Connect/Apple Health)
final biometricsProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'heartRate': null,
    'hrv': null,
    'sleepHours': null,
    'steps': null,
  };
});

