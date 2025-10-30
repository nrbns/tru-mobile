import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_provider.dart';

class MantrasLibraryScreen extends ConsumerStatefulWidget {
  const MantrasLibraryScreen({super.key});

  @override
  ConsumerState<MantrasLibraryScreen> createState() =>
      _MantrasLibraryScreenState();
}

class _MantrasLibraryScreenState extends ConsumerState<MantrasLibraryScreen> {
  String _selectedCategory = 'All';
  String _selectedTradition = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories => [
        'All',
        'Prayer',
        'Meditation',
        'Gratitude',
        'Peace',
        'Healing',
        'Protection',
      ];

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
                          'Mantras Library',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Sacred verses and prayers',
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search mantras...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  prefixIcon:
                      const Icon(LucideIcons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            // Category & Tradition Filters
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
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
            // Mantras List
            Expanded(
              child: _buildMantrasList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMantrasList() {
    final searchQuery = _searchController.text.toLowerCase();
    final traditions =
        _selectedTradition == 'All' ? null : [_selectedTradition];
    final category = _selectedCategory == 'All' ? null : _selectedCategory;

    final mantrasAsync = ref.watch(mantrasStreamProvider({
      'traditions': traditions,
      'category': category,
    }));

    return mantrasAsync.when(
      data: (mantras) {
        // Filter by search query
        final filtered = searchQuery.isEmpty
            ? mantras
            : mantras.where((m) {
                final text = (m['text'] as String? ?? '').toLowerCase();
                final translation =
                    (m['translation'] as String? ?? '').toLowerCase();
                final meaning = (m['meaning'] as String? ?? '').toLowerCase();
                return text.contains(searchQuery) ||
                    translation.contains(searchQuery) ||
                    meaning.contains(searchQuery);
              }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.music, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty ? 'No mantras found' : 'No results',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add mantras to Firestore collection',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final mantra = filtered[index];
            return _MantraCard(
              mantra: mantra,
              onPlay: () async {
                final service = ref.read(spiritualContentServiceProvider);
                await service.playMantra(mantra['text'] as String);
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
              'Error loading mantras',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(mantrasStreamProvider({
                'traditions':
                    _selectedTradition == 'All' ? null : [_selectedTradition],
                'category':
                    _selectedCategory == 'All' ? null : _selectedCategory,
              })),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MantraCard extends StatelessWidget {
  final Map<String, dynamic> mantra;
  final VoidCallback? onPlay;

  const _MantraCard({required this.mantra, this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuraCard(
        variant: AuraCardVariant.spiritual,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.quote,
                  color: AppColors.spiritualColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mantra['title'] as String? ??
                        '${mantra['tradition'] as String? ?? ''} Mantra',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mantra['text'] as String? ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (mantra['translation'] != null) ...[
              const SizedBox(height: 8),
              Text(
                mantra['translation'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
            if (mantra['meaning'] != null) ...[
              const SizedBox(height: 8),
              Text(
                mantra['meaning'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (mantra['repetitions'] != null)
                  Text(
                    'Repetitions: ${mantra['repetitions']}x',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  )
                else
                  const Spacer(),
                Row(
                  children: [
                    if (onPlay != null)
                      IconButton(
                        icon: const Icon(LucideIcons.play, size: 20),
                        color: AppColors.spiritualColor,
                        onPressed: onPlay,
                      ),
                    IconButton(
                      icon: const Icon(LucideIcons.heart, size: 20),
                      color: AppColors.spiritualColor,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.share2, size: 20),
                      color: AppColors.spiritualColor,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
