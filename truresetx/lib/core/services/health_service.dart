import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/agent_action.dart';

/// Lightweight in-memory HealthService mock for development & testing.
/// Replace data persistence with a real DB (Supabase/Firestore) in production.
class HealthService {
  HealthService() : _uuidGen = const Uuid();

  final Uuid _uuidGen;

  // Simple in-memory stores so callers see changing state
  final Map<String, List<Workout>> _workoutsByUser = {};
  final Map<String, List<Meal>> _mealsByUser = {};
  final Map<String, List<MoodCheck>> _moodByUser = {};
  final Map<String, List<SpiritualSession>> _spiritualByUser = {};
  final Map<String, Assessment> _lastAssessmentByUser = {};
  final Map<String, List<Goal>> _goalsByUser = {};
  final Map<String, UserPreferences> _prefsByUser = {};

  // Simulate network / DB latency
  final Duration _ioDelay = const Duration(milliseconds: 220);

  // --- Read methods ---

  Future<List<Workout>> getRecentWorkouts(String userId, int days) async {
    await Future.delayed(_ioDelay);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final list = _workoutsByUser[userId] ??
        [
          // Seed one-time mock if store empty
          Workout(
            id: _uuidGen.v4(),
            userId: userId,
            name: 'Morning Strength',
            duration: 45,
            date: DateTime.now().subtract(const Duration(days: 1)),
            exercises: ['Push-ups', 'Squats', 'Planks'],
          ),
          Workout(
            id: _uuidGen.v4(),
            userId: userId,
            name: 'Cardio Blast',
            duration: 30,
            date: DateTime.now().subtract(const Duration(days: 2)),
            exercises: ['Running', 'Jumping Jacks', 'Burpees'],
          ),
        ];
    // Cache seed
    _workoutsByUser[userId] = list;
    return list.where((w) => w.date.isAfter(cutoff)).toList();
  }

  Future<List<Meal>> getRecentMeals(String userId, int days) async {
    await Future.delayed(_ioDelay);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final list = _mealsByUser[userId] ??
        [
          Meal(
            id: _uuidGen.v4(),
            userId: userId,
            name: 'Breakfast',
            calories: 350.0,
            date: DateTime.now().subtract(const Duration(hours: 3)),
            foods: ['Oatmeal', 'Berries', 'Almonds'],
          ),
          Meal(
            id: _uuidGen.v4(),
            userId: userId,
            name: 'Lunch',
            calories: 600.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
            foods: ['Grilled Chicken', 'Rice', 'Salad'],
          ),
        ];
    _mealsByUser[userId] = list;
    return list.where((m) => m.date.isAfter(cutoff)).toList();
  }

