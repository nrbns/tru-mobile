import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_feed_provider.dart';

class SpiritualFeedScreen extends ConsumerWidget {
  const SpiritualFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(dailySpiritualFeedProvider);
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
                    child: Text('Spiritual Feed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: feedAsync.when(
                data: (feed) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (feed['daily_quote'] != null)
                      AuraCard(
                        variant: AuraCardVariant.spiritual,
                        glow: true,
                        child: Text(feed['daily_quote'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                height: 1.6)),
                      ),
                    const SizedBox(height: 12),
                    if (feed['reflection_prompt'] != null)
                      AuraCard(
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb,
                                color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(feed['reflection_prompt'] as String,
                                    style:
                                        const TextStyle(color: Colors.white))),
                          ],
                        ),
                      ),
                    if (feed['gratitude_prompt'] != null) ...[
                      const SizedBox(height: 12),
                      AuraCard(
                        child: Row(
                          children: [
                            const Icon(Icons.favorite,
                                color: AppColors.spiritualColor),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(feed['gratitude_prompt'] as String,
                                    style:
                                        const TextStyle(color: Colors.white))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
