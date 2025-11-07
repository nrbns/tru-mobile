import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/utils/lucide_compat.dart';

/// Spiritual Features Home Screen - Shows cards for Wisdom, Mantras, Audio Player, Rituals, Calendar
class SpiritualFeaturesHomeScreen extends StatelessWidget {
  const SpiritualFeaturesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spiritual Features',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Explore wisdom, mantras, and practices',
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
            // Feature Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FeatureCard(
                    title: 'Wisdom & Legends',
                    description: 'Thirukkural, Gita, Rumi & more',
                    icon: LucideIcons.bookOpen,
                    iconColor: Colors.purple,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                    ),
                    onTap: () => context.push('/spirit/wisdom-legends'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'Mantras Library',
                    description: 'Sacred verses and prayers',
                    icon: LucideIcons.music,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/spirit/mantras'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'Audio Verse Player',
                    description: 'Listen to your scriptures',
                    icon: LucideIcons.headphones,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/spirit/audio-player'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'Rituals Tracker',
                    description: 'Track your spiritual rituals',
                    icon: LucideIcons.calendar,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/spirit/rituals'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'Calendar View',
                    description: 'View your spiritual calendar',
                    icon: LucideIcons.calendarDays,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/spirit/calendar'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'Wisdom Feed',
                    description: 'Daily wisdom and insights',
                    icon: LucideIcons.bookOpenText,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/spirit/wisdom-feed'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'Streaks Detail',
                    description: 'Track your progress',
                    icon: LucideIcons.flame,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/spirit/streaks'),
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

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Gradient? gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AuraCard(
        child: Container(
          decoration: gradient != null
              ? BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16))
              : null,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: gradient == null
                      ? AppColors.surface.withAlpha((0.3 * 255).round())
                      : Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: gradient != null ? Colors.white : iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: gradient != null ? Colors.white : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: gradient != null
                            ? Colors.white.withAlpha((0.8 * 255).round())
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: gradient != null
                    ? Colors.white.withAlpha((0.7 * 255).round())
                    : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

