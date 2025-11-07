import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/auth_provider.dart';
import '../widgets/error_state.dart';

/// AuthGate wraps screens that require authentication.
/// If the user is not signed in, it shows the SignInScreen.
class AuthGate extends ConsumerWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Not authenticated - redirect to sign-in route preserving the
          // attempted path so we can return the user after successful login.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final router = GoRouter.of(context);
            // Use the current browser/app URI as the attempted location. Encode
            // it and pass as a query param to the sign-in route.
            final attemptedPath =
                Uri.base.path + (Uri.base.hasQuery ? '?${Uri.base.query}' : '');
            final redirectParam = Uri.encodeComponent(attemptedPath);
            router.go('/sign-in?redirect=$redirectParam');
          });
          return const Center(child: CircularProgressIndicator());
        }

        // Authenticated - show protected child
        return child;
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) =>
          ErrorState(title: 'Authentication error', message: e.toString()),
    );
  }
}
