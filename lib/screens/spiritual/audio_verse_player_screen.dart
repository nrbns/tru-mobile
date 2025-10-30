import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_provider.dart';

class AudioVersePlayerScreen extends ConsumerStatefulWidget {
  const AudioVersePlayerScreen({super.key});

  @override
  ConsumerState<AudioVersePlayerScreen> createState() =>
      _AudioVersePlayerScreenState();
}

class _AudioVersePlayerScreenState
    extends ConsumerState<AudioVersePlayerScreen> {
  String _selectedTradition = 'All';
  bool _isPlaying = false;
  String? _currentlyPlayingId;

  List<String> get _traditions => [
        'All',
        'Hinduism',
        'Buddhism',
        'Christianity',
        'Islam',
        'Judaism',
        'Sikhism',
      ];

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(sacredVersesProvider({
      'traditions': _selectedTradition == 'All' ? null : [_selectedTradition],
      'limit': 20,
    }));

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio Verse Player',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Listen to your scriptures',
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
            // Tradition Filter
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _traditions.length,
                itemBuilder: (context, index) {
                  final tradition = _traditions[index];
                  final isSelected = _selectedTradition == tradition;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTradition = tradition;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                                  .withAlpha((0.3 * 255).round())
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          tradition,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Verses List
            Expanded(
              child: versesAsync.when(
                data: (verses) {
                  if (verses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.headphones,
                              size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'No verses found',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add verses to Firestore collection',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verse = verses[index];
                      final isCurrentlyPlaying =
                          _currentlyPlayingId == verse['id'];

                      return _VerseCard(
                        verse: verse,
                        isPlaying: isCurrentlyPlaying && _isPlaying,
                        onPlay: () async {
                          final service =
                              ref.read(spiritualContentServiceProvider);

                          if (isCurrentlyPlaying && _isPlaying) {
                            await service.stopPlayback();
                            setState(() {
                              _isPlaying = false;
                            });
                          } else {
                            await service.playVerse(verse['verse'] as String);
                            setState(() {
                              _currentlyPlayingId = verse['id'] as String?;
                              _isPlaying = true;
                            });
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading verses',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(sacredVersesProvider({
                          'traditions': _selectedTradition == 'All'
                              ? null
                              : [_selectedTradition],
                          'limit': 20,
                        })),
                        child: const Text('Retry'),
                      ),
                    ],
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

class _VerseCard extends StatelessWidget {
  final Map<String, dynamic> verse;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _VerseCard({
    required this.verse,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        variant:
            isPlaying ? AuraCardVariant.spiritual : AuraCardVariant.default_,
        glow: isPlaying,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.spiritualColor,
                        AppColors.spiritualColor.withAlpha((0.7 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.headphones,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (verse['source'] != null)
                        Text(
                          verse['source'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      if (verse['chapter'] != null &&
                          verse['verse_number'] != null)
                        Text(
                          '${verse['chapter']} ${verse['verse_number']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? LucideIcons.pause : LucideIcons.play,
                    color: AppColors.spiritualColor,
                  ),
                  onPressed: onPlay,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              verse['verse'] as String? ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (verse['translation'] != null) ...[
              const SizedBox(height: 8),
              Text(
                verse['translation'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
