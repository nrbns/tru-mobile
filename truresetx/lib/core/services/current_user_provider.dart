import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';

/// Provides the current user's id (backend-agnostic) or null if not signed in.
final currentUserIdProvider = Provider<String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUserId;
});
