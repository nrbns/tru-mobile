import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/agentic/agentic_coordinator.dart';
import '../services/agentic/bond_level_system.dart';
import '../services/agentic/energy_pulse_system.dart';
import '../services/agentic/agentic_discipline_engine.dart';

// Re-export Firebase providers if not already defined
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Agentic Coordinator Provider
final agenticCoordinatorProvider = Provider<AgenticCoordinator>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return AgenticCoordinator(db, auth);
});

// Individual Engine Providers
final mindEngineProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.mindEngine;
});

final bodyEngineProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.bodyEngine;
});

final spiritEngineProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.spiritEngine;
});

final disciplineEngineProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.disciplineEngine;
});

final lifeEngineProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.lifeEngine;
});

// Advanced System Providers
final bondLevelProvider = FutureProvider<BondLevel>((ref) async {
  final system = ref.watch(agenticCoordinatorProvider).bondSystem;
  return system.calculateBondLevel();
});

final energyPulseProvider = FutureProvider<EnergyPulse>((ref) async {
  final system = ref.watch(agenticCoordinatorProvider).energyPulse;
  return system.calculateEnergyPulse();
});

final karmaStatusProvider = FutureProvider<KarmaStatus>((ref) async {
  final engine = ref.watch(disciplineEngineProvider);
  return engine.getKarmaStatus();
});

// Wearable Integration Provider
final wearableProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.wearable;
});

// Inner Voice Coach Provider
final innerVoiceCoachProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.innerVoice;
});

// Sleep Realm Provider
final sleepRealmProvider = Provider((ref) {
  final coordinator = ref.watch(agenticCoordinatorProvider);
  return coordinator.sleepRealm;
});

