import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.fitnessGoals,
    required this.dietaryRestrictions,
    required this.medicalConditions,
    required this.emergencyContact,
    required this.preferredWorkoutTime,
    required this.timezone,
    required this.language,
    required this.notificationSettings,
    required this.privacySettings,
    required this.createdAt,
    required this.updatedAt,
    this.profilePicture,
    this.bio,
    this.location,
    this.occupation,
    this.interests,
    this.achievements,
    this.streaks,
    this.badges,
    this.socialConnections,
    this.subscriptionTier,
    this.lastActiveAt,
    this.isVerified,
    this.isPremium,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  final String id;
  final String email;
  final String fullName;
  final DateTime dateOfBirth;
  final Gender gender;
  final double height; // in cm
  final double weight; // in kg
  final ActivityLevel activityLevel;
  final List<FitnessGoal> fitnessGoals;
  final List<DietaryRestriction> dietaryRestrictions;
  final List<MedicalCondition> medicalConditions;
  final EmergencyContact emergencyContact;
  final String preferredWorkoutTime;
  final String timezone;
  final String language;
  final NotificationSettings notificationSettings;
  final PrivacySettings privacySettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional fields
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? occupation;
  final List<String>? interests;
  final List<Achievement>? achievements;
  final Map<String, int>? streaks;
  final List<Badge>? badges;
  final List<SocialConnection>? socialConnections;
  final String? subscriptionTier;
  final DateTime? lastActiveAt;
  final bool? isVerified;
  final bool? isPremium;

  // Computed properties
  double get bmi => weight / ((height / 100) * (height / 100));
  
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
  
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  String get activityLevelDescription {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 'Little to no exercise';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Heavy exercise 6-7 days/week';
      case ActivityLevel.extraActive:
        return 'Very heavy exercise, physical job';
    }
  }
  
  List<String> get fitnessGoalNames => fitnessGoals.map((goal) => goal.name).toList();
  List<String> get dietaryRestrictionNames => dietaryRestrictions.map((restriction) => restriction.name).toList();
  List<String> get medicalConditionNames => medicalConditions.map((condition) => condition.name).toList();
  
  bool get hasProfilePicture => profilePicture != null && profilePicture!.isNotEmpty;
  bool get isComplete => fullName.isNotEmpty && dateOfBirth != DateTime(1900);
  
  Map<String, dynamic> get healthSummary => {
    'age': age,
    'bmi': bmi.toStringAsFixed(1),
    'bmiCategory': bmiCategory,
    'activityLevel': activityLevelDescription,
    'goals': fitnessGoalNames,
    'restrictions': dietaryRestrictionNames,
  };
}

@JsonSerializable()
class FitnessGoal {
  FitnessGoal({
    required this.id,
    required this.name,
    required this.category,
    required this.priority,
    required this.targetDate,
    required this.isActive,
    this.description,
    this.targetValue,
    this.currentValue,
    this.unit,
  });

  factory FitnessGoal.fromJson(Map<String, dynamic> json) => _$FitnessGoalFromJson(json);
  Map<String, dynamic> toJson() => _$FitnessGoalToJson(this);

  final String id;
  final String name;
  final String category; // weight_loss, muscle_gain, endurance, flexibility, etc.
  final int priority; // 1-5, 5 being highest
  final DateTime targetDate;
  final bool isActive;
  final String? description;
  final double? targetValue;
  final double? currentValue;
  final String? unit;
}

@JsonSerializable()
class DietaryRestriction {
  DietaryRestriction({
    required this.id,
    required this.name,
    required this.type,
    required this.severity,
    this.description,
    this.notes,
  });

  factory DietaryRestriction.fromJson(Map<String, dynamic> json) => _$DietaryRestrictionFromJson(json);
  Map<String, dynamic> toJson() => _$DietaryRestrictionToJson(this);

  final String id;
  final String name;
  final String type; // allergy, intolerance, preference, religious, etc.
  final String severity; // mild, moderate, severe
  final String? description;
  final String? notes;
}

@JsonSerializable()
class MedicalCondition {
  MedicalCondition({
    required this.id,
    required this.name,
    required this.type,
    required this.severity,
    this.description,
    this.medications,
    this.notes,
  });

  factory MedicalCondition.fromJson(Map<String, dynamic> json) => _$MedicalConditionFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalConditionToJson(this);

  final String id;
  final String name;
  final String type; // chronic, acute, mental_health, etc.
  final String severity; // mild, moderate, severe
  final String? description;
  final List<String>? medications;
  final String? notes;
}

@JsonSerializable()
class EmergencyContact {
  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.address,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);

  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final String? address;
}

@JsonSerializable()
class NotificationSettings {
  NotificationSettings({
    required this.workoutReminders,
    required this.mealReminders,
    required this.moodCheckIns,
    required this.meditationReminders,
    required this.achievementCelebrations,
    required this.weeklyReports,
    required this.promotionalEmails,
    required this.pushNotifications,
    required this.emailNotifications,
    this.reminderTime,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  final bool workoutReminders;
  final bool mealReminders;
  final bool moodCheckIns;
  final bool meditationReminders;
  final bool achievementCelebrations;
  final bool weeklyReports;
  final bool promotionalEmails;
  final bool pushNotifications;
  final bool emailNotifications;
  final String? reminderTime; // HH:mm format
  final String? quietHoursStart; // HH:mm format
  final String? quietHoursEnd; // HH:mm format
}

@JsonSerializable()
class PrivacySettings {
  PrivacySettings({
    required this.profileVisibility,
    required this.activitySharing,
    required this.dataSharing,
    required this.locationSharing,
    required this.healthDataSharing,
    this.allowedConnections,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => _$PrivacySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);

  final String profileVisibility; // public, friends, private
  final bool activitySharing;
  final bool dataSharing;
  final bool locationSharing;
  final bool healthDataSharing;
  final List<String>? allowedConnections;
}

@JsonSerializable()
class Achievement {
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.earnedAt,
    required this.points,
    this.icon,
    this.badge,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime earnedAt;
  final int points;
  final String? icon;
  final String? badge;
}

@JsonSerializable()
class Badge {
  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.earnedAt,
    this.icon,
    this.rarity,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeToJson(this);

  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime earnedAt;
  final String? icon;
  final String? rarity; // common, rare, epic, legendary
}

@JsonSerializable()
class SocialConnection {
  SocialConnection({
    required this.id,
    required this.type,
    required this.username,
    required this.isConnected,
    this.displayName,
    this.avatar,
  });

  factory SocialConnection.fromJson(Map<String, dynamic> json) => _$SocialConnectionFromJson(json);
  Map<String, dynamic> toJson() => _$SocialConnectionToJson(this);

  final String id;
  final String type; // instagram, facebook, twitter, etc.
  final String username;
  final bool isConnected;
  final String? displayName;
  final String? avatar;
}

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

enum ActivityLevel {
  @JsonValue('sedentary')
  sedentary,
  @JsonValue('lightly_active')
  lightlyActive,
  @JsonValue('moderately_active')
  moderatelyActive,
  @JsonValue('very_active')
  veryActive,
  @JsonValue('extra_active')
  extraActive,
}