import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Enum describing available backends. Keep in sync with adapters.
enum AuthBackend { supabase, firebase, clerk }

/// Hive box/key used to persist the selected backend
const String _kSettingsBox = 'settings';
const String _kAuthBackendKey = 'auth_backend';

class AuthBackendNotifier extends StateNotifier<AuthBackend> {
  AuthBackendNotifier() : super(AuthBackend.supabase) {
    _load();
  }

  Future<void> _load() async {
    try {
      final box = Hive.box(_kSettingsBox);
      final val = box.get(_kAuthBackendKey, defaultValue: 'supabase') as String;
      switch (val) {
        case 'firebase':
          state = AuthBackend.firebase;
          break;
        case 'clerk':
          state = AuthBackend.clerk;
          break;
        case 'supabase':
        default:
          state = AuthBackend.supabase;
      }
    } catch (_) {
      // If Hive isn't ready, keep default
      state = AuthBackend.supabase;
    }
  }

  Future<void> setBackend(AuthBackend backend) async {
    state = backend;
    try {
      final box = Hive.box(_kSettingsBox);
      final val = backend == AuthBackend.firebase
          ? 'firebase'
          : backend == AuthBackend.clerk
              ? 'clerk'
              : 'supabase';
      await box.put(_kAuthBackendKey, val);
    } catch (_) {
      // ignore persistence errors
    }
  }
}

final authBackendProvider =
    StateNotifierProvider<AuthBackendNotifier, AuthBackend>((ref) {
  return AuthBackendNotifier();
});
