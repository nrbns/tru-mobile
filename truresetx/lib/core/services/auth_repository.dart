import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_auth_adapter.dart';
import 'firebase_auth_adapter.dart';
import 'clerk_auth_adapter.dart';
import 'auth_backend.dart';

/// Abstract auth repository contract used by the UI.
abstract class AuthRepository {
  Future<void> initialize();

  Future<dynamic> signUp(
      {required String email, required String password, String? fullName});
  Future<dynamic> signIn({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);

  /// Returns the current user's id for the active backend, or `null` if not signed in.
  String? get currentUserId;

  Stream<dynamic> get authStateChanges;
  bool get isAuthenticated;
}

/// Provider that returns the selected adapter instance based on
/// [kDefaultAuthBackend]. You can replace this with a runtime selection
/// (read from settings or environment) if you want to switch backends
/// without a rebuild.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final backend = ref.watch(authBackendProvider);
  switch (backend) {
    case AuthBackend.firebase:
      return FirebaseAuthAdapter.instance;
    case AuthBackend.supabase:
      return SupabaseAuthAdapter.instance;
    case AuthBackend.clerk:
      return ClerkAuthAdapter.instance;
  }
});

/// Stream provider that exposes backend-specific auth state change events.
final authStateStreamProvider = StreamProvider<dynamic>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Convenience provider that returns whether a user is signed in.
final authSignedInProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges.map((event) => repo.isAuthenticated);
});
