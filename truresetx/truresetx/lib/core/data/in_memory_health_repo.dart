import 'dart:async';

// Simple in-memory repository for quick local MVP wiring.
// Replace with Supabase/Firestore-backed implementation for production.

class MoodLog {
  final DateTime recordedAt;
  final int mood; // 1..10
  final int energy; // 1..10
  final String? note;

  MoodLog({
    required this.recordedAt,
    required this.mood,
    required this.energy,
    this.note,
  });
}

class SleepSession {
  final DateTime startAt;
  final DateTime endAt;
  final int efficiency; // 0..100

  SleepSession(
      {required this.startAt, required this.endAt, required this.efficiency});
}

class MealLog {
  final DateTime recordedAt;
  final String description;
  final num carbs;
  final num protein;
  final num fat;

  MealLog({
    required this.recordedAt,
    required this.description,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

class InMemoryHealthRepository {
  InMemoryHealthRepository._internal();

  static final InMemoryHealthRepository _instance =
      InMemoryHealthRepository._internal();
  static InMemoryHealthRepository get instance => _instance;

  final _moodController = StreamController<List<MoodLog>>.broadcast();
  final _sleepController = StreamController<List<SleepSession>>.broadcast();
  final _mealController = StreamController<List<MealLog>>.broadcast();

  final List<MoodLog> _moodLogs = [];
  final List<SleepSession> _sleepSessions = [];
  final List<MealLog> _meals = [];

  Stream<List<MoodLog>> streamMoodLogs(String userId) => _moodController.stream;
  Stream<List<SleepSession>> streamSleepSessions(String userId) =>
      _sleepController.stream;
  Stream<List<MealLog>> streamMealLogs(String userId) => _mealController.stream;

  Future<void> addMood(String userId, MoodLog m) async {
    _moodLogs.add(m);
    _moodController.add(List.unmodifiable(_moodLogs));
  }

  Future<void> addSleep(String userId, SleepSession s) async {
    _sleepSessions.add(s);
    _sleepController.add(List.unmodifiable(_sleepSessions));
  }

  Future<void> addMeal(String userId, MealLog meal) async {
    _meals.add(meal);
    _mealController.add(List.unmodifiable(_meals));
  }

  // Simple fetch helpers
  Future<List<MoodLog>> fetchMoodLogs(String userId) async =>
      List.unmodifiable(_moodLogs);
  Future<List<SleepSession>> fetchSleepSessions(String userId) async =>
      List.unmodifiable(_sleepSessions);
  Future<List<MealLog>> fetchMealLogs(String userId) async =>
      List.unmodifiable(_meals);

  // Dispose for tests or app shutdown
  void dispose() {
    _moodController.close();
    _sleepController.close();
    _mealController.close();
  }
}
