import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/affirmations_provider.dart';

class AffirmationsScreen extends ConsumerStatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  ConsumerState<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends ConsumerState<AffirmationsScreen> {
  String? _category;
  String? _type;

  @override
  Widget build(BuildContext context) {
    final affirmationsAsync = ref.watch(affirmationsStreamProvider({
      'category': _category,
      'type': _type,
    }));

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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Affirmations & Healing',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Guided words for healing and growth',
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
            // Filters (simple placeholders)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  DropdownButton<String?>(
                    value: _category,
                    hint: const Text('Category',
                        style: TextStyle(color: Colors.white70)),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                          value: 'healing', child: Text('Healing')),
                      DropdownMenuItem(
                          value: 'confidence', child: Text('Confidence')),
                      DropdownMenuItem(
                          value: 'abundance', child: Text('Abundance')),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: _type,
                    hint: const Text('Type',
                        style: TextStyle(color: Colors.white70)),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(
                          value: 'healing', child: Text('Healing')),
                      DropdownMenuItem(
                          value: 'confidence', child: Text('Confidence')),
                    ],
                    onChanged: (v) => setState(() => _type = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: affirmationsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text('No affirmations found',
                          style: TextStyle(color: Colors.grey[400])),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final a = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AuraCard(
                          variant: AuraCardVariant.spiritual,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.text,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.6)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (a.category.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withAlpha((0.2 * 255).round()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(a.category,
                                          style: const TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 12)),
                                    ),
                                  const Spacer(),
                                  Text('x${a.repeatCount}',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
