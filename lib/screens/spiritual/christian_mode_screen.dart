import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/faith_provider.dart';

class ChristianModeScreen extends ConsumerWidget {
  const ChristianModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = ref.watch(christianVersesProvider(1));
    final devos = ref.watch(christianDevotionalsProvider(5));
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
                    child: Text('Christian Mode',
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
                  verses.when(
                    data: (v) => v.isEmpty
                        ? const SizedBox.shrink()
                        : AuraCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Daily Verse',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text((v.first['text'] ?? '') as String,
                                    style: TextStyle(
                                        color: Colors.grey[300], height: 1.6)),
                              ],
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  devos.when(
                    data: (d) => Column(
                      children: d
                          .map((it) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AuraCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          (it['title'] ?? 'Devotional')
                                              as String,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Text((it['reflection'] ?? '') as String,
                                          style: TextStyle(
                                              color: Colors.grey[300])),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
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
