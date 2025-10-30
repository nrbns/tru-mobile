import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/providers/nutrition_provider.dart';
// Removed unused import: nutrition_service is not used directly in this widget.

class NutritionLogScreen extends ConsumerWidget {
  const NutritionLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(mealLogsStreamProvider);
    final todayCaloriesAsync = ref.watch(todayCaloriesProvider);

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
                    child: Text(
                      'Nutrition Log',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Summary
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
                  const Icon(LucideIcons.flame,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: todayCaloriesAsync.when(
                      data: (kcal) => Text(
                        'Today: $kcal kcal',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      loading: () => const Text('Calculating...',
                          style: TextStyle(color: Colors.white)),
                      error: (_, __) => const Text('—',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            // Meal logs
            Expanded(
              child: logsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return Center(
                      child: Text('No meals logged yet',
                          style: TextStyle(color: Colors.grey[400])),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final total =
                          (log['total'] as Map<String, dynamic>?) ?? {};
                      final ts = log['at'];
                      final time = ts is Timestamp ? ts.toDate() : null;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.utensils,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  time != null ? _fmtTime(time) : 'Meal',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text('${total['kcal'] ?? 0} kcal',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              children: [
                                _macroChip('P', total['protein'] ?? 0,
                                    AppColors.primary),
                                _macroChip(
                                    'C', total['carbs'] ?? 0, Colors.orange),
                                _macroChip(
                                    'F', total['fat'] ?? 0, Colors.pinkAccent),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQuickAdd(context, ref),
        backgroundColor: AppColors.primary,
        label: const Text('Add Meal'),
        icon: const Icon(LucideIcons.plus),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _macroChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.15 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value g',
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _openQuickAdd(BuildContext context, WidgetRef ref) async {
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final kcalCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quick Add Meal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _numField('Calories (kcal)', kcalCtrl),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _numField('Protein (g)', proteinCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _numField('Carbs (g)', carbsCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _numField('Fat (g)', fatCtrl)),
              ]),
              const SizedBox(height: 8),
              _textField('Note (optional)', noteCtrl),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final service = ref.read(nutritionServiceProvider);
                    final kcal = int.tryParse(kcalCtrl.text.trim()) ?? 0;
                    final p = int.tryParse(proteinCtrl.text.trim()) ?? 0;
                    final c = int.tryParse(carbsCtrl.text.trim()) ?? 0;
                    final f = int.tryParse(fatCtrl.text.trim()) ?? 0;
                    await service.logMeal(
                      items: [
                        {
                          'name': 'Custom Meal',
                          'kcal': kcal,
                          'protein': p,
                          'carbs': c,
                          'fat': f
                        },
                      ],
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                    );
                    if (context.mounted) Navigator.of(ctx).pop();
                  },
                  icon: const Icon(LucideIcons.save),
                  label: const Text('Save Meal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _numField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController c) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
