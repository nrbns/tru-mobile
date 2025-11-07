import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import 'auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthAdapter implements AuthRepository {
  SupabaseAuthAdapter._();
  static final SupabaseAuthAdapter instance = SupabaseAuthAdapter._();

  final AuthService _svc = AuthService.instance;

  @override
  Future<void> initialize() async {
    await _svc.initialize();
  }

  @override
  Future<dynamic> signUp(
      {required String email,
      required String password,
      String? fullName}) async {
    return await _svc.signUp(
        email: email, password: password, fullName: fullName);
  }

  @override
  Future<dynamic> signIn(
      {required String email, required String password}) async {
    return await _svc.signIn(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    return await _svc.signInWithGoogle();
  }

  @override
  Future<void> signInWithApple() async {
    return await _svc.signInWithApple();
  }

  @override
  Future<void> signOut() async {
    return await _svc.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    return await _svc.resetPassword(email);
  }

  @override
  Stream<dynamic> get authStateChanges =>
      // Map supabase events to the session/user object already used elsewhere
      SupabaseAuthShim.instance.authStateChanges;

  @override
  bool get isAuthenticated => _svc.isAuthenticated;

  @override
  String? get currentUserId => _svc.userId;
}

/// Lightweight shim to expose the existing Supabase onAuthStateChange stream
class SupabaseAuthShim {
  SupabaseAuthShim._();
  static final SupabaseAuthShim instance = SupabaseAuthShim._();

  // We reference the existing Supabase client stream from auth_service.
  Stream<dynamic> get authStateChanges {
    // Forward the Supabase onAuthStateChange stream so consumers receive
    // session/user updates. Map to the session object for simplicity.
    return Supabase.instance.client.auth.onAuthStateChange
        .map((evt) => evt.session);
  }
}

/// Provider for the Supabase adapter
final supabaseAuthAdapterProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthAdapter.instance;
});
