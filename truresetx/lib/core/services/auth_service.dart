import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service for managing user sessions and authentication
class AuthService {
  AuthService._();
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Current user session
  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  bool get isAuthenticated => currentUser != null;
  String? get userId => currentUser?.id;
  String? get userEmail => currentUser?.email;

  /// Initialize authentication service
  Future<void> initialize() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _onSignedIn(session);
          break;
        case AuthChangeEvent.signedOut:
          _onSignedOut();
          break;
        case AuthChangeEvent.tokenRefreshed:
          _onTokenRefreshed(session);
          break;
        case AuthChangeEvent.userUpdated:
          _onUserUpdated(session);
          break;
        case AuthChangeEvent.passwordRecovery:
          _onPasswordRecovery();
          break;
        case AuthChangeEvent.initialSession:
          // initial session event: handle if needed
          if (session != null) _onSignedIn(session);
          break;
        default:
          // Fallback for any future events
          break;
      }
    });
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          ...?metadata,
        },
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(response.user!);
      }

      return response;
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.truresetx://login-callback/',
      );
    } catch (e) {
      throw AuthException('Google sign in failed: $e');
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.truresetx://login-callback/',
      );
    } catch (e) {
      throw AuthException('Apple sign in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.truresetx://reset-password/',
      );
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return response;
    } catch (e) {
      throw AuthException('Password update failed: $e');
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'avatar_url': avatarUrl,
            ...?metadata,
          },
        ),
      );

      return response;
    } catch (e) {
      throw AuthException('Profile update failed: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _supabase.auth.admin.deleteUser(userId!);
    } catch (e) {
      throw AuthException('Account deletion failed: $e');
    }
  }

  /// Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId!).single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile in database
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      await _supabase.from('profiles').update(profileData).eq('id', userId!);
    } catch (e) {
      throw AuthException('Profile update failed: $e');
    }
  }

  /// Create user profile in database
  Future<void> _createUserProfile(User user) async {
    try {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0],
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Profile creation is not critical, log and continue
      print('Failed to create user profile: $e');
    }
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      final profile = await getUserProfile();
      return profile?['onboarding_completed'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      await updateUserProfile({
        'onboarding_completed': true,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AuthException('Failed to complete onboarding: $e');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final profile = await getUserProfile();
      return profile?['preferences'] ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await updateUserProfile({
        'preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AuthException('Failed to update preferences: $e');
    }
  }

  /// Get user health data
  Future<Map<String, dynamic>> getUserHealthData() async {
    try {
      final profile = await getUserProfile();
      return {
        'height_cm': profile?['height_cm'],
        'weight_kg': profile?['weight_kg'],
        'goal': profile?['goal'],
        'birth_date': profile?['birth_date'],
        'gender': profile?['gender'],
      };
    } catch (e) {
      return {};
    }
  }

  /// Update user health data
  Future<void> updateUserHealthData(Map<String, dynamic> healthData) async {
    try {
      await updateUserProfile({
        ...healthData,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AuthException('Failed to update health data: $e');
    }
  }

  /// Auth state change handlers
  void _onSignedIn(Session? session) {
    final user = session?.user;
    final email = user?.email ?? 'unknown';
    print('User signed in: $email');
    // Additional logic for signed in state
  }

  void _onSignedOut() {
    print('User signed out');
    // Additional logic for signed out state
  }

  void _onTokenRefreshed(Session? session) {
    final user = session?.user;
    final email = user?.email ?? 'unknown';
    print('Token refreshed for: $email');
    // Additional logic for token refresh
  }

  void _onUserUpdated(Session? session) {
    final user = session?.user;
    final email = user?.email ?? 'unknown';
    print('User updated: $email');
    // Additional logic for user update
  }

  void _onPasswordRecovery() {
    print('Password recovery initiated');
    // Additional logic for password recovery
  }

  /// Get access token for API calls
  String? get accessToken => currentSession?.accessToken;

  /// Check if session is valid
  bool get isSessionValid {
    final session = currentSession;
    if (session == null) return false;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000,
    );

    return expiresAt.isAfter(DateTime.now());
  }

  /// Refresh session if needed
  Future<void> refreshSessionIfNeeded() async {
    if (!isSessionValid) {
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        print('Failed to refresh session: $e');
      }
    }
  }
}

/// Custom auth exception
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Provider for current user using Supabase auth state change stream
final currentUserProvider = StreamProvider<User?>((ref) {
  final client = Supabase.instance.client;
  // Map Supabase auth events to the current User (may be null)
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Provider for authentication state (signed in = true)
final authStateProvider = StreamProvider<bool>((ref) {
  final client = Supabase.instance.client;
  return client.auth.onAuthStateChange.map((event) => event.session != null);
});

/// Provider for user profile
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) return null;
  return await authService.getUserProfile();
});

/// Provider for user preferences
final userPreferencesProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) return {};
  return await authService.getUserPreferences();
});

/// Provider for user health data
final userHealthDataProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) return {};
  return await authService.getUserHealthData();
});
