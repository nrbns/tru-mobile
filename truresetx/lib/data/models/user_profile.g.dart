// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      activityLevel: $enumDecode(_$ActivityLevelEnumMap, json['activityLevel']),
      fitnessGoals: (json['fitnessGoals'] as List<dynamic>)
          .map((e) => FitnessGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>)
          .map((e) => DietaryRestriction.fromJson(e as Map<String, dynamic>))
          .toList(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>)
          .map((e) => MedicalCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      emergencyContact: EmergencyContact.fromJson(
          json['emergencyContact'] as Map<String, dynamic>),
      preferredWorkoutTime: json['preferredWorkoutTime'] as String,
      timezone: json['timezone'] as String,
      language: json['language'] as String,
      notificationSettings: NotificationSettings.fromJson(
          json['notificationSettings'] as Map<String, dynamic>),
      privacySettings: PrivacySettings.fromJson(
          json['privacySettings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      occupation: json['occupation'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      streaks: (json['streaks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
          .toList(),
      socialConnections: (json['socialConnections'] as List<dynamic>?)
          ?.map((e) => SocialConnection.fromJson(e as Map<String, dynamic>))
          .toList(),
      subscriptionTier: json['subscriptionTier'] as String?,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      isVerified: json['isVerified'] as bool?,
      isPremium: json['isPremium'] as bool?,
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'height': instance.height,
      'weight': instance.weight,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
      'fitnessGoals': instance.fitnessGoals,
      'dietaryRestrictions': instance.dietaryRestrictions,
      'medicalConditions': instance.medicalConditions,
      'emergencyContact': instance.emergencyContact,
      'preferredWorkoutTime': instance.preferredWorkoutTime,
      'timezone': instance.timezone,
      'language': instance.language,
      'notificationSettings': instance.notificationSettings,
      'privacySettings': instance.privacySettings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'profilePicture': instance.profilePicture,
      'bio': instance.bio,
      'location': instance.location,
      'occupation': instance.occupation,
      'interests': instance.interests,
      'achievements': instance.achievements,
      'streaks': instance.streaks,
      'badges': instance.badges,
      'socialConnections': instance.socialConnections,
      'subscriptionTier': instance.subscriptionTier,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'isVerified': instance.isVerified,
      'isPremium': instance.isPremium,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'prefer_not_to_say',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.lightlyActive: 'lightly_active',
  ActivityLevel.moderatelyActive: 'moderately_active',
  ActivityLevel.veryActive: 'very_active',
  ActivityLevel.extraActive: 'extra_active',
};

FitnessGoal _$FitnessGoalFromJson(Map<String, dynamic> json) => FitnessGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      priority: (json['priority'] as num).toInt(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      isActive: json['isActive'] as bool,
      description: json['description'] as String?,
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$FitnessGoalToJson(FitnessGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'priority': instance.priority,
      'targetDate': instance.targetDate.toIso8601String(),
      'isActive': instance.isActive,
      'description': instance.description,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'unit': instance.unit,
    };

DietaryRestriction _$DietaryRestrictionFromJson(Map<String, dynamic> json) =>
    DietaryRestriction(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DietaryRestrictionToJson(DietaryRestriction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'severity': instance.severity,
      'description': instance.description,
      'notes': instance.notes,
    };

MedicalCondition _$MedicalConditionFromJson(Map<String, dynamic> json) =>
    MedicalCondition(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String?,
      medications: (json['medications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MedicalConditionToJson(MedicalCondition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'severity': instance.severity,
      'description': instance.description,
      'medications': instance.medications,
      'notes': instance.notes,
    };

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'relationship': instance.relationship,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
    };

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      workoutReminders: json['workoutReminders'] as bool,
      mealReminders: json['mealReminders'] as bool,
      moodCheckIns: json['moodCheckIns'] as bool,
      meditationReminders: json['meditationReminders'] as bool,
      achievementCelebrations: json['achievementCelebrations'] as bool,
      weeklyReports: json['weeklyReports'] as bool,
      promotionalEmails: json['promotionalEmails'] as bool,
      pushNotifications: json['pushNotifications'] as bool,
      emailNotifications: json['emailNotifications'] as bool,
      reminderTime: json['reminderTime'] as String?,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'workoutReminders': instance.workoutReminders,
      'mealReminders': instance.mealReminders,
      'moodCheckIns': instance.moodCheckIns,
      'meditationReminders': instance.meditationReminders,
      'achievementCelebrations': instance.achievementCelebrations,
      'weeklyReports': instance.weeklyReports,
      'promotionalEmails': instance.promotionalEmails,
      'pushNotifications': instance.pushNotifications,
      'emailNotifications': instance.emailNotifications,
      'reminderTime': instance.reminderTime,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
    };

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      profileVisibility: json['profileVisibility'] as String,
      activitySharing: json['activitySharing'] as bool,
      dataSharing: json['dataSharing'] as bool,
      locationSharing: json['locationSharing'] as bool,
      healthDataSharing: json['healthDataSharing'] as bool,
      allowedConnections: (json['allowedConnections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'profileVisibility': instance.profileVisibility,
      'activitySharing': instance.activitySharing,
      'dataSharing': instance.dataSharing,
      'locationSharing': instance.locationSharing,
      'healthDataSharing': instance.healthDataSharing,
      'allowedConnections': instance.allowedConnections,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      points: (json['points'] as num).toInt(),
      icon: json['icon'] as String?,
      badge: json['badge'] as String?,
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'points': instance.points,
      'icon': instance.icon,
      'badge': instance.badge,
    };

Badge _$BadgeFromJson(Map<String, dynamic> json) => Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      icon: json['icon'] as String?,
      rarity: json['rarity'] as String?,
    );

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'icon': instance.icon,
      'rarity': instance.rarity,
    };

SocialConnection _$SocialConnectionFromJson(Map<String, dynamic> json) =>
    SocialConnection(
      id: json['id'] as String,
      type: json['type'] as String,
      username: json['username'] as String,
      isConnected: json['isConnected'] as bool,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$SocialConnectionToJson(SocialConnection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'username': instance.username,
      'isConnected': instance.isConnected,
      'displayName': instance.displayName,
      'avatar': instance.avatar,
    };
