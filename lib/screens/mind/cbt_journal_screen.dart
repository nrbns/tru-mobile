import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../widgets/voice_recorder_widget.dart';
import '../../core/providers/cbt_provider.dart';

class CBTJournalScreen extends ConsumerStatefulWidget {
  const CBTJournalScreen({super.key});

  @override
  ConsumerState<CBTJournalScreen> createState() => _CBTJournalScreenState();
}

class _CBTJournalScreenState extends ConsumerState<CBTJournalScreen> {
  final _situationController = TextEditingController();
  final _thoughtsController = TextEditingController();
  final _feelingsController = TextEditingController();
  final _evidenceController = TextEditingController();
  final _alternativeController = TextEditingController();

  void _showAnalysisSummary(
      BuildContext context, Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.aiGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.brain,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Analysis Complete',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (analysis['mood_score'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Text(
                        'Detected Mood: ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${analysis['mood_score']}/10',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (analysis['emotions'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emotions Detected:',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: (analysis['emotions'] as List)
                            .map((e) => Chip(
                                  label: Text(
                                    e.toString(),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: AppColors.primary
                                      .withAlpha((0.2 * 255).round()),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              if (analysis['cbt_insights'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CBT Insights:',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      ...(analysis['cbt_insights'] as List)
                          .map((insight) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $insight',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )),
                    ],
                  ),
                ),
              const Text(
                'Fields have been auto-filled based on the analysis. You can edit them as needed.',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _situationController.dispose();
    _thoughtsController.dispose();
    _feelingsController.dispose();
    _evidenceController.dispose();
    _alternativeController.dispose();
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CBT Thought Journal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Challenge your thoughts',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.helpCircle,
                        color: AppColors.primary),
                    onPressed: () {},
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
                    // Info Card
                    AuraCard(
                      variant: AuraCardVariant.ai,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use this journal to identify and challenge negative thought patterns using Cognitive Behavioral Therapy techniques.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(
                                LucideIcons.mic,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Can\'t write? Record your voice instead!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Voice Recording Option
                    AuraCard(
                      variant: AuraCardVariant.default_,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.aiGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  LucideIcons.mic,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Voice Recording',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Record your thoughts and we\'ll analyze them for you',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          VoiceRecorderWidget(
                            onTranscriptReceived: (transcript) {
                              // Auto-fill the appropriate field
                              if (_situationController.text.isEmpty) {
                                setState(() {
                                  _situationController.text = transcript;
                                });
                              }
                            },
                            onAnalysisComplete: (analysis) async {
                              // Populate CBT fields from AI analysis
                              setState(() {
                                if (_thoughtsController.text.isEmpty &&
                                    analysis['thoughts'] != null) {
                                  _thoughtsController.text =
                                      (analysis['thoughts'] as List).join(', ');
                                }
                                if (_feelingsController.text.isEmpty &&
                                    analysis['emotions'] != null) {
                                  _feelingsController.text =
                                      (analysis['emotions'] as List).join(', ');
                                }
                                if (analysis['situation'] != null &&
                                    _situationController.text.isEmpty) {
                                  _situationController.text =
                                      analysis['situation'] as String;
                                }
                                if (analysis['alternative_perspective'] !=
                                        null &&
                                    _alternativeController.text.isEmpty) {
                                  _alternativeController.text =
                                      analysis['alternative_perspective']
                                          as String;
                                }
                              });

                              // Show analysis summary
                              if (!mounted) return;
                              _showAnalysisSummary(this.context, analysis);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[700]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR WRITE MANUALLY',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Step 1: Situation
                    _CBTStep(
                      stepNumber: 1,
                      title: 'What happened?',
                      hint: 'Describe the situation briefly...',
                      controller: _situationController,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    // Step 2: Thoughts
                    _CBTStep(
                      stepNumber: 2,
                      title: 'What thoughts came to mind?',
                      hint: 'What were your automatic thoughts?',
                      controller: _thoughtsController,
                      color: AppColors.primary,
                      multiline: true,
                    ),
                    const SizedBox(height: 24),
                    // Step 3: Feelings
                    _CBTStep(
                      stepNumber: 3,
                      title: 'How did you feel?',
                      hint:
                          'What emotions did you experience? (anxious, sad, angry, etc.)',
                      controller: _feelingsController,
                      color: AppColors.primary,
                      multiline: true,
                    ),
                    const SizedBox(height: 24),
                    // Step 4: Evidence
                    _CBTStep(
                      stepNumber: 4,
                      title: 'What\'s the evidence?',
                      hint: 'What facts support or contradict your thoughts?',
                      controller: _evidenceController,
                      color: AppColors.secondary,
                      multiline: true,
                    ),
                    const SizedBox(height: 24),
                    // Step 5: Alternative
                    _CBTStep(
                      stepNumber: 5,
                      title: 'Alternative perspective',
                      hint: 'How else could you view this situation?',
                      controller: _alternativeController,
                      color: AppColors.secondary,
                      multiline: true,
                    ),
                    const SizedBox(height: 32),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Save journal entry to Firestore
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          try {
                            final cbtService = ref.read(cbtServiceProvider);
                            await cbtService.saveCBTJournal(
                              situation: _situationController.text,
                              thoughts: _thoughtsController.text,
                              feelings: _feelingsController.text,
                              evidence: _evidenceController.text.isEmpty
                                  ? null
                                  : _evidenceController.text,
                              alternativePerspective:
                                  _alternativeController.text.isEmpty
                                      ? null
                                      : _alternativeController.text,
                            );

                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Journal entry saved successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            navigator.pop();
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Error saving journal: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
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
                              'Save Journal Entry',
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

class _CBTStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String hint;
  final TextEditingController controller;
  final Color color;
  final bool multiline;

  const _CBTStep({
    required this.stepNumber,
    required this.title,
    required this.hint,
    required this.controller,
    required this.color,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: multiline ? 4 : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            hintStyle: const TextStyle(color: AppColors.textMuted),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
