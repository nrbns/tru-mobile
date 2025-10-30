import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_provider.dart';

class WisdomFeedScreen extends ConsumerStatefulWidget {
  const WisdomFeedScreen({super.key});

  @override
  ConsumerState<WisdomFeedScreen> createState() => _WisdomFeedScreenState();
}

class _WisdomFeedScreenState extends ConsumerState<WisdomFeedScreen> {
  @override
  void initState() {
    super.initState();
    // Generate daily wisdom if not exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wisdomAsync = ref.read(dailyWisdomProvider);
      wisdomAsync.whenData((wisdom) {
        if (wisdom == null) {
          final service = ref.read(spiritualContentServiceProvider);
          service.generateDailyWisdom();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final wisdomAsync = ref.watch(dailyWisdomProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wisdom Feed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Daily wisdom and insights',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Feed
            Expanded(
              child: wisdomAsync.when(
                data: (wisdom) {
                  if (wisdom == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.bookOpenText,
                              size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'Generating daily wisdom...',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              final service =
                                  ref.read(spiritualContentServiceProvider);
                              service.generateDailyWisdom();
                            },
                            child: const Text('Generate Wisdom'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final service = ref.read(spiritualContentServiceProvider);
                      await service.generateDailyWisdom();
                      final _ = ref.refresh(dailyWisdomProvider);
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _WisdomCard(wisdom: wisdom),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading wisdom',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(dailyWisdomProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WisdomCard extends StatelessWidget {
  final Map<String, dynamic> wisdom;

  const _WisdomCard({required this.wisdom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AuraCard(
        variant: AuraCardVariant.spiritual,
        glow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Wisdom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (wisdom['tradition'] != null)
                        Text(
                          wisdom['tradition'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.heart, size: 20),
                  color: AppColors.spiritualColor,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (wisdom['quote'] != null) ...[
              Text(
                wisdom['quote'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (wisdom['reflection'] != null) ...[
              Text(
                wisdom['reflection'] as String,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[300],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (wisdom['practice_suggestion'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          AppColors.secondary.withAlpha((0.3 * 255).round())),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.lightbulb,
                        size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wisdom['practice_suggestion'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.heart, size: 18),
                  color: AppColors.spiritualColor,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(LucideIcons.share2, size: 18),
                  color: AppColors.spiritualColor,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(LucideIcons.bookmark, size: 18),
                  color: AppColors.spiritualColor,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
