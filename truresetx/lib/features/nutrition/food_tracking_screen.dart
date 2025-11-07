import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/backend_providers.dart';
import '../../data/models/food_models.dart';
import 'food_scanner.dart';
import 'manual_food_input.dart';
import 'water_logging_screen.dart';
import '../../core/services/supabase_edge_functions.dart';
import '../../data/providers/realtime_providers.dart';

class FoodTrackingScreen extends ConsumerStatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  ConsumerState<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends ConsumerState<FoodTrackingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMeal = 'breakfast';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(foodSearchQueryProvider);
    final dailyNutrition = ref.watch(dailyNutritionProvider(null));
    final liveDetection = ref.watch(liveDetectedFoodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Live detection banner
          liveDetection.when(
            data: (d) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.yellow[100],
                  child: ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: Text(
                        'Detected: ${d.name} (${((d.confidence ?? 0.0) * 100).toStringAsFixed(0)}%)'),
                    subtitle: Text(d.brief ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final detected = d;
                            // Capture messenger before the async gap to avoid
                            // using BuildContext across await.
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref
                                  .read(supabaseEdgeFunctionsProvider)
                                  .logDetectedFood(detected.toMap());
                              ref.invalidate(dailyNutritionProvider);
                              if (!mounted) return;
                              messenger.showSnackBar(const SnackBar(
                                  content: Text('Detected food logged')));
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(SnackBar(
                                  content:
                                      Text('Error logging detected food: $e')));
                            }
                          },
                          child: const Text('Accept'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Ignore: do nothing for now
                          },
                          child: const Text('Ignore'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Search Bar
          _buildSearchBar(),

          // Meal Selector
          _buildMealSelector(),

          // Daily Nutrition Summary
          dailyNutrition.when(
            data: (nutrition) => _buildNutritionSummary(nutrition),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),

          // Search Results or Recent Foods
          Expanded(
            child: searchQuery.isNotEmpty
                ? _buildSearchResults(searchQuery)
                : _buildRecentFoods(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openWaterLogging,
            backgroundColor: Colors.blue,
            tooltip: 'Water Logging',
            child: const Icon(Icons.water_drop),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _openFoodScanner,
            backgroundColor: Colors.green,
            tooltip: 'Scan Food',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _openManualInput,
            backgroundColor: Colors.orange,
            tooltip: 'Add Food',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for foods...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(foodSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          ref.read(foodSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildMealSelector() {
    final meals = ['breakfast', 'lunch', 'dinner', 'snacks'];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          final isSelected = _selectedMeal == meal;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(meal.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMeal = meal;
                });
              },
              selectedColor: Colors.blue.withAlpha((0.2 * 255).round()),
              checkmarkColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionSummary(DailyNutrition nutrition) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Nutrition',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${nutrition.nutritionScore}/100',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutritionMetric(
                  'Calories',
                  '${nutrition.totalCalories.toInt()}',
                  'kcal',
                  nutrition.caloriesProgress,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildNutritionMetric(
                  'Protein',
                  '${nutrition.totalProtein.toInt()}g',
                  'goal: ${(nutrition.goals['protein_g'] ?? 150).toInt()}g',
                  nutrition.proteinProgress,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutritionMetric(
                  'Carbs',
                  '${nutrition.totalCarbs.toInt()}g',
                  'goal: ${(nutrition.goals['carbs_g'] ?? 250).toInt()}g',
                  nutrition.carbsProgress,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildNutritionMetric(
                  'Fat',
                  '${nutrition.totalFat.toInt()}g',
                  'goal: ${(nutrition.goals['fat_g'] ?? 65).toInt()}g',
                  nutrition.fatProgress,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionMetric(
    String label,
    String value,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildSearchResults(String query) {
    final searchResults = ref.watch(foodSearchProvider(query));

    return searchResults.when(
      data: (results) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.foods.length,
        itemBuilder: (context, index) {
          final food = results.foods[index];
          return _buildFoodItem(food);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error searching foods: $error'),
      ),
    );
  }

  Widget _buildRecentFoods() {
    // This would typically show recently logged foods
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for foods to log',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start typing to search our food database',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodCatalog food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withAlpha((0.1 * 255).round()),
          child: const Icon(Icons.restaurant, color: Colors.blue),
        ),
        title: Text(food.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(food.formattedServingSize),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildNutrientChip(
                    '${food.calories.toInt()} cal', Colors.orange),
                const SizedBox(width: 4),
                _buildNutrientChip(
                    '${food.protein.toInt()}g protein', Colors.green),
                const SizedBox(width: 4),
                _buildNutrientChip('${food.carbs.toInt()}g carbs', Colors.blue),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _logFood(food),
        ),
        onTap: () => _showFoodDetails(food),
      ),
    );
  }

  Widget _buildNutrientChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _logFood(FoodCatalog food) {
    showDialog(
      context: context,
      builder: (context) => _LogFoodDialog(
        food: food,
        meal: _selectedMeal,
        onLogged: () {
          // Refresh daily nutrition
          ref.invalidate(dailyNutritionProvider);
        },
      ),
    );
  }

  void _showFoodDetails(FoodCatalog food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(food.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serving: ${food.formattedServingSize}'),
            const SizedBox(height: 16),
            const Text('Nutrition per serving:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildNutritionRow('Calories', '${food.calories.toInt()} kcal'),
            _buildNutritionRow('Protein', '${food.protein.toInt()}g'),
            _buildNutritionRow('Carbs', '${food.carbs.toInt()}g'),
            _buildNutritionRow('Fat', '${food.fat.toInt()}g'),
            if (food.fiber > 0)
              _buildNutritionRow('Fiber', '${food.fiber.toInt()}g'),
            if (food.sodium > 0)
              _buildNutritionRow('Sodium', '${food.sodium.toInt()}mg'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logFood(food);
            },
            child: const Text('Log Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Navigation helpers used by the FABs
  void _openWaterLogging() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WaterLoggingScreen(),
      ),
    );
  }

  void _openFoodScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScanner(
          onFoodDetected: (food) {
            Navigator.pop(context);
            _logFood(food);
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          },
        ),
      ),
    );
  }

  void _openManualInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualFoodInputScreen(
          onFoodAdded: (food) {
            Navigator.pop(context);
            _logFood(food);
          },
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Database'),
              subtitle: const Text('Find foods from our database'),
              onTap: () {
                Navigator.pop(context);
                _searchController.clear();
                FocusScope.of(context).requestFocus();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scan Barcode'),
              subtitle: const Text('Scan product barcode'),
              onTap: () => _scanBarcode(),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              subtitle: const Text('Analyze food with camera'),
              onTap: () => _takePhoto(),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Manual Entry'),
              subtitle: const Text('Create custom food item'),
              onTap: () => _createManualFood(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // NOTE: _showAddFoodDialog removed from usage and can be reintroduced if needed.

  void _scanBarcode() {
    Navigator.pop(context);
    // Implement barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcode scanning not implemented yet')),
    );
  }

  void _takePhoto() {
    Navigator.pop(context);
    // Implement photo analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo analysis not implemented yet')),
    );
  }

  void _createManualFood() {
    Navigator.pop(context);
    // Navigate to manual food creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual food creation not implemented yet')),
    );
  }
}

// ignore: unused_element_parameter
class _LogFoodDialog extends ConsumerStatefulWidget {
  const _LogFoodDialog({
    required this.food,
    required this.meal,
    required this.onLogged,
  });

  final FoodCatalog food;
  final String meal;
  final VoidCallback onLogged;

  @override
  ConsumerState<_LogFoodDialog> createState() => _LogFoodDialogState();
}

class _LogFoodDialogState extends ConsumerState<_LogFoodDialog> {
  double _quantity = 1.0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log ${widget.food.displayName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity = (_quantity - 0.1).clamp(0.1, 100.0);
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _quantity.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity = (_quantity + 0.1).clamp(0.1, 100.0);
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Nutrition for this serving:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildNutritionRow('Calories',
                      '${(widget.food.calories * _quantity).toInt()} kcal'),
                  _buildNutritionRow('Protein',
                      '${(widget.food.protein * _quantity).toInt()}g'),
                  _buildNutritionRow(
                      'Carbs', '${(widget.food.carbs * _quantity).toInt()}g'),
                  _buildNutritionRow(
                      'Fat', '${(widget.food.fat * _quantity).toInt()}g'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _logFood, child: const Text('Log Food')),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500))
        ],
      ),
    );
  }

  Future<void> _logFood() async {
    try {
      final service = ref.read(supabaseEdgeFunctionsProvider);

      final foodData = {
        'food_id': widget.food.id,
        'quantity': _quantity,
        'meal': widget.meal,
        'notes':
            _notesController.text.isNotEmpty ? _notesController.text : null,
        'logged_at': DateTime.now().toIso8601String(),
      };

      await service.logFood(foodData: foodData);

      if (mounted) {
        Navigator.pop(context);
        widget.onLogged();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food logged successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error logging food: $e')));
      }
    }
  }
}
