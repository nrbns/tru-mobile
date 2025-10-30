import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/emotion_chip.dart';

class QuickLogScreen extends StatefulWidget {
  const QuickLogScreen({super.key});

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  String? _selectedMood;
  final Set<String> _selectedEmotions = {};
  final TextEditingController _noteController = TextEditingController();

  final List<_MoodLevel> _moodLevels = const [
    _MoodLevel(
      id: 'amazing',
      label: 'Amazing',
      icon: LucideIcons.smile,
      color: AppColors.success,
    ),
    _MoodLevel(
      id: 'good',
      label: 'Good',
      icon: LucideIcons.smile,
      color: AppColors.primary,
    ),
    _MoodLevel(
      id: 'okay',
      label: 'Okay',
      icon: LucideIcons.meh,
      color: AppColors.warning,
    ),
    _MoodLevel(
      id: 'bad',
      label: 'Bad',
      icon: LucideIcons.frown,
      color: AppColors.error,
    ),
    _MoodLevel(
      id: 'terrible',
      label: 'Terrible',
      icon: LucideIcons.angry,
      color: Color(0xFF991B1B),
    ),
  ];

  final List<String> _emotions = const [
    'Happy',
    'Grateful',
    'Peaceful',
    'Anxious',
    'Stressed',
    'Sad',
    'Angry',
    'Excited',
    'Tired',
    'Energized',
    'Focused',
    'Distracted',
    'Calm',
    'Overwhelmed',
    'Hopeful',
  ];

  void _toggleEmotion(String emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else {
        _selectedEmotions.add(emotion);
      }
    });
  }

  void _handleSave() {
    if (_selectedMood != null) {
      // Save mood log
      context.pop();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Mood Log',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'How are you feeling right now?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood Selection
                    const Text(
                      'Your Mood',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moodLevels.length,
                        itemBuilder: (context, index) {
                          final mood = _moodLevels[index];
                          final isSelected = _selectedMood == mood.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMood = mood.id;
                                });
                              },
                              child: AuraCard(
                                variant: isSelected
                                    ? AuraCardVariant.default_
                                    : AuraCardVariant.default_,
                                glow: isSelected,
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  width: 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: mood.color
                                              .withAlpha((0.2 * 255).round()),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          mood.icon,
                                          color: mood.color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        mood.label,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Emotion Tags
                    const Text(
                      'What emotions are you experiencing?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _emotions.map((emotion) {
                        return EmotionChip(
                          label: emotion,
                          selected: _selectedEmotions.contains(emotion),
                          onTap: () => _toggleEmotion(emotion),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Mood Correlation Link
                    GestureDetector(
                      onTap: () => context.push('/mind/mood-correlation'),
                      child: const AuraCard(
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.trendingUp,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'View mood correlations',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Note
                    const Text(
                      'Add a note (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedMood != null ? _handleSave : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.save, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Save Mood Log',
                              style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodLevel {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const _MoodLevel({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}
