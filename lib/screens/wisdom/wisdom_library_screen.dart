import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/wisdom_provider.dart';

class WisdomLibraryScreen extends ConsumerStatefulWidget {
  const WisdomLibraryScreen({super.key});

  @override
  ConsumerState<WisdomLibraryScreen> createState() =>
      _WisdomLibraryScreenState();
}

class _WisdomLibraryScreenState extends ConsumerState<WisdomLibraryScreen> {
  String? _selectedSource;
  String? _selectedCategory;
  String? _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sourcesAsync = ref.watch(wisdomSourcesProvider);
    final categoriesAsync = ref.watch(wisdomCategoriesProvider);
    final wisdomAsync = ref.watch(
      wisdomLibraryProvider({
        'source': _selectedSource,
        'category': _selectedCategory,
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
                          'Wisdom Library',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Explore timeless wisdom',
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
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search wisdom...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(LucideIcons.search,
                      color: AppColors.textSecondary),
                  suffixIcon: _searchQuery!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x,
                              color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            // Filters
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: sourcesAsync.when(
                      data: (sources) => DropdownButton<String>(
                        value: _selectedSource,
                        hint: const Text('All Sources',
                            style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Sources')),
                          ...sources.map((s) =>
                              DropdownMenuItem(value: s, child: Text(s))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSource = value);
                        },
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: categoriesAsync.when(
                      data: (categories) => DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text('All Categories',
                            style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Categories')),
                          ...categories.map((c) =>
                              DropdownMenuItem(value: c, child: Text(c))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw,
                        color: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        _selectedSource = null;
                        _selectedCategory = null;
                      });
                    },
                    tooltip: 'Clear Filters',
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: wisdomAsync.when(
                data: (wisdomList) {
                  final filtered = _searchQuery!.isEmpty
                      ? wisdomList
                      : wisdomList.where((w) {
                          return w.translation
                                  .toLowerCase()
                                  .contains(_searchQuery!.toLowerCase()) ||
                              (w.meaning
                                      ?.toLowerCase()
                                      .contains(_searchQuery!.toLowerCase()) ??
                                  false) ||
                              (w.source
                                  .toLowerCase()
                                  .contains(_searchQuery!.toLowerCase()));
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.bookOpen,
                              color: Colors.grey[600], size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No wisdom found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final wisdom = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWisdomCard(context, wisdom),
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

  Widget _buildWisdomCard(BuildContext context, wisdom) {
    return AuraCard(
      variant: AuraCardVariant.spiritual,
      child: InkWell(
        onTap: () {
          context.push('/spirit/wisdom/${wisdom.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wisdom.source,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wisdom.translation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.arrowRight,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
            if (wisdom.tags != null && wisdom.tags!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: wisdom.tags!.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
