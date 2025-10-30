import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/wisdom_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WisdomDetailScreen extends ConsumerStatefulWidget {
  final String wisdomId;

  const WisdomDetailScreen({
    super.key,
    required this.wisdomId,
  });

  @override
  ConsumerState<WisdomDetailScreen> createState() => _WisdomDetailScreenState();
}

class _WisdomDetailScreenState extends ConsumerState<WisdomDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  void _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _playWisdom(String text) async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _tts.speak(text);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wisdomAsync = ref.watch(
      FutureProvider((ref) async {
        final service = ref.read(wisdomServiceProvider);
        return service.getWisdomById(widget.wisdomId);
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: wisdomAsync.when(
          data: (wisdom) {
            if (wisdom == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Wisdom not found',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return Column(
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
                        icon: const Icon(LucideIcons.arrowLeft,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wisdom.source,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              wisdom.category,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? LucideIcons.pause : LucideIcons.play,
                          color: AppColors.primary,
                        ),
                        onPressed: () => _playWisdom(wisdom.translation),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Verse (if available)
                        if (wisdom.verse != null &&
                            wisdom.verse!.isNotEmpty) ...[
                          AuraCard(
                            variant: AuraCardVariant.spiritual,
                            child: Column(
                              children: [
                                Text(
                                  wisdom.verse!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    height: 1.6,
                                    fontFamily: 'serif',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (wisdom.language != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '(${wisdom.language})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Translation
                        AuraCard(
                          glow: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.translate,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Translation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                wisdom.translation,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Meaning
                        if (wisdom.meaning != null &&
                            wisdom.meaning!.isNotEmpty) ...[
                          AuraCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.lightbulb,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Meaning & Context',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  wisdom.meaning!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[300],
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Metadata
                        AuraCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.info,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'About',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (wisdom.author != null) ...[
                                _buildMetadataRow('Author', wisdom.author!),
                                const SizedBox(height: 8),
                              ],
                              if (wisdom.era != null) ...[
                                _buildMetadataRow('Era', wisdom.era!),
                                const SizedBox(height: 8),
                              ],
                              if (wisdom.tradition != null) ...[
                                _buildMetadataRow(
                                    'Tradition', wisdom.tradition!),
                                const SizedBox(height: 8),
                              ],
                              _buildMetadataRow('Level', wisdom.level),
                              if (wisdom.moodFit != null &&
                                  wisdom.moodFit!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Text(
                                      'Fits Mood:',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                    ...wisdom.moodFit!.map((mood) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary
                                              .withAlpha((0.2 * 255).round()),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          mood,
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push(
                                '/spirit/wisdom/${wisdom.id}/reflect',
                              );
                            },
                            icon: const Icon(LucideIcons.bookOpen, size: 20),
                            label: const Text(
                              'Reflect on This Wisdom',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  try {
                                    final service =
                                        ref.read(wisdomServiceProvider);
                                    await service.saveToMyWisdom(wisdom.id);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Saved to library'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Failed: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(LucideIcons.bookmark),
                                label: const Text('Save'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.push(
                                    '/spirit/wisdom/${wisdom.id}/ai-discuss',
                                  );
                                },
                                icon: const Icon(LucideIcons.messageCircle),
                                label: const Text('AI Discuss'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.secondary,
                                  side: const BorderSide(
                                      color: AppColors.secondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertCircle,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Error: $err', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
