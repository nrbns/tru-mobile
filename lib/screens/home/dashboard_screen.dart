import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/tracker_bar.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/agent_wrapper.dart';
import '../../core/providers/today_provider.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/providers/wisdom_provider.dart';
import '../../core/providers/activity_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayStreamProvider);
    final appState = ref.watch(appStateProvider);
    final activityAsync = ref.watch(todayActivityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AgentWrapper(
        child: SafeArea(
        bottom: false,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Real-Time Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFormattedDate(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      color: Colors.white,
                      size: 24,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Pulse Card
                    AuraCard(
                      variant: AuraCardVariant.ai,
                      glow: true,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: AppColors.aiGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.sparkles,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Pulse',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "You're doing great today! Your energy is up 23% compared to yesterday.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'View Insights →',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Mood & Energy Rings
                    todayAsync.when(
                      data: (today) {
                        // Calculate progress percentages (0-100)
                        final moodProgress = today.mood.latest != null
                            ? (today.mood.latest! / 10 * 100).clamp(0.0, 100.0)
                            : 0.0;
                        final waterProgress = (today.waterMl / 2000 * 100).clamp(0.0, 100.0);
                        final workoutProgress = (today.workouts.progress * 100).clamp(0.0, 100.0);
                        
                        // Get mood label
                        String moodLabel = 'Not Set';
                        if (today.mood.latest != null) {
                          if (today.mood.latest! >= 8) {
                            moodLabel = 'Excellent';
                          } else if (today.mood.latest! >= 6) {
                            moodLabel = 'Good';
                          } else if (today.mood.latest! >= 4) {
                            moodLabel = 'Fair';
                          } else {
                            moodLabel = 'Low';
                          }
                        }
                        
                        // Get energy label (based on mood and workouts)
                        final energyScore = (moodProgress + workoutProgress) / 2;
                        String energyLabel = 'Low';
                        if (energyScore >= 80) {
                          energyLabel = 'High';
                        } else if (energyScore >= 60) {
                          energyLabel = 'Good';
                        } else if (energyScore >= 40) {
                          energyLabel = 'Fair';
                        }
                        
                        return Row(
                          children: [
                            Expanded(
                              child: AuraCard(
                                variant: AuraCardVariant.mood,
                                child: Column(
                                  children: [
                                    ProgressRing(
                                      progress: moodProgress,
                                      size: 80,
                                      strokeWidth: 6,
                                      color: AppColors.secondary,
                                      showPercentage: false,
                                      glow: moodProgress > 0,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Mood',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      moodLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AuraCard(
                                variant: AuraCardVariant.nutrition,
                                child: Column(
                                  children: [
                                    ProgressRing(
                                      progress: waterProgress,
                                      size: 80,
                                      strokeWidth: 6,
                                      color: AppColors.nutritionColor,
                                      showPercentage: false,
                                      glow: waterProgress > 0,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Water',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${today.waterMl ~/ 250}/8 cups',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AuraCard(
                                child: Column(
                                  children: [
                                    ProgressRing(
                                      progress: workoutProgress,
                                      size: 80,
                                      strokeWidth: 6,
                                      color: AppColors.warning,
                                      showPercentage: false,
                                      glow: workoutProgress > 0,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Workouts',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${today.workouts.done}/${today.workouts.target}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Row(
                        children: [
                          Expanded(
                            child: AuraCard(
                              variant: AuraCardVariant.mood,
                              child: Column(
                                children: [
                                  const ProgressRing(
                                    progress: 0,
                                    size: 80,
                                    strokeWidth: 6,
                                    color: AppColors.secondary,
                                    showPercentage: false,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Mood',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuraCard(
                              variant: AuraCardVariant.nutrition,
                              child: Column(
                                children: [
                                  const ProgressRing(
                                    progress: 0,
                                    size: 80,
                                    strokeWidth: 6,
                                    color: AppColors.nutritionColor,
                                    showPercentage: false,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Water',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '0/8 cups',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuraCard(
                              child: Column(
                                children: [
                                  const ProgressRing(
                                    progress: 0,
                                    size: 80,
                                    strokeWidth: 6,
                                    color: AppColors.warning,
                                    showPercentage: false,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Workouts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '0/1',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      error: (_, __) => Row(
                        children: [
                          Expanded(
                            child: AuraCard(
                              variant: AuraCardVariant.mood,
                              child: Column(
                                children: [
                                  const ProgressRing(
                                    progress: 0,
                                    size: 80,
                                    strokeWidth: 6,
                                    color: AppColors.secondary,
                                    showPercentage: false,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Mood',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Not Set',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuraCard(
                              variant: AuraCardVariant.nutrition,
                              child: Column(
                                children: [
                                  const ProgressRing(
                                    progress: 0,
                                    size: 80,
                                    strokeWidth: 6,
                                    color: AppColors.nutritionColor,
                                    showPercentage: false,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Water',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '0/8 cups',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuraCard(
                              child: Column(
                                children: [
                                  const ProgressRing(
                                    progress: 0,
                                    size: 80,
                                    strokeWidth: 6,
                                    color: AppColors.warning,
                                    showPercentage: false,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Workouts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '0/1',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Glow Tracker
                    Consumer(
                      builder: (context, ref, child) {
                        return todayAsync.when(
                          data: (today) {
                            final waterCups = today.waterMl / 250;
                            final activityMinutes = activityAsync.valueOrNull?['activity_minutes'] as int? ?? 0;
                            // Sleep hours - placeholder (would come from sleep tracking service)
                            final sleepHours = 0.0; // TODO: Integrate sleep tracking
                            
                            return AuraCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Today's Glow Tracker",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Icon(
                                        LucideIcons.flame,
                                        color: AppColors.warning,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TrackerBar(
                                    value: waterCups,
                                    max: 8,
                                    label: 'Hydration',
                                    icon: LucideIcons.droplet,
                                    color: AppColors.nutritionColor,
                                    unit: ' cups',
                                  ),
                                  const SizedBox(height: 16),
                                  TrackerBar(
                                    value: activityMinutes.toDouble(),
                                    max: 450,
                                    label: 'Activity',
                                    icon: LucideIcons.zap,
                                    color: AppColors.warning,
                                    unit: ' min',
                                  ),
                                  const SizedBox(height: 16),
                                  TrackerBar(
                                    value: sleepHours,
                                    max: 8,
                                    label: 'Sleep',
                                    icon: LucideIcons.moon,
                                    color: AppColors.secondary,
                                    unit: ' hrs',
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => AuraCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Today's Glow Tracker",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      LucideIcons.flame,
                                      color: AppColors.warning,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TrackerBar(
                                  value: 0,
                                  max: 8,
                                  label: 'Hydration',
                                  icon: LucideIcons.droplet,
                                  color: AppColors.nutritionColor,
                                  unit: ' cups',
                                ),
                                const SizedBox(height: 16),
                                TrackerBar(
                                  value: 0,
                                  max: 450,
                                  label: 'Activity',
                                  icon: LucideIcons.zap,
                                  color: AppColors.warning,
                                  unit: ' min',
                                ),
                                const SizedBox(height: 16),
                                TrackerBar(
                                  value: 0,
                                  max: 8,
                                  label: 'Sleep',
                                  icon: LucideIcons.moon,
                                  color: AppColors.secondary,
                                  unit: ' hrs',
                                ),
                              ],
                            ),
                          ),
                          error: (_, __) => AuraCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Today's Glow Tracker",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      LucideIcons.flame,
                                      color: AppColors.warning,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TrackerBar(
                                  value: 0,
                                  max: 8,
                                  label: 'Hydration',
                                  icon: LucideIcons.droplet,
                                  color: AppColors.nutritionColor,
                                  unit: ' cups',
                                ),
                                const SizedBox(height: 16),
                                TrackerBar(
                                  value: 0,
                                  max: 450,
                                  label: 'Activity',
                                  icon: LucideIcons.zap,
                                  color: AppColors.warning,
                                  unit: ' min',
                                ),
                                const SizedBox(height: 16),
                                TrackerBar(
                                  value: 0,
                                  max: 8,
                                  label: 'Sleep',
                                  icon: LucideIcons.moon,
                                  color: AppColors.secondary,
                                  unit: ' hrs',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Wisdom of the Day Widget
                    Consumer(
                      builder: (context, ref, child) {
                        final dailyWisdomAsync = ref.watch(
                          dailyWisdomProvider({
                            'mood': null,
                            'spiritualPath': null,
                            'category': null,
                          }),
                        );

                        return dailyWisdomAsync.when(
                          data: (wisdom) => AuraCard(
                            variant: AuraCardVariant.spiritual,
                            glow: true,
                            child: InkWell(
                              onTap: () => context.push('/spirit/wisdom-daily'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.bookOpen,
                                        color: AppColors.spiritualColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Wisdom of the Day',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              wisdom.source ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        LucideIcons.arrowRight,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    wisdom.translation,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          loading: () => const AuraCard(
                            variant: AuraCardVariant.spiritual,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (err, stack) => const SizedBox.shrink(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Quick Actions
                    const QuickActions(),
                    const SizedBox(height: 16),
                    // Streaks & Achievements
                    Row(
                      children: [
                        Expanded(
                          child: AuraCard(
                            variant: AuraCardVariant.spiritual,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.spiritualColor
                                        .withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.flame,
                                    color: AppColors.spiritualColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Streak',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    Text(
                                      todayAsync.when(
                                        data: (today) => '${today.streak} Days',
                                        loading: () => '0 Days',
                                        error: (_, __) => '0 Days',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AuraCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.award,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Achievements',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    Text(
                                      '${appState.achievementCount}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Energy Graph
                    const AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Energy Analytics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                LucideIcons.trendingUp,
                                color: AppColors.success,
                                size: 24,
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            height: 120,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _EnergyBar(height: 45, day: 'M'),
                                _EnergyBar(height: 52, day: 'T'),
                                _EnergyBar(height: 48, day: 'W'),
                                _EnergyBar(height: 65, day: 'T'),
                                _EnergyBar(height: 58, day: 'F'),
                                _EnergyBar(height: 72, day: 'S'),
                                _EnergyBar(height: 82, day: 'S', isToday: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Space for nav bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1];
    return '$weekday, $month ${now.day}';
  }
}

class _EnergyBar extends StatelessWidget {
  final double height;
  final String day;
  final bool isToday;

  const _EnergyBar({
    required this.height,
    required this.day,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Expanded(
              child: Opacity(
                opacity: isToday ? 1.0 : 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  height: height,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
