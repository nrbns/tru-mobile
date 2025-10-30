import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<_GroceryItem> _items = [
    _GroceryItem(id: '1', name: 'Bananas', checked: false),
    _GroceryItem(id: '2', name: 'Spinach', checked: true),
    _GroceryItem(id: '3', name: 'Chicken Breast', checked: false),
    _GroceryItem(id: '4', name: 'Brown Rice', checked: false),
    _GroceryItem(id: '5', name: 'Greek Yogurt', checked: true),
    _GroceryItem(id: '6', name: 'Almonds', checked: false),
  ];

  void _toggleItem(String id) {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        if (_items[i].id == id) {
          _items[i] = _items[i].copyWith(checked: !_items[i].checked);
          break;
        }
      }
    });
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
                          'Grocery List',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Your shopping list',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AuraCard(
                      variant: AuraCardVariant.nutrition,
                      child: CheckboxListTile(
                        value: item.checked,
                        onChanged: (_) => _toggleItem(item.id),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            color:
                                item.checked ? Colors.grey[500] : Colors.white,
                            fontSize: 16,
                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        activeColor: AppColors.nutritionColor,
                        checkColor: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroceryItem {
  final String id;
  final String name;
  bool checked;

  _GroceryItem({
    required this.id,
    required this.name,
    required this.checked,
  });

  _GroceryItem copyWith({bool? checked}) {
    return _GroceryItem(
      id: id,
      name: name,
      checked: checked ?? this.checked,
    );
  }
}
