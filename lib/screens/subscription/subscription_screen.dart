import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/services/subscription_service.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final limitsAsync = ref.watch(subscriptionLimitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha((0.8 * 255).round()),
                border: const Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
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
                          'Subscription',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Choose your plan',
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Current Status
                    statusAsync.when(
                      data: (status) => AuraCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.crown,
                                  color: status['is_active'] == true
                                      ? AppColors.warning
                                      : Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Current Plan: ${status['tier']?.toString().toUpperCase() ?? 'FREE'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (status['expires_at'] != null)
                                        Text(
                                          'Expires: ${status['expires_at']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    // Plans
                    _buildPlanCard(
                      context,
                      'Free',
                      'Perfect to get started',
                      0,
                      [
                        '10 AI messages/day',
                        'Basic features',
                        '7-day analytics',
                        'Ads included'
                      ],
                      SubscriptionTier.free,
                      ref,
                    ),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      context,
                      'Premium',
                      'Unlock full potential',
                      99,
                      [
                        'Unlimited AI chat',
                        'Meal planning',
                        '365-day analytics',
                        'Exercise videos',
                        'Ad-free'
                      ],
                      SubscriptionTier.premium,
                      ref,
                    ),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      context,
                      'Premium Plus',
                      'Ultimate experience',
                      199,
                      [
                        'Everything in Premium',
                        'Wearable sync',
                        'Priority support',
                        'Custom challenges',
                        'Offline mode'
                      ],
                      SubscriptionTier.premiumPlus,
                      ref,
                    ),
                    const SizedBox(height: 24),
                    // Current Limits
                    limitsAsync.when(
                      data: (limits) => AuraCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Limits',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...limits.entries.map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                      Text(
                                        entry.value == -1
                                            ? 'Unlimited'
                                            : entry.value == true
                                                ? 'Enabled'
                                                : entry.value == false
                                                    ? 'Disabled'
                                                    : entry.value.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (err, stack) => const SizedBox.shrink(),
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

  Widget _buildPlanCard(
    BuildContext context,
    String title,
    String description,
    int price,
    List<String> features,
    SubscriptionTier tier,
    WidgetRef ref,
  ) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final isCurrent = statusAsync.valueOrNull?['tier'] == tier.name;

    return AuraCard(
      variant: tier == SubscriptionTier.free
          ? AuraCardVariant.default_
          : tier == SubscriptionTier.premium
              ? AuraCardVariant.nutrition
              : AuraCardVariant.ai,
      glow: tier != SubscriptionTier.free,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
              if (price > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: tier == SubscriptionTier.premiumPlus
                            ? AppColors.primary
                            : AppColors.nutritionColor,
                      ),
                    ),
                    Text(
                      '/month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.check,
                      size: 16,
                      color: tier == SubscriptionTier.free
                          ? Colors.grey
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent
                  ? null
                  : () {
                      // TODO: Implement payment flow
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment integration coming soon'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: tier == SubscriptionTier.free
                    ? AppColors.surface
                    : tier == SubscriptionTier.premium
                        ? AppColors.nutritionColor
                        : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isCurrent
                    ? 'Current Plan'
                    : price == 0
                        ? 'Continue'
                        : 'Subscribe',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
