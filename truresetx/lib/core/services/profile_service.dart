import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_profile.dart';
import 'supabase_service.dart';
import 'current_user_provider.dart';

/// Profile Service for managing user profiles
class ProfileService {
  ProfileService({required SupabaseService supabase}) : _supabase = supabase;

  final SupabaseService _supabase;

  /// Create a new user profile
  Future<UserProfile> createProfile(UserProfile profile) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .insert({
            'id': profile.id,
            'email': profile.email,
            'full_name': profile.fullName,
            'date_of_birth': profile.dateOfBirth.toIso8601String(),
            'gender': profile.gender.name,
            'height': profile.height,
            'weight': profile.weight,
            'activity_level': profile.activityLevel.name,
            'fitness_goals':
                profile.fitnessGoals.map((goal) => goal.toJson()).toList(),
            'dietary_restrictions': profile.dietaryRestrictions
                .map((restriction) => restriction.toJson())
                .toList(),
            'medical_conditions': profile.medicalConditions
                .map((condition) => condition.toJson())
                .toList(),
            'emergency_contact': profile.emergencyContact.toJson(),
            'preferred_workout_time': profile.preferredWorkoutTime,
            'timezone': profile.timezone,
            'language': profile.language,
            'notification_settings': profile.notificationSettings.toJson(),
            'privacy_settings': profile.privacySettings.toJson(),
            'profile_picture': profile.profilePicture,
            'bio': profile.bio,
            'location': profile.location,
            'occupation': profile.occupation,
            'interests': profile.interests,
            'achievements': profile.achievements
                ?.map((achievement) => achievement.toJson())
                .toList(),
            'streaks': profile.streaks,
            'badges': profile.badges?.map((badge) => badge.toJson()).toList(),
            'social_connections': profile.socialConnections
                ?.map((connection) => connection.toJson())
                .toList(),
            'subscription_tier': profile.subscriptionTier,
            'is_verified': profile.isVerified,
            'is_premium': profile.isPremium,
            'created_at': profile.createdAt.toIso8601String(),
            'updated_at': profile.updatedAt.toIso8601String(),
          })
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .update({
            'full_name': profile.fullName,
            'date_of_birth': profile.dateOfBirth.toIso8601String(),
            'gender': profile.gender.name,
            'height': profile.height,
            'weight': profile.weight,
            'activity_level': profile.activityLevel.name,
            'fitness_goals':
                profile.fitnessGoals.map((goal) => goal.toJson()).toList(),
            'dietary_restrictions': profile.dietaryRestrictions
                .map((restriction) => restriction.toJson())
                .toList(),
            'medical_conditions': profile.medicalConditions
                .map((condition) => condition.toJson())
                .toList(),
            'emergency_contact': profile.emergencyContact.toJson(),
            'preferred_workout_time': profile.preferredWorkoutTime,
            'timezone': profile.timezone,
            'language': profile.language,
            'notification_settings': profile.notificationSettings.toJson(),
            'privacy_settings': profile.privacySettings.toJson(),
            'profile_picture': profile.profilePicture,
            'bio': profile.bio,
            'location': profile.location,
            'occupation': profile.occupation,
            'interests': profile.interests,
            'achievements': profile.achievements
                ?.map((achievement) => achievement.toJson())
                .toList(),
            'streaks': profile.streaks,
            'badges': profile.badges?.map((badge) => badge.toJson()).toList(),
            'social_connections': profile.socialConnections
                ?.map((connection) => connection.toJson())
                .toList(),
            'subscription_tier': profile.subscriptionTier,
            'is_verified': profile.isVerified,
            'is_premium': profile.isPremium,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Delete user profile
  Future<void> deleteProfile(String userId) async {
    try {
      await _supabase.client.from('profiles').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  /// Check if profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get profile completion percentage
  Future<double> getProfileCompletion(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return 0.0;

      int completedFields = 0;
      int totalFields = 10; // Adjust based on required fields

      // Check required fields
      if (profile.fullName.isNotEmpty) completedFields++;
      if (profile.dateOfBirth != DateTime(1900)) completedFields++;
      if (profile.gender != Gender.preferNotToSay) completedFields++;
      if (profile.height > 0) completedFields++;
      if (profile.weight > 0) completedFields++;
      if (profile.activityLevel != ActivityLevel.moderatelyActive) {
        completedFields++;
      }
      if (profile.fitnessGoals.isNotEmpty) completedFields++;
      if (profile.bio != null && profile.bio!.isNotEmpty) completedFields++;
      if (profile.location != null && profile.location!.isNotEmpty) {
        completedFields++;
      }
      if (profile.hasProfilePicture) completedFields++;

      return completedFields / totalFields;
    } catch (e) {
      return 0.0;
    }
  }

  /// Add fitness goal
  Future<void> addFitnessGoal(String userId, FitnessGoal goal) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      final updatedGoals = [...profile.fitnessGoals, goal];

      await _supabase.client.from('profiles').update({
        'fitness_goals': updatedGoals.map((goal) => goal.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to add fitness goal: $e');
    }
  }

  /// Update fitness goal
  Future<void> updateFitnessGoal(String userId, FitnessGoal goal) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      final updatedGoals =
          profile.fitnessGoals.map((g) => g.id == goal.id ? goal : g).toList();

      await _supabase.client.from('profiles').update({
        'fitness_goals': updatedGoals.map((goal) => goal.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update fitness goal: $e');
    }
  }

  /// Remove fitness goal
  Future<void> removeFitnessGoal(String userId, String goalId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      final updatedGoals =
          profile.fitnessGoals.where((g) => g.id != goalId).toList();

      await _supabase.client.from('profiles').update({
        'fitness_goals': updatedGoals.map((goal) => goal.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to remove fitness goal: $e');
    }
  }

  /// Add achievement
  Future<void> addAchievement(String userId, Achievement achievement) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      final updatedAchievements = [
        ...(profile.achievements ?? []),
        achievement
      ];

      await _supabase.client.from('profiles').update({
        'achievements': updatedAchievements
            .map((achievement) => achievement.toJson())
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to add achievement: $e');
    }
  }

  /// Add badge
  Future<void> addBadge(String userId, Badge badge) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      final updatedBadges = [...(profile.badges ?? []), badge];

      await _supabase.client.from('profiles').update({
        'badges': updatedBadges.map((badge) => badge.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to add badge: $e');
    }
  }

  /// Update streaks
  Future<void> updateStreaks(String userId, Map<String, int> streaks) async {
    try {
      await _supabase.client.from('profiles').update({
        'streaks': streaks,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update streaks: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      return {
        'profile_completion': await getProfileCompletion(userId),
        'bmi': profile.bmi,
        'bmi_category': profile.bmiCategory,
        'age': profile.age,
        'active_goals':
            profile.fitnessGoals.where((goal) => goal.isActive).length,
        'total_goals': profile.fitnessGoals.length,
        'achievements_count': profile.achievements?.length ?? 0,
        'badges_count': profile.badges?.length ?? 0,
        'dietary_restrictions_count': profile.dietaryRestrictions.length,
        'medical_conditions_count': profile.medicalConditions.length,
      };
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  /// Search profiles (for community features)
  Future<List<UserProfile>> searchProfiles({
    String? query,
    String? location,
    List<String>? interests,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Fetch a page of profiles and apply safe client-side filtering.
      final response = await _supabase.client
          .from('profiles')
          .select()
          .range(offset, offset + limit - 1);

      final data = response;

      final List results = data as List;

      // Apply client-side filters: privacy, query, location, interests
      final filtered = results.where((item) {
        try {
          final Map<String, dynamic> json =
              Map<String, dynamic>.from(item as Map);

          // privacy_settings may be stored as Map or JSON-string
          String visibility = '';
          final ps = json['privacy_settings'];
          if (ps is Map && ps['profile_visibility'] != null) {
            visibility = ps['profile_visibility'].toString();
          } else if (ps is String && ps.isNotEmpty) {
            try {
              final decoded = jsonDecode(ps);
              if (decoded is Map && decoded['profile_visibility'] != null) {
                visibility = decoded['profile_visibility'].toString();
              }
            } catch (_) {}
          }

          if (visibility != 'public') return false;

          if (query != null && query.isNotEmpty) {
            final name = (json['full_name'] ?? '').toString().toLowerCase();
            final bio = (json['bio'] ?? '').toString().toLowerCase();
            final q = query.toLowerCase();
            if (!name.contains(q) && !bio.contains(q)) return false;
          }

          if (location != null && location.isNotEmpty) {
            if ((json['location'] ?? '').toString() != location) return false;
          }

          if (interests != null && interests.isNotEmpty) {
            final its = json['interests'];
            if (its is List) {
              final lower = its.map((e) => e.toString().toLowerCase()).toList();
              final any = interests.any((i) => lower.contains(i.toLowerCase()));
              if (!any) return false;
            }
          }

          return true;
        } catch (e) {
          return false;
        }
      }).toList();

      return filtered
          .map((json) =>
              UserProfile.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }

  /// Get profile recommendations
  Future<List<UserProfile>> getProfileRecommendations(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return [];

      // Get profiles with similar interests or location
      final recommendations = <UserProfile>[];

      if (profile.interests != null && profile.interests!.isNotEmpty) {
        final similarProfiles = await searchProfiles(
          interests: profile.interests!.take(3).toList(),
          limit: 5,
        );
        recommendations.addAll(similarProfiles);
      }

      if (profile.location != null) {
        final localProfiles = await searchProfiles(
          location: profile.location,
          limit: 5,
        );
        recommendations.addAll(localProfiles);
      }

      // Remove duplicates and current user
      final uniqueRecommendations =
          recommendations.where((p) => p.id != userId).toSet().toList();

      return uniqueRecommendations.take(10).toList();
    } catch (e) {
      print('Error getting profile recommendations: $e');
      return [];
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _supabase.client.from('profiles').update({
        'last_active_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      print('Error updating last active: $e');
    }
  }

  /// Get profile analytics
  Future<Map<String, dynamic>> getProfileAnalytics(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) throw Exception('Profile not found');

      return {
        'profile_age_days': DateTime.now().difference(profile.createdAt).inDays,
        'last_updated_days_ago':
            DateTime.now().difference(profile.updatedAt).inDays,
        'completion_percentage': await getProfileCompletion(userId),
        'goals_completion_rate':
            _calculateGoalsCompletionRate(profile.fitnessGoals),
        'health_metrics_completeness':
            _calculateHealthMetricsCompleteness(profile),
        'social_engagement': _calculateSocialEngagement(profile),
      };
    } catch (e) {
      throw Exception('Failed to get profile analytics: $e');
    }
  }

  double _calculateGoalsCompletionRate(List<FitnessGoal> goals) {
    if (goals.isEmpty) return 0.0;

    final completedGoals = goals.where((goal) {
      if (goal.targetValue == null || goal.currentValue == null) return false;
      return goal.currentValue! >= goal.targetValue!;
    }).length;

    return completedGoals / goals.length;
  }

  double _calculateHealthMetricsCompleteness(UserProfile profile) {
    int completed = 0;
    int total = 6;

    if (profile.height > 0) completed++;
    if (profile.weight > 0) completed++;
    if (profile.dateOfBirth != DateTime(1900)) completed++;
    if (profile.activityLevel != ActivityLevel.moderatelyActive) completed++;
    if (profile.dietaryRestrictions.isNotEmpty) completed++;
    if (profile.medicalConditions.isNotEmpty) completed++;

    return completed / total;
  }

  double _calculateSocialEngagement(UserProfile profile) {
    int engagement = 0;
    int total = 3;

    if (profile.socialConnections != null &&
        profile.socialConnections!.isNotEmpty) {
      engagement++;
    }
    if (profile.bio != null && profile.bio!.isNotEmpty) {
      engagement++;
    }
    if (profile.interests != null && profile.interests!.isNotEmpty) {
      engagement++;
    }

    return engagement / total;
  }
}

/// Provider for Profile Service
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(supabase: ref.read(supabaseServiceProvider));
});

/// Provider for current user profile
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final profileService = ref.read(profileServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return null;

  return await profileService.getProfile(userId);
});

/// Provider for profile completion percentage
final profileCompletionProvider = FutureProvider<double>((ref) async {
  final profileService = ref.read(profileServiceProvider);
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return 0.0;

  return await profileService.getProfileCompletion(user.id);
});

/// Provider for user statistics
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final profileService = ref.read(profileServiceProvider);
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return {};

  return await profileService.getUserStats(user.id);
});

