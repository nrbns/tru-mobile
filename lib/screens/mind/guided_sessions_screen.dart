import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/meditation_provider.dart';
import 'package:just_audio/just_audio.dart';

class GuidedSessionsScreen extends ConsumerStatefulWidget {
  const GuidedSessionsScreen({super.key});

  @override
  ConsumerState<GuidedSessionsScreen> createState() =>
      _GuidedSessionsScreenState();
}

class _GuidedSessionsScreenState extends ConsumerState<GuidedSessionsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
                          'Guided Sessions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Audio-guided meditations',
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
              child: ref.watch(meditationsStreamProvider({'limit': 20})).when(
                    data: (meditations) {
                      if (meditations.isEmpty) {
                        return const Center(
                          child: Text(
                            'No meditations available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: meditations.length,
                        itemBuilder: (context, index) {
                          final meditation = meditations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AuraCard(
                              variant: AuraCardVariant.mood,
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      LucideIcons.headphones,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meditation['title'] ?? 'Meditation',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.clock,
                                              size: 14,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${meditation['duration'] ?? 10} min',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withAlpha(
                                                        (0.2 * 255).round()),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                meditation['category'] ??
                                                    'Meditation',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _currentlyPlaying == meditation['id']
                                          ? LucideIcons.pauseCircle
                                          : LucideIcons.playCircle,
                                      size: 40,
                                    ),
                                    color: AppColors.primary,
                                    onPressed: () async {
                                      if (_currentlyPlaying ==
                                          meditation['id']) {
                                        await _audioPlayer.pause();
                                        setState(
                                            () => _currentlyPlaying = null);
                                      } else {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        try {
                                          final audioUrl =
                                              meditation['audioUrl'] as String?;
                                          if (audioUrl != null &&
                                              audioUrl.isNotEmpty) {
                                            await _audioPlayer.setUrl(audioUrl);
                                            await _audioPlayer.play();
                                            setState(() => _currentlyPlaying =
                                                meditation['id'] as String);

                                            // Start meditation session tracking
                                            final meditationService = ref.read(
                                                meditationServiceProvider);
                                            try {
                                              await meditationService
                                                  .startMeditationSession(
                                                meditationId:
                                                    meditation['id'] as String,
                                              );
                                            } catch (e) {
                                              print(
                                                  'Error starting meditation session: $e');
                                            }
                                          }
                                        } catch (e) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error playing meditation: $e'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading meditations: $error',
                        style: const TextStyle(color: Colors.red),
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
