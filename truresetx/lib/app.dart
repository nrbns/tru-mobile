import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';
import 'core/theme/app_theme.dart';

class TruResetXApp extends ConsumerWidget {
  const TruResetXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'TruResetX',
      debugShowCheckedModeBanner: false,
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
