// realtime_profile_service.dart
import 'dart:async';

// no Flutter material imports required in this service
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_profile.dart';

/// Abstract realtime profile service - implement with Supabase/Firebase/WSS
abstract class RealtimeProfileService {
  Stream<UserProfile> profileStream(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<void> setPresence(String userId, bool online);
  void dispose();
}

/// Mock implementation for local testing.
/// Emits the latest profile on a broadcast stream and simulates presence updates.
class MockRealtimeProfileService implements RealtimeProfileService {
  final Map<String, StreamController<UserProfile>> _controllers = {};
  final Map<String, UserProfile> _profiles = {};
  final Map<String, Timer?> _presenceTimers = {};

  @override
  Stream<UserProfile> profileStream(String userId) {
    if (!_controllers.containsKey(userId)) {
      _controllers[userId] = StreamController<UserProfile>.broadcast();
      // seed with an empty/placeholder profile if none present
      if (!_profiles.containsKey(userId)) {
        // Build a minimal seed profile using the real constructors available in the
        // codebase (avoid copyWith / defaultSettings which don't exist on models).
        final seed = UserProfile(
          id: userId,
          email: '',
          fullName: 'New User',
          dateOfBirth: DateTime(1900),
          gender: Gender.preferNotToSay,
          height: 170,
          weight: 70,
          activityLevel: ActivityLevel.moderatelyActive,
          fitnessGoals: const [],
          dietaryRestrictions: const [],
          medicalConditions: const [],
          // EmergencyContact is required by the model; provide an empty placeholder
          emergencyContact:
              EmergencyContact(name: '', relationship: '', phoneNumber: ''),
          preferredWorkoutTime: 'morning',
          timezone: 'UTC',
          language: 'en',
          notificationSettings: NotificationSettings(
            workoutReminders: true,
            mealReminders: true,
            moodCheckIns: true,
            meditationReminders: true,
            achievementCelebrations: true,
            weeklyReports: true,
            promotionalEmails: false,
            pushNotifications: true,
            emailNotifications: true,
            reminderTime: '09:00',
            quietHoursStart: '22:00',
            quietHoursEnd: '07:00',
          ),
          privacySettings: PrivacySettings(
            profileVisibility: 'private',
            activitySharing: false,
            dataSharing: false,
            locationSharing: false,
            healthDataSharing: false,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          bio: null,
          location: null,
          occupation: null,
        );
        _profiles[userId] = seed;
      }
      // push initial value
      Future.microtask(() => _controllers[userId]!.add(_profiles[userId]!));
    }
    return _controllers[userId]!.stream;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 400));
    // Real UserProfile doesn't expose copyWith; store a cloned profile but
    // ensure we update the updatedAt timestamp so consumers see a change.
    _profiles[profile.id] = _cloneWith(profile, updatedAt: DateTime.now());
    if (_controllers.containsKey(profile.id)) {
      _controllers[profile.id]!.add(_profiles[profile.id]!);
    }
  }

  @override
  Future<void> setPresence(String userId, bool online) async {
    if (!_profiles.containsKey(userId)) {
      return;
    }

    // Update timestamps on presence changes so UI can infer online status.
    final current = _profiles[userId]!;
    final newProfile = _cloneWith(
      current,
      lastActiveAt: online ? DateTime.now() : current.lastActiveAt,
      updatedAt: DateTime.now(),
    );
    _profiles[userId] = newProfile;

    // Emit immediately to listeners
    if (_controllers.containsKey(userId)) {
      _controllers[userId]!.add(newProfile);
    }

    _presenceTimers[userId]?.cancel();
    if (!online) {
      // when going offline, emit one more time shortly after to simulate
      // presence debounce/cleanup
      _presenceTimers[userId] = Timer(const Duration(seconds: 1), () {
        _controllers[userId]?.add(_profiles[userId]!);
      });
    }
  }

  // Helper to clone a UserProfile while overriding a couple of fields.
  UserProfile _cloneWith(UserProfile p,
      {DateTime? lastActiveAt, DateTime? updatedAt}) {
    return UserProfile(
      id: p.id,
      email: p.email,
      fullName: p.fullName,
      dateOfBirth: p.dateOfBirth,
      gender: p.gender,
      height: p.height,
      weight: p.weight,
      activityLevel: p.activityLevel,
      fitnessGoals: p.fitnessGoals,
      dietaryRestrictions: p.dietaryRestrictions,
      medicalConditions: p.medicalConditions,
      emergencyContact: p.emergencyContact,
      preferredWorkoutTime: p.preferredWorkoutTime,
      timezone: p.timezone,
      language: p.language,
      notificationSettings: p.notificationSettings,
      privacySettings: p.privacySettings,
      createdAt: p.createdAt,
      updatedAt: updatedAt ?? p.updatedAt,
      profilePicture: p.profilePicture,
      bio: p.bio,
      location: p.location,
      occupation: p.occupation,
      interests: p.interests,
      achievements: p.achievements,
      streaks: p.streaks,
      badges: p.badges,
      socialConnections: p.socialConnections,
      subscriptionTier: p.subscriptionTier,
      lastActiveAt: lastActiveAt ?? p.lastActiveAt,
      isVerified: p.isVerified,
      isPremium: p.isPremium,
    );
  }

  @override
  void dispose() {
    for (final t in _presenceTimers.values) {
      t?.cancel();
    }
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
    _profiles.clear();
  }
}

/// Riverpod provider for the service. Replace with your real implementation.
final realtimeProfileServiceProvider = Provider<RealtimeProfileService>((ref) {
  final mock = MockRealtimeProfileService();
  ref.onDispose(() => mock.dispose());
  return mock;
});

/// Stream provider to watch a user's profile in realtime.
final userProfileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile, String>((ref, userId) {
  final service = ref.watch(realtimeProfileServiceProvider);
  return service.profileStream(userId);
});
