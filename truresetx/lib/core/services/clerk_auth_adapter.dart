import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';
import 'auth_repository.dart';

/// Clerk adapter that supports a backend-mediated flow. The adapter calls
/// a configurable `Environment.clerkBaseUrl` which should point to a
/// server endpoint that exchanges Clerk sessions/tokens. If no URL is
/// configured, methods throw and act as a no-op scaffold.
class ClerkAuthAdapter implements AuthRepository {
  ClerkAuthAdapter._();
  static final ClerkAuthAdapter instance = ClerkAuthAdapter._();

  String get _baseUrl => Environment.clerkBaseUrl;
  bool get _isConfigured => _baseUrl.isNotEmpty;

  String? _currentUserId;

  @override
  Future<void> initialize() async {
    // No-op for now; if you provide a backend that pings Clerk, we can
    // optionally poll for session state here.
  }

  @override
  Future<dynamic> signUp(
      {required String email,
      required String password,
      String? fullName}) async {
    if (!_isConfigured) {
      throw UnimplementedError('Clerk base URL not configured');
    }
    final resp = await http.post(Uri.parse('$_baseUrl/signup'), body: {
      'email': email,
      'password': password,
      if (fullName != null) 'fullName': fullName,
    });
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body);
      _currentUserId = body['user']?['id']?.toString();
      return body;
    }
    throw Exception('Clerk signUp failed: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<dynamic> signIn(
      {required String email, required String password}) async {
    if (!_isConfigured) {
      throw UnimplementedError('Clerk base URL not configured');
    }
    final resp = await http.post(Uri.parse('$_baseUrl/signin'), body: {
      'email': email,
      'password': password,
    });
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body);
      _currentUserId = body['user']?['id']?.toString();
      return body;
    }
    throw Exception('Clerk signIn failed: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<void> signInWithGoogle() async {
    if (!_isConfigured) {
      throw UnimplementedError('Clerk base URL not configured');
    }
    // For social SSO we expect the backend to redirect flows; mobile flows
    // typically require a browser redirect. Leave as TODO for a specific
    // integration path.
    throw UnimplementedError(
        'Clerk social sign-in not implemented in adapter.');
  }

  @override
  Future<void> signInWithApple() async {
    throw UnimplementedError('Clerk Apple sign-in not implemented.');
  }

  @override
  Future<void> signOut() async {
    if (!_isConfigured) {
      throw UnimplementedError('Clerk base URL not configured');
    }
    final resp = await http.post(Uri.parse('$_baseUrl/signout'));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      _currentUserId = null;
      return;
    }
    throw Exception('Clerk signOut failed: ${resp.statusCode} ${resp.body}');
  }

  @override
  Future<void> resetPassword(String email) async {
    if (!_isConfigured) {
      throw UnimplementedError('Clerk base URL not configured');
    }
    final resp = await http
        .post(Uri.parse('$_baseUrl/reset-password'), body: {'email': email});
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    throw Exception(
        'Clerk resetPassword failed: ${resp.statusCode} ${resp.body}');
  }

  @override
  Stream<dynamic> get authStateChanges => const Stream.empty();

  @override
  bool get isAuthenticated => _currentUserId != null;

  @override
  String? get currentUserId => _currentUserId;
}

final clerkAuthAdapterProvider = Provider<AuthRepository>((ref) {
  return ClerkAuthAdapter.instance;
});
