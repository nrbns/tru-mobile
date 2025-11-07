import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/crisis_support_provider.dart';

class SOSModeScreen extends ConsumerWidget {
  const SOSModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helplinesAsync = ref.watch(helplinesStreamProvider({}));
    return Scaffold(
      backgroundColor: AppColors.error.withAlpha((0.1 * 255).round()),
      body: SafeArea(
        child: Column(
          children: [
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
                          'SOS Mode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Quick help when you need it',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AuraCard(
                      variant: AuraCardVariant.default_,
                      glow: true,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error,
                                  AppColors.error.withAlpha((0.7 * 255).round())
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error
                                      .withAlpha((0.5 * 255).round()),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.phone,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Emergency Contacts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          helplinesAsync.when(
                            data: (helplines) {
                              if (helplines.isEmpty) {
                                return const SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: null,
                                    child: Text('No helplines available'),
                                  ),
                                );
                              }
                              final primaryHelpline = helplines.first;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final service = ref
                                          .read(crisisSupportServiceProvider);
                                      await service.callHelpline(
                                          primaryHelpline['number'] ?? '');
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error calling: $e'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LucideIcons.phone, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Call ${primaryHelpline['organization'] ?? 'Crisis Line'}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox(
                              width: double.infinity,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stack) => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error
                                      .withAlpha((0.5 * 255).round()),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Call 911 (Emergency)'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _QuickHelpCard(
                      icon: LucideIcons.wind,
                      title: 'Breathing Exercise',
                      description: 'Guided breathing to calm down',
                      onTap: () async {
                        final service = ref.read(crisisSupportServiceProvider);
                        final _ = await service.getBreathingSOSExercise();
                        // Navigate to breathing exercise screen
                        // context.push('/mind/breathing-sos', extra: exercise);
                      },
                    ),
                    _QuickHelpCard(
                      icon: LucideIcons.brain,
                      title: 'Grounding Technique',
                      description: '5-4-3-2-1 grounding method',
                      onTap: () async {
                        final service = ref.read(crisisSupportServiceProvider);
                        final _ = await service.getGroundingSOSExercise();
                        // Navigate to grounding exercise screen
                        // context.push('/mind/grounding-sos', extra: exercise);
                      },
                    ),
                    _QuickHelpCard(
                      icon: LucideIcons.heart,
                      title: 'Safety Plan',
                      description: 'View your safety plan',
                      onTap: () {
                        // Navigate to safety plan screen
                        // context.push('/mind/safety-plan');
                      },
                    ),
                    const SizedBox(height: 24),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.info, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Helplines',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          helplinesAsync.when(
                            data: (helplines) {
                              if (helplines.isEmpty) {
                                return const _ResourceItem(
                                  title: 'Emergency Services',
                                  number: '911',
                                );
                              }
                              return Column(
                                children: helplines
                                    .take(5)
                                    .map((helpline) => _ResourceItem(
                                          title: helpline['organization'] ??
                                              'Crisis Line',
                                          number: helpline['number'] ?? '',
                                          onTap: () async {
                                            try {
                                              final service = ref.read(
                                                  crisisSupportServiceProvider);
                                              await service.callHelpline(
                                                  helpline['number'] ?? '');
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                    backgroundColor:
                                                        AppColors.error,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ))
                                    .toList(),
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const _ResourceItem(
                              title: 'Emergency Services',
                              number: '911',
                            ),
                          ),
                          const _ResourceItem(
                            title: 'Emergency Services',
                            number: '911',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickHelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _QuickHelpCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            color: AppColors.primary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final String title;
  final String number;
  final VoidCallback? onTap;

  const _ResourceItem({
    required this.title,
    required this.number,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    LucideIcons.phone,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