  Future<List<MoodCheck>> getRecentMoodChecks(String userId, int days) async {
    await Future.delayed(_ioDelay);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final list = _moodByUser[userId] ??
        [
          MoodCheck(
            id: _uuidGen.v4(),
            userId: userId,
            energyLevel: 7.5,
            stressLevel: 3.0,
            mood: 'content',
            date: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ];
    _moodByUser[userId] = list;
    return list.where((m) => m.date.isAfter(cutoff)).toList();
  }

  Future<List<SpiritualSession>> getRecentSpiritualSessions(
      String userId, int days) async {
    await Future.delayed(_ioDelay);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final list = _spiritualByUser[userId] ??
        [
          SpiritualSession(
            id: _uuidGen.v4(),
            userId: userId,
            type: 'meditation',
            duration: 15,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
    _spiritualByUser[userId] = list;
    return list.where((s) => s.date.isAfter(cutoff)).toList();
  }

  Future<SleepData> getSleepData(String userId, int days) async {
    await Future.delayed(_ioDelay);
    // Simple aggregated mock
    return SleepData(
      averageHours: 7.5,
      averageQuality: 7.8,
      bedtime: DateTime.now().subtract(const Duration(hours: 8)),
      wakeTime: DateTime.now(),
    );
  }

  Future<double> getCurrentStressLevel(String userId) async {
    await Future.delayed(_ioDelay);
    // Use latest mood check if available
    final recent = await getRecentMoodChecks(userId, 7);
    if (recent.isNotEmpty) return recent.first.stressLevel;
    return 3.0;
  }

  Future<double> getCurrentEnergyLevel(String userId) async {
    await Future.delayed(_ioDelay);
    final recent = await getRecentMoodChecks(userId, 7);
    if (recent.isNotEmpty) return recent.first.energyLevel;
    return 6.5;
  }

  Future<double> getCommunityActivity(String userId, int days) async {
    await Future.delayed(_ioDelay);
    // Mock activity metric 0..1
    return 0.6;
  }

  Future<List<Goal>> getCurrentGoals(String userId) async {
    await Future.delayed(_ioDelay);
    final list = _goalsByUser[userId] ??
        [
          Goal(
            id: _uuidGen.v4(),
            userId: userId,
            title: 'Lose 10 pounds',
            category: 'fitness',
            targetDate: DateTime.now().add(const Duration(days: 90)),
            progress: 0.3,
          ),
        ];
    _goalsByUser[userId] = list;
    return list;
  }

  Future<UserPreferences> getUserPreferences(String userId) async {
    await Future.delayed(_ioDelay);
    final prefs = _prefsByUser[userId] ??
        UserPreferences(
          userId: userId,
          equipment: ['dumbbells', 'yoga_mat'],
          dietary: ['vegetarian'],
          workoutTime: 'morning',
          goals: ['weight_loss', 'strength'],
        );
    _prefsByUser[userId] = prefs;
    return prefs;
  }

  Future<Assessment?> getLastAssessment(String userId) async {
    await Future.delayed(_ioDelay);
    return _lastAssessmentByUser[userId] ??
        Assessment(
          id: _uuidGen.v4(),
          userId: userId,
          date: DateTime.now().subtract(const Duration(days: 5)),
          overallGrade: 'B',
          limitations: ['ankle_mobility'],
          recommendations: ['ankle_dorsiflexion'],
        );
  }

  Future<MacroTargets> getTodaysMacros(String userId) async {
    await Future.delayed(_ioDelay);
    // realistic daily target mock (adjust as needed)
    return MacroTargets(
      calories: 2200.0,
      protein: 120.0,
      carbs: 250.0,
      fat: 70.0,
    );
  }

  Future<MacroTargets> getRemainingMacros(String userId) async {
    await Future.delayed(_ioDelay);
    // mock remaining values
    return MacroTargets(
      calories: 900.0,
      protein: 40.0,
      carbs: 120.0,
      fat: 30.0,
    );
  }

  // --- Mutation / scheduling methods (return bool for success) ---

  Future<bool> scheduleAssessment(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    // Create a simple assessment placeholder and store as last assessment
    final assessment = Assessment(
      id: _uuidGen.v4(),
      userId: userId,
      date: DateTime.now(),
      overallGrade: 'Pending',
      limitations: [],
      recommendations: [],
    );
    _lastAssessmentByUser[userId] = assessment;
    // In production, you would enqueue a real assessment job
    return true;
  }

  Future<bool> createWorkoutPlan(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    // For mock, create a workout entry and push to user's workouts
    final workout = Workout(
      id: _uuidGen.v4(),
      userId: userId,
      name: parameters['name'] ?? 'AI Generated Plan',
      duration: parameters['duration'] ?? 30,
      date: DateTime.now(),
      exercises: (parameters['exercises'] as List<dynamic>?)?.cast<String>() ??
          ['Bodyweight Squat', 'Push-up'],
    );
    _workoutsByUser.putIfAbsent(userId, () => []).insert(0, workout);
    return true;
  }

  Future<bool> createQuickWorkout(
      String userId, Map<String, dynamic> parameters) async {
    return createWorkoutPlan(userId, {
      'name': parameters['name'] ?? 'Quick Mobility',
      'duration': parameters['duration'] ?? 5,
      'exercises':
          parameters['exercises'] ?? ['Cat-Cow', 'Ankle Mobilizations'],
    });
  }

  Future<bool> sendMealReminder(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    // In production, enqueue push / notification
    debugPrint('Meal reminder (mock) for $userId params=$parameters');
    return true;
  }

  Future<bool> suggestNextMeal(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    debugPrint('Suggesting next meal (mock) for $userId params=$parameters');
    return true;
  }

  Future<bool> scheduleMoodCheck(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    final mood = MoodCheck(
      id: _uuidGen.v4(),
      userId: userId,
      energyLevel: parameters['energy'] ?? 6.0,
      stressLevel: parameters['stress'] ?? 4.0,
      mood: parameters['mood'] ?? 'neutral',
      date: DateTime.now(),
    );
    _moodByUser.putIfAbsent(userId, () => []).insert(0, mood);
    return true;
  }

  Future<bool> scheduleStressIntervention(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    debugPrint(
        'Stress intervention scheduled (mock) for $userId params=$parameters');
    return true;
  }

  Future<bool> scheduleSpiritualSession(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    final session = SpiritualSession(
      id: _uuidGen.v4(),
      userId: userId,
      type: parameters['type'] ?? 'meditation',
      duration: parameters['duration'] ?? 10,
      date: DateTime.now(),
    );
    _spiritualByUser.putIfAbsent(userId, () => []).insert(0, session);
    return true;
  }

  Future<bool> scheduleCommunityActivity(
      String userId, Map<String, dynamic> parameters) async {
    await Future.delayed(_ioDelay);
    debugPrint(
        'Community activity scheduled (mock) for $userId params=$parameters');
    return true;
  }

  Future<void> recordActionFailure(String userId, AgentAction action) async {
    await Future.delayed(_ioDelay);
    debugPrint('Recorded action failure for $userId -> ${action.type}');
    // attach failure info to a log collected in production
  }

  Future<void> updateUserPreferences(
      String userId, List<AgentAction> actions) async {
    await Future.delayed(_ioDelay);
    // naive example: adjust workoutTime based on actions
    final pref = _prefsByUser[userId] ??= await getUserPreferences(userId);
    if (actions.any((a) => a.type == ActionType.createQuickWorkout)) {
      // prefer short morning sessions
      _prefsByUser[userId] = UserPreferences(
          userId: userId,
          equipment: pref.equipment,
          dietary: pref.dietary,
          workoutTime: 'morning',
          goals: pref.goals);
    }
  }

  Future<void> sendWellnessCheckIn(String userId) async {
    await Future.delayed(_ioDelay);
    debugPrint('Wellness check-in (mock) sent to $userId');
  }

  /// Dispose if you need to clear resources later
  void dispose() {
    _workoutsByUser.clear();
    _mealsByUser.clear();
    _moodByUser.clear();
    _spiritualByUser.clear();
    _lastAssessmentByUser.clear();
    _goalsByUser.clear();
    _prefsByUser.clear();
  }
}

// --- Data Models (unchanged fields; kept simple) ---
class Workout {
  Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.duration,
    required this.date,
    required this.exercises,
  });
  final String id;
  final String userId;
  final String name;
  final int duration;
  final DateTime date;
  final List<String> exercises;
}

class Meal {
  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.date,
    required this.foods,
  });
  final String id;
  final String userId;
  final String name;
  final double calories;
  final DateTime date;
  final List<String> foods;
}

