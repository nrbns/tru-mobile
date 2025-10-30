import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/wisdom_provider.dart';

class WisdomLegendsScreen extends ConsumerStatefulWidget {
  const WisdomLegendsScreen({super.key});

  @override
  ConsumerState<WisdomLegendsScreen> createState() =>
      _WisdomLegendsScreenState();
}

class _WisdomLegendsScreenState extends ConsumerState<WisdomLegendsScreen> {
  String? _selectedAuthor;

  final List<String> _legendAuthors = [
    'APJ Abdul Kalam',
    'Swami Vivekananda',
    'Socrates',
    'Lao Tzu',
    'Buddha',
    'Rumi',
    'Confucius',
    'Marcus Aurelius',
    'Steve Jobs',
    'Gandhi',
    'Nelson Mandela',
    'Osho',
  ];

  @override
  Widget build(BuildContext context) {
    final legendsAsync = ref.watch(
      legendsWisdomProvider({
        'author': _selectedAuthor,
        'limit': 50,
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                          'Legends & Masters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Wisdom from legendary minds',
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
            // Author Filter
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _legendAuthors.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _selectedAuthor == null,
                        label: const Text('All'),
                        onSelected: (selected) {
                          setState(() => _selectedAuthor = null);
                        },
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }

                  final author = _legendAuthors[index - 1];
                  final isSelected = _selectedAuthor == author;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(author),
                      onSelected: (selected) {
                        setState(
                            () => _selectedAuthor = selected ? author : null);
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Content
            Expanded(
              child: legendsAsync.when(
                data: (legends) {
                  if (legends.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.users,
                              color: Colors.grey[600], size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No legends wisdom found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: legends.length,
                    itemBuilder: (context, index) {
                      final wisdom = legends[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildLegendCard(context, ref, wisdom),
                      );
                    },
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
                      Text('Error: $err',
                          style: const TextStyle(color: Colors.grey)),
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

  Widget _buildLegendCard(BuildContext context, WidgetRef ref, wisdom) {
    return AuraCard(
      variant: AuraCardVariant.ai,
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    wisdom.author?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wisdom.author ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (wisdom.era != null)
                      Text(
                        wisdom.era!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quote
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              wisdom.translation,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (wisdom.meaning != null && wisdom.meaning!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              wisdom.meaning!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/spirit/wisdom/${wisdom.id}');
                  },
                  icon: const Icon(LucideIcons.bookOpen, size: 16),
                  label: const Text('Read More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final service = ref.read(wisdomServiceProvider);
                      await service.markWisdomApplied(wisdom.id);
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content:
                              Text('Challenge applied! Check your tracker'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(LucideIcons.checkCircle, size: 16),
                  label: const Text('Apply Today'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
