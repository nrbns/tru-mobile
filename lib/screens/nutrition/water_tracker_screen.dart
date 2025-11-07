import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/tracker_bar.dart';
import '../../core/providers/app_state_provider.dart';
// removed unused import
import '../../core/providers/today_provider.dart';

class WaterTrackerScreen extends ConsumerStatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  ConsumerState<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends ConsumerState<WaterTrackerScreen>
    with SingleTickerProviderStateMixin {
  static const int glassSize = 250; // ml
  static const int dailyGoal = 2000; // ml

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _addGlass() {
    final todayService = ref.read(todayServiceProvider);
    final currentIntake = ref.read(appStateProvider).waterIntake;
    final newIntake = (currentIntake + glassSize).clamp(0, dailyGoal + 500);
    ref.read(appStateProvider.notifier).updateWaterIntake(newIntake);
    todayService.updateWaterIntake(newIntake);
  }

  void _removeGlass() {
    final todayService = ref.read(todayServiceProvider);
    final currentIntake = ref.read(appStateProvider).waterIntake;
    final newIntake = (currentIntake - glassSize).clamp(0, dailyGoal + 500);
    ref.read(appStateProvider.notifier).updateWaterIntake(newIntake);
    todayService.updateWaterIntake(newIntake);
  }

  @override
  Widget build(BuildContext context) {
    final waterIntake = ref.watch(appStateProvider).waterIntake;
    final progress = (waterIntake / dailyGoal * 100).clamp(0.0, 100.0);
    final glasses = (waterIntake / glassSize).floor();
    final goalGlasses = (dailyGoal / glassSize).ceil();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background.withAlpha((0.9 * 255).round()),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Tracker',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Stay hydrated, stay healthy',
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      // Water Visualization
                      AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 192,
                            height: 256,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              border: Border.all(
                                color: AppColors.cyan,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan
                                      .withAlpha((0.4 * 255).round()),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(44),
                              child: Stack(
                                children: [
                                  // Water fill
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: (progress / 100) * 256,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.cyan,
                                            AppColors.primary,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.cyan
                                                .withAlpha((0.5 * 255).round()),
                                            blurRadius: 30,
                                            offset: const Offset(0, -10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Wave effect
                                  Positioned(
                                    top: (progress / 100) * 256 - 32,
                                    left: -100,
                                    right: -100,
                                    child: Transform.translate(
                                      offset: Offset(
                                        _waveAnimation.value * 200 - 100,
                                        0,
                                      ),
                                      child: Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withAlpha((0.1 * 255).round()),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Droplet icon
                                  Center(
                                    child: Icon(
                                      LucideIcons.droplet,
                                      size: 64,
                                      color: Colors.white
                                          .withAlpha((0.3 * 255).round()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Stats
                      Text(
                        '${waterIntake}ml',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'of $dailyGoal ml daily goal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$glasses / $goalGlasses glasses',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: TrackerBar(
                          value: progress,
                          max: 100,
                          label: 'Daily Progress',
                          icon: LucideIcons.droplet,
                          color: AppColors.cyan,
                          unit: '%',
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _removeGlass,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Icon(LucideIcons.minus, size: 24),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: _addGlass,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyan,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                                elevation: 8,
                              ),
                              child: const Icon(LucideIcons.plus, size: 28),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Icon(LucideIcons.moreHorizontal,
                                  size: 24),
                            ),
                          ],
                        ),
                      ),
                      if (progress >= 100) ...[
                        const SizedBox(height: 24),
                        const AuraCard(
                          variant: AuraCardVariant.nutrition,
                          glow: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.award,
                                color: AppColors.success,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Goal Achieved! 🎉',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