class MoodCheck {
  MoodCheck({
    required this.id,
    required this.userId,
    required this.energyLevel,
    required this.stressLevel,
    required this.mood,
    required this.date,
  });
  final String id;
  final String userId;
  final double energyLevel;
  final double stressLevel;
  final String mood;
  final DateTime date;
}

class SpiritualSession {
  SpiritualSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.date,
  });
  final String id;
  final String userId;
  final String type;
  final int duration;
  final DateTime date;
}

class SleepData {
  SleepData({
    required this.averageHours,
    required this.averageQuality,
    required this.bedtime,
    required this.wakeTime,
  });
  final double averageHours;
  final double averageQuality;
  final DateTime bedtime;
  final DateTime wakeTime;
}

class Goal {
  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.targetDate,
    required this.progress,
  });
  final String id;
  final String userId;
  final String title;
  final String category;
  final DateTime targetDate;
  final double progress;
}

class UserPreferences {
  UserPreferences({
    required this.userId,
    required this.equipment,
    required this.dietary,
    required this.workoutTime,
    required this.goals,
  });
  final String userId;
  final List<String> equipment;
  final List<String> dietary;
  final String workoutTime;
  final List<String> goals;
}

class Assessment {
  Assessment({
    required this.id,
    required this.userId,
    required this.date,
    required this.overallGrade,
    required this.limitations,
    required this.recommendations,
  });
  final String id;
  final String userId;
  final DateTime date;
  final String overallGrade;
  final List<String> limitations;
  final List<String> recommendations;
}

class MacroTargets {
  MacroTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// Provider
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});
