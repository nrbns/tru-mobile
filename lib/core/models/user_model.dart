import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? dob;
  final int? heightCm;
  final int? weightKg;
  final List<String> goals;
  final List<String> traditions;
  final MacroTargets? macroTargets;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    this.email,
    this.phone,
    this.dob,
    this.heightCm,
    this.weightKg,
    required this.goals,
    required this.traditions,
    this.macroTargets,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      dob: data['dob']?.toDate(),
      heightCm: data['height_cm'],
      weightKg: data['weight_kg'],
      goals: List<String>.from(data['goals'] ?? []),
      traditions: List<String>.from(data['traditions'] ?? []),
      macroTargets: data['macro_targets'] != null
          ? MacroTargets.fromMap(data['macro_targets'])
          : null,
      settings: UserSettings.fromMap(data['settings'] ?? {}),
      createdAt: data['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: data['updated_at']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'goals': goals,
      'traditions': traditions,
      'macro_targets': macroTargets?.toMap(),
      'settings': settings.toMap(),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}

class MacroTargets {
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fat; // grams
  final int fiber; // grams
  final int sodium; // mg

  MacroTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
  });

  factory MacroTargets.fromMap(Map<String, dynamic> map) {
    return MacroTargets(
      calories: map['calories'] ?? 2000,
      protein: map['protein'] ?? 150,
      carbs: map['carbs'] ?? 200,
      fat: map['fat'] ?? 65,
      fiber: map['fiber'] ?? 25,
      sodium: map['sodium'] ?? 2300,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
    };
  }
}

class UserSettings {
  final bool eveningCheckin;
  final bool hydrationReminders;
  final bool practiceReminders;
  final String timezone;
  final NotificationSettings push;

  UserSettings({
    required this.eveningCheckin,
    required this.hydrationReminders,
    required this.practiceReminders,
    required this.timezone,
    required this.push,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      eveningCheckin: map['evening_checkin'] ?? true,
      hydrationReminders: map['hydration_reminders'] ?? true,
      practiceReminders: map['practice_reminders'] ?? true,
      timezone: map['timezone'] ?? 'Asia/Kolkata',
      push: NotificationSettings.fromMap(map['push'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'evening_checkin': eveningCheckin,
      'hydration_reminders': hydrationReminders,
      'practice_reminders': practiceReminders,
      'timezone': timezone,
      'push': push.toMap(),
    };
  }
}

class NotificationSettings {
  final bool enabled;
  final bool eveningReflection;
  final bool hydrationNudges;
  final bool sadhanaReminders;

  NotificationSettings({
    required this.enabled,
    required this.eveningReflection,
    required this.hydrationNudges,
    required this.sadhanaReminders,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] ?? true,
      eveningReflection: map['evening_reflection'] ?? true,
      hydrationNudges: map['hydration_nudges'] ?? true,
      sadhanaReminders: map['sadhana_reminders'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'evening_reflection': eveningReflection,
      'hydration_nudges': hydrationNudges,
      'sadhana_reminders': sadhanaReminders,
    };
  }
}
