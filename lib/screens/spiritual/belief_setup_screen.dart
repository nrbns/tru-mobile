import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class BeliefSetupScreen extends StatefulWidget {
  const BeliefSetupScreen({super.key});

  @override
  State<BeliefSetupScreen> createState() => _BeliefSetupScreenState();
}

class _BeliefSetupScreenState extends State<BeliefSetupScreen> {
  String? _selectedTradition;
  final Set<String> _selectedPractices = {};

  final List<_Tradition> _traditions = const [
    _Tradition(
        id: 'christianity', title: 'Christianity', icon: LucideIcons.cross),
    _Tradition(id: 'islam', title: 'Islam', icon: LucideIcons.crescent),
    _Tradition(id: 'judaism', title: 'Judaism', icon: LucideIcons.star),
    _Tradition(id: 'hinduism', title: 'Hinduism', icon: LucideIcons.om),
    _Tradition(id: 'buddhism', title: 'Buddhism', icon: LucideIcons.lotus),
    _Tradition(id: 'spiritual', title: 'Spiritual', icon: LucideIcons.sparkles),
    _Tradition(id: 'agnostic', title: 'Agnostic', icon: LucideIcons.helpCircle),
    _Tradition(id: 'other', title: 'Other', icon: LucideIcons.heart),
  ];

  final List<_Practice> _practices = const [
    _Practice(
        id: 'prayer',
        title: 'Prayer/Meditation',
        icon: LucideIcons.heartHandshake),
    _Practice(
        id: 'scripture',
        title: 'Scripture Reading',
        icon: LucideIcons.bookOpen),
    _Practice(id: 'reflection', title: 'Reflection', icon: LucideIcons.brain),
    _Practice(id: 'gratitude', title: 'Gratitude', icon: LucideIcons.sparkles),
    _Practice(id: 'mantras', title: 'Mantras', icon: LucideIcons.music),
  ];

  void _handleContinue() {
    if (_selectedTradition == null) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        context.go('/home');
        return;
      }

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // Fire-and-forget save; navigate immediately and let backend retry/save asynchronously.
      // Wrap in try/catch to avoid unhandled JS interop errors on web when
      // Firebase hasn't initialized correctly.
      try {
        userRef.set({
          'traditions': [_selectedTradition],
          'preferred_practices': _selectedPractices.toList(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: ${e.toString()}')),
          );
        }
      }

      context.go('/home');
    } catch (e) {
      // Likely Firebase isn't initialized on web — fail gracefully.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase not available: ${e.toString()}')),
        );
      }
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tell us about your beliefs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This helps us personalize your spiritual journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Faith Tradition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _traditions.map((tradition) {
                        final isSelected = _selectedTradition == tradition.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTradition = tradition.id;
                            });
                          },
                          child: AuraCard(
                            variant: isSelected
                                ? AuraCardVariant.spiritual
                                : AuraCardVariant.default_,
                            glow: isSelected,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tradition.icon,
                                  color: isSelected
                                      ? AppColors.spiritualColor
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tradition.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Spiritual Practices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._practices.map((practice) {
                      final isSelected =
                          _selectedPractices.contains(practice.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedPractices.remove(practice.id);
                              } else {
                                _selectedPractices.add(practice.id);
                              }
                            });
                          },
                          child: AuraCard(
                            variant: isSelected
                                ? AuraCardVariant.spiritual
                                : AuraCardVariant.default_,
                            glow: isSelected,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.spiritualColor
                                            .withAlpha((0.2 * 255).round())
                                        : AppColors.textMuted
                                            .withAlpha((0.1 * 255).round()),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    practice.icon,
                                    color: isSelected
                                        ? AppColors.spiritualColor
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  practice.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  isSelected
                                      ? LucideIcons.checkCircle
                                      : LucideIcons.circle,
                                  color: isSelected
                                      ? AppColors.spiritualColor
                                      : AppColors.textMuted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedTradition != null ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

class _Tradition {
  final String id;
  final String title;
  final IconData icon;

  const _Tradition({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class _Practice {
  final String id;
  final String title;
  final IconData icon;

  const _Practice({
    required this.id,
    required this.title,
    required this.icon,
  });
}
