import 'package:cloud_firestore/cloud_firestore.dart';

class TodayModel {
  final String uid;
  final DateTime date;
  final int streak;
  final int calories;
  final int waterMl;
  final WorkoutStatus workouts;
  final MoodStatus mood;
  final SadhanaStatus sadhana;
  final DateTime updatedAt;

  TodayModel({
    required this.uid,
    required this.date,
    required this.streak,
    required this.calories,
    required this.waterMl,
    required this.workouts,
    required this.mood,
    required this.sadhana,
    required this.updatedAt,
  });

  factory TodayModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TodayModel(
      uid: doc.reference.parent.parent!.id,
      date: data['date']?.toDate() ?? DateTime.now(),
      streak: data['streak'] ?? 0,
      calories: data['calories'] ?? 0,
      waterMl: data['water_ml'] ?? 0,
      workouts: WorkoutStatus.fromMap(data['workouts'] ?? {}),
      mood: MoodStatus.fromMap(data['mood'] ?? {}),
      sadhana: SadhanaStatus.fromMap(data['sadhana'] ?? {}),
      updatedAt: data['updated_at']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'streak': streak,
      'calories': calories,
      'water_ml': waterMl,
      'workouts': workouts.toMap(),
      'mood': mood.toMap(),
      'sadhana': sadhana.toMap(),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}

class WorkoutStatus {
  final int done;
  final int target;

  WorkoutStatus({required this.done, required this.target});

  factory WorkoutStatus.fromMap(Map<String, dynamic> map) {
    return WorkoutStatus(
      done: map['done'] ?? 0,
      target: map['target'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {'done': done, 'target': target};
  }

  double get progress => target > 0 ? (done / target).clamp(0.0, 1.0) : 0.0;
}

class MoodStatus {
  final int? latest;
  final double? average;
  final DateTime? lastLoggedAt;

  MoodStatus({this.latest, this.average, this.lastLoggedAt});

  factory MoodStatus.fromMap(Map<String, dynamic> map) {
    return MoodStatus(
      latest: map['latest'],
      average: map['average']?.toDouble(),
      lastLoggedAt: map['last_logged_at']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latest': latest,
      'average': average,
      'last_logged_at':
          lastLoggedAt != null ? Timestamp.fromDate(lastLoggedAt!) : null,
    };
  }
}

class SadhanaStatus {
  final int done;
  final int target;
  final List<String> completedPractices;

  SadhanaStatus({
    required this.done,
    required this.target,
    required this.completedPractices,
  });

  factory SadhanaStatus.fromMap(Map<String, dynamic> map) {
    return SadhanaStatus(
      done: map['done'] ?? 0,
      target: map['target'] ?? 3,
      completedPractices: List<String>.from(map['completed_practices'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'done': done,
      'target': target,
      'completed_practices': completedPractices,
    };
  }

  double get progress => target > 0 ? (done / target).clamp(0.0, 1.0) : 0.0;
}
