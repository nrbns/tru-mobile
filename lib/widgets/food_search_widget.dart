import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../theme/app_colors.dart';
import '../core/services/nutrition_service.dart';

/// Food Search Widget - HealthifyMe/Spoonacular-like interface
class FoodSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodSelected;
  final NutritionService? nutritionService;

  const FoodSearchWidget({
    super.key,
    required this.onFoodSelected,
    this.nutritionService,
  });

  @override
  State<FoodSearchWidget> createState() => _FoodSearchWidgetState();
}

class _FoodSearchWidgetState extends State<FoodSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final NutritionService _nutritionService = NutritionService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isScanning = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFoods(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await (widget.nutritionService ?? _nutritionService)
          .searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching foods: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _scanBarcode() async {
    setState(() => _isScanning = true);
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF000000',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes == '-1') {
        // User cancelled
        setState(() => _isScanning = false);
        return;
      }

      final foodData = await (widget.nutritionService ?? _nutritionService)
          .scanBarcode(barcodeScanRes);

      setState(() => _isScanning = false);
      widget.onFoodSelected(foodData);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isScanning = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning barcode: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search foods (like HealthifyMe)...',
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
                              _searchFoods('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _searchFoods(value);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Barcode Scanner Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.scanLine, color: Colors.white),
                  onPressed: _isScanning ? null : _scanBarcode,
                ),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty && _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.search,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search or scan barcode',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Type food name or tap barcode icon',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final food = _searchResults[index];
                            return _FoodItem(
                              food: food,
                              onTap: () {
                                widget.onFoodSelected(food);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _FoodItem extends StatelessWidget {
  final Map<String, dynamic> food;
  final VoidCallback onTap;

  const _FoodItem({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nutrition = food['nutrition'] as Map<String, dynamic>? ?? {};
    final calories = nutrition['calories'] ?? nutrition['kcal'] ?? 0;
    final protein = nutrition['protein'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;
    final fat = nutrition['fat'] ?? 0;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: food['image'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  food['image'] as String,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.primary.withAlpha((0.2 * 255).round()),
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
        title: Text(
          food['title'] as String? ?? 'Unknown Food',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _NutrientChip(label: '$calories cal', color: AppColors.primary),
                const SizedBox(width: 4),
                _NutrientChip(label: 'P: ${protein}g', color: Colors.blue),
                const SizedBox(width: 4),
                _NutrientChip(label: 'C: ${carbs}g', color: Colors.orange),
                const SizedBox(width: 4),
                _NutrientChip(label: 'F: ${fat}g', color: Colors.red),
              ],
            ),
          ],
        ),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final Color color;

  const _NutrientChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
