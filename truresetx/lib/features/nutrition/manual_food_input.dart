import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/food_models.dart';
// backend_providers not needed here
import '../../core/services/supabase_edge_functions.dart';

/// Manual Food Input Screen for adding custom foods
class ManualFoodInputScreen extends ConsumerStatefulWidget {
  const ManualFoodInputScreen({
    super.key,
    required this.onFoodAdded,
  });
  // Produce a single FoodCatalog when a manual food is created
  final Function(FoodCatalog) onFoodAdded;

  @override
  ConsumerState<ManualFoodInputScreen> createState() =>
      _ManualFoodInputScreenState();
}

class _ManualFoodInputScreenState extends ConsumerState<ManualFoodInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _servingUnitController = TextEditingController(text: 'g');
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Other';
  bool _isSaving = false;

  final List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Grains',
    'Proteins',
    'Dairy',
    'Nuts & Seeds',
    'Beverages',
    'Snacks',
    'Desserts',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _servingSizeController.dispose();
    _servingUnitController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Custom Food'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveFood,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionHeader('Basic Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Food Name',
                hint: 'e.g., Grilled Chicken Breast',
                validator: (value) =>
                    value?.isEmpty == true ? 'Food name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _brandController,
                label: 'Brand (Optional)',
                hint: 'e.g., Tyson, Generic',
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 24),

              // Nutritional Information
              _buildSectionHeader('Nutritional Information (per serving)'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _servingSizeController,
                      label: 'Serving Size',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _servingUnitController,
                      label: 'Unit',
                      hint: 'g, ml, cup, etc.',
                      validator: (value) =>
                          value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _caloriesController,
                label: 'Calories',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Calories are required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _fatController,
                      label: 'Fat (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _fiberController,
                      label: 'Fiber (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _sugarController,
                      label: 'Sugar (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _sodiumController,
                      label: 'Sodium (mg)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Additional Information
              _buildSectionHeader('Additional Information'),
              _buildTextField(
                controller: _imageUrlController,
                label: 'Image URL (Optional)',
                hint: 'https://example.com/food-image.jpg',
              ),
              const SizedBox(height: 24),

              // Quick Fill Buttons
              _buildQuickFillButtons(),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Food Item',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildQuickFillButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Fill Templates',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFillButton('Apple', _fillAppleData),
            _buildQuickFillButton('Banana', _fillBananaData),
            _buildQuickFillButton('Chicken', _fillChickenData),
            _buildQuickFillButton('Rice', _fillRiceData),
            _buildQuickFillButton('Egg', _fillEggData),
            _buildQuickFillButton('Broccoli', _fillBroccoliData),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFillButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }

  void _fillAppleData() {
    _nameController.text = 'Apple';
    _brandController.text = 'Fresh Produce';
    _selectedCategory = 'Fruits';
    _servingSizeController.text = '1';
    _servingUnitController.text = 'medium';
    _caloriesController.text = '95';
    _proteinController.text = '0.5';
    _carbsController.text = '25.0';
    _fatController.text = '0.3';
    _fiberController.text = '4.0';
    _sugarController.text = '19.0';
    _sodiumController.text = '2.0';
    setState(() {});
  }

  void _fillBananaData() {
    _nameController.text = 'Banana';
    _brandController.text = 'Fresh Produce';
    _selectedCategory = 'Fruits';
    _servingSizeController.text = '1';
    _servingUnitController.text = 'medium';
    _caloriesController.text = '105';
    _proteinController.text = '1.3';
    _carbsController.text = '27.0';
    _fatController.text = '0.4';
    _fiberController.text = '3.1';
    _sugarController.text = '14.0';
    _sodiumController.text = '1.0';
    setState(() {});
  }

  void _fillChickenData() {
    _nameController.text = 'Chicken Breast';
    _brandController.text = 'Fresh Meat';
    _selectedCategory = 'Proteins';
    _servingSizeController.text = '100';
    _servingUnitController.text = 'g';
    _caloriesController.text = '165';
    _proteinController.text = '31.0';
    _carbsController.text = '0.0';
    _fatController.text = '3.6';
    _fiberController.text = '0.0';
    _sugarController.text = '0.0';
    _sodiumController.text = '74.0';
    setState(() {});
  }

  void _fillRiceData() {
    _nameController.text = 'Rice (Cooked)';
    _brandController.text = 'Generic';
    _selectedCategory = 'Grains';
    _servingSizeController.text = '100';
    _servingUnitController.text = 'g';
    _caloriesController.text = '130';
    _proteinController.text = '2.7';
    _carbsController.text = '28.0';
    _fatController.text = '0.3';
    _fiberController.text = '0.4';
    _sugarController.text = '0.1';
    _sodiumController.text = '1.0';
    setState(() {});
  }

  void _fillEggData() {
    _nameController.text = 'Egg';
    _brandController.text = 'Fresh';
    _selectedCategory = 'Proteins';
    _servingSizeController.text = '1';
    _servingUnitController.text = 'large';
    _caloriesController.text = '70';
    _proteinController.text = '6.0';
    _carbsController.text = '0.6';
    _fatController.text = '5.0';
    _fiberController.text = '0.0';
    _sugarController.text = '0.6';
    _sodiumController.text = '70.0';
    setState(() {});
  }

  void _fillBroccoliData() {
    _nameController.text = 'Broccoli';
    _brandController.text = 'Fresh Produce';
    _selectedCategory = 'Vegetables';
    _servingSizeController.text = '100';
    _servingUnitController.text = 'g';
    _caloriesController.text = '55';
    _proteinController.text = '3.7';
    _carbsController.text = '11.0';
    _fatController.text = '0.6';
    _fiberController.text = '5.1';
    _sugarController.text = '2.6';
    _sodiumController.text = '33.0';
    setState(() {});
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create FoodCatalog (single item) for manual entry
      final id = DateTime.now().millisecondsSinceEpoch;
      final nutrients = {
        'calories': double.tryParse(_caloriesController.text) ?? 0.0,
        'protein_g': double.tryParse(_proteinController.text) ?? 0.0,
        'carbs_g': double.tryParse(_carbsController.text) ?? 0.0,
        'fat_g': double.tryParse(_fatController.text) ?? 0.0,
        'fiber_g': double.tryParse(_fiberController.text) ?? 0.0,
        'sugar_g': double.tryParse(_sugarController.text) ?? 0.0,
        'sodium_mg': double.tryParse(_sodiumController.text) ?? 0.0,
      };

      final foodCatalog = FoodCatalog(
        id: id,
        source: 'MANUAL',
        externalId: null,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        servingQty: double.tryParse(_servingSizeController.text) ?? 100.0,
        servingUnit: _servingUnitController.text.trim().isEmpty
            ? 'serving'
            : _servingUnitController.text.trim(),
        nutrients: nutrients,
        labels: null,
        lang: 'en',
        updatedAt: DateTime.now(),
      );

      // Add to backend via edge function (send minimal map)
      final service = ref.read(supabaseEdgeFunctionsProvider);
      await service.createManualFood(foodData: {
        'id': foodCatalog.id,
        'name': foodCatalog.name,
        'brand': foodCatalog.brand,
        'serving_qty': foodCatalog.servingQty,
        'serving_unit': foodCatalog.servingUnit,
        'nutrients': foodCatalog.nutrients,
        'lang': foodCatalog.lang,
      });

      // Notify parent with the created FoodCatalog
      widget.onFoodAdded(foodCatalog);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foodCatalog.name} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add food: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
