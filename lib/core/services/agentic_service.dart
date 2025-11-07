import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'agent_engines/mind_engine.dart';
import 'agent_engines/body_engine.dart';
import 'agent_engines/spirit_engine.dart';
import 'agent_engines/discipline_engine.dart';
import 'agent_engines/life_engine.dart';
import '../models/agent_intent.dart';
import '../models/agent_mood.dart';
import 'agent_service.dart';

/// Master Agentic Service - Orchestrates all engines for autonomous decision-making
class AgenticService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  
  late final MindEngine _mindEngine;
  late final BodyEngine _bodyEngine;
  late final SpiritEngine _spiritEngine;
  late final DisciplineEngine _disciplineEngine;
  late final LifeEngine _lifeEngine;
  late final AgentService _agentService;

  AgenticService(this._db, this._auth) {
    _mindEngine = MindEngine(_db, _auth);
    _bodyEngine = BodyEngine(_db, _auth);
    _spiritEngine = SpiritEngine(_db, _auth);
    _disciplineEngine = DisciplineEngine(_db, _auth);
    _lifeEngine = LifeEngine(_db, _auth);
    _agentService = AgentService(_db, _auth);
  }

  /// Generate autonomous intents based on all engines
  Future<List<AgentIntent>> generateAutonomousIntents() async {
    final intents = <AgentIntent>[];

    // 1. Mind Engine - Emotional state
    final emotionalState = await _mindEngine.analyzeEmotionalState();
    final moodPrediction = await _mindEngine.predictDailyMood();

    // 2. Body Engine - Physical state
    final bodyState = await _bodyEngine.getCurrentBodyState();
    final workoutAdaptation = await _bodyEngine.suggestWorkoutAdaptation(bodyState);

    // 3. Spirit Engine - Spiritual path
    final spiritualPath = await _spiritEngine.getSpiritualPath();
    final spiritualGuidance = await _spiritEngine.generateGuidance(
      path: spiritualPath,
      stressLevel: emotionalState.stressLevel,
      dominantEmotion: emotionalState.dominantEmotion,
    );

    // 4. Discipline Engine - Accountability
    final accountability = await _disciplineEngine.checkAccountability();
    final karmaScore = await _disciplineEngine.calculateKarmaScore();

    // 5. Life Engine - Long-term patterns
    final lifeInsight = await _lifeEngine.analyzeLifePatterns();
    final microGoals = await _lifeEngine.generateDailyMicroGoals();

    // Generate intents based on analysis
    if (emotionalState.stressLevel > 0.7) {
      intents.add(AgentIntent(
        intentId: 'breath_reset',
        title: '${spiritualGuidance.duration}-min ${spiritualGuidance.practiceType.replaceAll('_', ' ')}',
        subtitle: spiritualGuidance.content,
        cta: 'Begin',
        icon: 'self_improvement',
        priority: 0.95,
        expiresInSec: 1800,
        metadata: {
          'route': '/agent/overlay',
          'type': spiritualGuidance.practiceType,
          'duration': spiritualGuidance.duration,
        },
      ));
    }

    if (workoutAdaptation.recommendation != 'rest') {
      intents.add(AgentIntent(
        intentId: 'workout_suggestion',
        title: workoutAdaptation.recommendation.toUpperCase() + ' Workout',
        subtitle: workoutAdaptation.reason,
        cta: 'Start',
        icon: 'fitness_center',
        priority: 0.85,
        expiresInSec: 3600,
        metadata: {
          'route': '/home/workouts',
          'intensity': workoutAdaptation.suggestedIntensity,
          'duration': workoutAdaptation.suggestedDuration,
        },
      ));
    }

    if (accountability.shouldTriggerStrict) {
      intents.add(AgentIntent(
        intentId: 'accountability_check',
        title: 'Accountability Check-in',
        subtitle: '${accountability.missedSessions} missed sessions. Let\'s realign.',
        cta: 'Talk',
        icon: 'warning',
        priority: 0.9,
        expiresInSec: null,
        metadata: {'route': '/agent/chat', 'strict_mode': true},
      ));
    }

    if (microGoals.isNotEmpty) {
      final topGoal = microGoals.first;
      intents.add(AgentIntent(
        intentId: 'micro_goal_${topGoal.category}',
        title: topGoal.description,
        subtitle: 'Earn ${topGoal.karmaReward} karma points',
        cta: 'Accept',
        icon: _getIconForCategory(topGoal.category),
        priority: 0.75,
        expiresInSec: 86400, // 24 hours
        metadata: {
          'category': topGoal.category,
          'karma_reward': topGoal.karmaReward,
        },
      ));
    }

    // Karma celebration
    if (karmaScore.weeklyEarned >= 50) {
      intents.add(AgentIntent(
        intentId: 'karma_celebration',
        title: 'Amazing! ${karmaScore.weeklyEarned} karma this week',
        subtitle: 'Keep your positive momentum going',
        cta: 'View',
        icon: 'star',
        priority: 0.6,
        expiresInSec: 86400,
        metadata: {'route': '/spirit/karma'},
      ));
    }

    return intents;
  }

  /// Determine agent mood based on all context
  Future<AgentMood> determineAgentMood() async {
    final accountability = await _disciplineEngine.checkAccountability();
    final emotionalState = await _mindEngine.analyzeEmotionalState();
    final moodPrediction = await _mindEngine.predictDailyMood();

    return AgentMoodExtension.fromContext(
      missedSessions: accountability.missedSessions,
      currentStreak: accountability.streakDays,
      stressLevel: emotionalState.stressLevel,
    );
  }

  /// Auto-execute adaptive actions (autonomous layer)
  Future<void> executeAdaptiveActions() async {
    // Check if user needs intervention
    final emotionalState = await _mindEngine.analyzeEmotionalState();
    final bodyState = await _bodyEngine.getCurrentBodyState();
    final accountability = await _disciplineEngine.checkAccountability();

    // Auto-cancel heavy workouts if stress is high
    if (emotionalState.stressLevel > 0.8 && bodyState.recoveryStatus == RecoveryStatus.needRest) {
      // Would trigger notification: "Heavy workout canceled. Suggested: 10-min yoga instead"
      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('agent_actions')
          .add({
        'type': 'workout_adaptation',
        'action': 'suggest_light_workout',
        'reason': 'High stress + recovery needed',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Trigger strict mode if needed
    if (accountability.shouldTriggerStrict) {
      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('agent_actions')
          .add({
        'type': 'discipline_intervention',
        'action': 'activate_strict_mode',
        'reason': 'Multiple missed sessions',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  String _getIconForCategory(String category) {
    switch (category) {
      case 'fitness':
        return 'fitness_center';
      case 'mind':
        return 'psychology';
      case 'spirit':
        return 'self_improvement';
      case 'nutrition':
        return 'restaurant';
      default:
        return 'check_circle';
    }
  }
}

