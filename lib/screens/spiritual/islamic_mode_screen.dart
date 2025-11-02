import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/faith_provider.dart';

class IslamicModeScreen extends ConsumerWidget {
  const IslamicModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayah = ref.watch(islamicAyahProvider(1));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text('Islamic Mode',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ayah.when(
                    data: (v) => v.isEmpty
                        ? const SizedBox.shrink()
                        : AuraCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Daily Ayah',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text((v.first['text'] ?? '') as String,
                                    style: TextStyle(
                                        color: Colors.grey[300], height: 1.6)),
                                if (v.first['translation'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text((v.first['translation'] ?? '') as String,
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12)),
                                ],
                              ],
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
