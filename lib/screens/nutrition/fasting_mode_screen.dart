import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/progress_ring.dart';
import '../../core/providers/fasting_provider.dart';

class FastingModeScreen extends ConsumerStatefulWidget {
  const FastingModeScreen({super.key});

  @override
  ConsumerState<FastingModeScreen> createState() => _FastingModeScreenState();
}

class _FastingModeScreenState extends ConsumerState<FastingModeScreen> {
  Timer? _timer;
  String? _selectedPlanType;
  int? _selectedFastingHours;

  final Map<String, int> _fastingPlans = {
    '16:8 Intermittent': 16,
    '18:6 Intermittent': 18,
    'One Meal a Day': 20,
    '24 Hour Fast': 24,
  };

  @override
  void initState() {
    super.initState();
    // Check for active session on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveSession();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkActiveSession() {
    final sessionAsync = ref.read(activeFastingSessionProvider);
    sessionAsync.whenData((session) {
      if (session != null) {
        final planType = session['plan_type'] as String?;
        if (planType != null && _fastingPlans.containsKey(planType)) {
          setState(() {
            _selectedPlanType = planType;
            _selectedFastingHours = _fastingPlans[planType];
          });
          _startTimer();
        }
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _startFasting(String planType, int hours) async {
    try {
      final service = ref.read(fastingServiceProvider);
      await service.startFasting(
        planType: planType,
        fastingHours: hours,
      );
      setState(() {
        _selectedPlanType = planType;
        _selectedFastingHours = hours;
      });
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fasting started: $planType')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start fasting: $e')),
        );
      }
    }
  }

  Future<void> _stopFasting(String? sessionId) async {
    if (sessionId == null) return;
    try {
      final service = ref.read(fastingServiceProvider);
      await service.stopFasting(sessionId);
      _timer?.cancel();
      setState(() {
        _selectedPlanType = null;
        _selectedFastingHours = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fasting stopped')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop fasting: $e')),
        );
      }
    }
  }

  Duration _getElapsedTime(Map<String, dynamic>? session) {
    if (session == null || _selectedPlanType == null) return Duration.zero;
    final startTime = (session['start_time'] as Timestamp?)?.toDate();
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime);
  }

  double _getProgress(Map<String, dynamic>? session) {
    if (session == null || _selectedFastingHours == null) return 0.0;
    final elapsed = _getElapsedTime(session);
    final totalSeconds = _selectedFastingHours! * 3600;
    final progress = (elapsed.inSeconds / totalSeconds * 100).clamp(0.0, 100.0);
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeFastingSessionProvider);

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
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fasting Mode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Track your intermittent fasting',
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    sessionAsync.when(
                      data: (session) {
                        final isActive = session != null;
                        final elapsed = _getElapsedTime(session);
                        final progress = _getProgress(session);
                        final remaining = _selectedFastingHours != null && elapsed.inSeconds < (_selectedFastingHours! * 3600)
                            ? Duration(seconds: (_selectedFastingHours! * 3600) - elapsed.inSeconds)
                            : Duration.zero;

                        return AuraCard(
                          variant: AuraCardVariant.nutrition,
                          glow: isActive,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ProgressRing(
                                progress: progress,
                                size: 150,
                                strokeWidth: 10,
                                color: AppColors.nutritionColor,
                                showPercentage: true,
                                glow: isActive,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                isActive
                                    ? _formatDuration(elapsed)
                                    : _selectedPlanType != null
                                        ? _formatDuration(Duration(
                                            hours: _selectedFastingHours ?? 0))
                                        : '00:00',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isActive
                                    ? 'Fasting in progress'
                                    : _selectedPlanType != null
                                        ? 'Selected: $_selectedPlanType'
                                        : 'Select a plan to start',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                              if (isActive && remaining.inHours >= 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.nutritionColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isActive
                                      ? () => _stopFasting(session['id'] as String?)
                                      : _selectedPlanType != null
                                          ? () => _startFasting(
                                              _selectedPlanType!,
                                              _selectedFastingHours!)
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isActive
                                        ? AppColors.error
                                        : AppColors.nutritionColor,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    disabledBackgroundColor:
                                        Colors.grey[700],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isActive
                                            ? LucideIcons.square
                                            : LucideIcons.play,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isActive
                                            ? 'Stop Fasting'
                                            : 'Start Fasting',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const AuraCard(
                        variant: AuraCardVariant.nutrition,
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              color: AppColors.error,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error loading fasting session',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Fasting Plans',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._fastingPlans.entries.map((entry) {
                            final isSelected = _selectedPlanType == entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _FastingPlan(
                                name: entry.key,
                                description: _getPlanDescription(entry.key),
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedPlanType = entry.key;
                                    _selectedFastingHours = entry.value;
                                  });
                                },
                              ),
                            );
                          }),
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

  String _getPlanDescription(String plan) {
    switch (plan) {
      case '16:8 Intermittent':
        return 'Fast for 16 hours, eat in 8-hour window';
      case '18:6 Intermittent':
        return 'Fast for 18 hours, eat in 6-hour window';
      case 'One Meal a Day':
        return 'Eat one large meal per day (20-hour fast)';
      case '24 Hour Fast':
        return 'Complete 24-hour fasting period';
      default:
        return 'Select this plan';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

class _FastingPlan extends StatelessWidget {
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _FastingPlan({
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.nutritionColor.withAlpha((0.2 * 255).round())
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.nutritionColor
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.nutritionColor
                    : AppColors.nutritionColor.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? LucideIcons.check : LucideIcons.clock,
                color: isSelected ? Colors.white : AppColors.nutritionColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? LucideIcons.checkCircle
                  : LucideIcons.chevronRight,
              color: isSelected
                  ? AppColors.nutritionColor
                  : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
