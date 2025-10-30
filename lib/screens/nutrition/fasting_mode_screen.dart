import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/progress_ring.dart';

class FastingModeScreen extends StatefulWidget {
  const FastingModeScreen({super.key});

  @override
  State<FastingModeScreen> createState() => _FastingModeScreenState();
}

class _FastingModeScreenState extends State<FastingModeScreen> {
  bool _isFasting = false;
  DateTime? _fastStartTime;
  final Duration _fastDuration = const Duration(hours: 8, minutes: 30);

  Duration get _elapsedTime {
    if (_fastStartTime == null) return Duration.zero;
    return DateTime.now().difference(_fastStartTime!);
  }

  void _toggleFasting() {
    setState(() {
      _isFasting = !_isFasting;
      if (_isFasting) {
        _fastStartTime = DateTime.now();
      } else {
        _fastStartTime = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    AuraCard(
                      variant: AuraCardVariant.nutrition,
                      glow: _isFasting,
                      child: Column(
                        children: [
                          const ProgressRing(
                            progress: 45,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _formatDuration(
                                _isFasting ? _elapsedTime : _fastDuration),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isFasting
                                ? 'Fasting in progress'
                                : 'Ready to start',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _toggleFasting,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFasting
                                    ? AppColors.error
                                    : AppColors.nutritionColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isFasting
                                        ? LucideIcons.square
                                        : LucideIcons.play,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isFasting
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
                    ),
                    const SizedBox(height: 24),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          _FastingPlan(
                            name: '16:8 Intermittent',
                            description:
                                'Fast for 16 hours, eat in 8-hour window',
                            onTap: () {},
                          ),
                          _FastingPlan(
                            name: '18:6 Intermittent',
                            description:
                                'Fast for 18 hours, eat in 6-hour window',
                            onTap: () {},
                          ),
                          _FastingPlan(
                            name: 'One Meal a Day',
                            description: 'Eat one large meal per day',
                            onTap: () {},
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}

class _FastingPlan extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onTap;

  const _FastingPlan({
    required this.name,
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.nutritionColor.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.clock,
              color: AppColors.nutritionColor,
              size: 20,
            ),
          ),
          title: Text(
            name,
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
