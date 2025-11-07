import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/list_providers.dart';
import '../../data/models/wellness_list.dart';

class AddListScreen extends ConsumerStatefulWidget {
  const AddListScreen({super.key});

  @override
  ConsumerState<AddListScreen> createState() => _AddListScreenState();
}

class _AddListScreenState extends ConsumerState<AddListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ListCategory _selectedCategory = ListCategory.general;
  String? _selectedIcon;
  String? _selectedColor;

  final List<String> _availableIcons = [
    '💪',
    '🥗',
    '🧠',
    '✨',
    '🔄',
    '🎯',
    '📝',
    '🏃‍♀️',
    '🧘‍♀️',
    '🌱',
    '💧',
    '🌅',
    '🌙',
    '⭐',
    '🔥',
    '💎',
    '🌸',
    '🌈',
    '🎨',
    '📚'
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New List'),
        actions: [
          TextButton(
            onPressed: _saveList,
            child: const Text('Save'),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'List Name',
                          hintText: 'Enter a name for your list',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a list name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Describe what this list is for',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ListCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return FilterChip(
                            label: Text(_getCategoryName(category)),
                            selected: isSelected,
                            avatar: Text(_getCategoryIcon(category)),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                            selectedColor: _getCategoryColor(category)
                                .withValues(alpha: 0.2),
                            checkmarkColor: _getCategoryColor(category),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Icon Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Icon',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withValues(alpha: 0.2)
                                    : null,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: _availableColors.map((color) {
                          final isSelected = _selectedColor ==
                              color.toARGB32().toRadixString(16);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor =
                                      color.toARGB32().toRadixString(16);
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey[300]!,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveList() {
    if (_formKey.currentState!.validate()) {
      final list = createNewList(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      ref.read(listsProvider.notifier).addList(list);
      context.pop();
    }
  }

  Color _getCategoryColor(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return Colors.red;
      case ListCategory.nutrition:
        return Colors.green;
      case ListCategory.mentalHealth:
        return Colors.blue;
      case ListCategory.spiritual:
        return Colors.purple;
      case ListCategory.habits:
        return Colors.orange;
      case ListCategory.goals:
        return Colors.pink;
      case ListCategory.general:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return '💪';
      case ListCategory.nutrition:
        return '🥗';
      case ListCategory.mentalHealth:
        return '🧠';
      case ListCategory.spiritual:
        return '✨';
      case ListCategory.habits:
        return '🔄';
      case ListCategory.goals:
        return '🎯';
      case ListCategory.general:
        return '📝';
    }
  }

  String _getCategoryName(ListCategory category) {
    switch (category) {
      case ListCategory.fitness:
        return 'Fitness';
      case ListCategory.nutrition:
        return 'Nutrition';
      case ListCategory.mentalHealth:
        return 'Mental Health';
      case ListCategory.spiritual:
        return 'Spiritual';
      case ListCategory.habits:
        return 'Habits';
      case ListCategory.goals:
        return 'Goals';
      case ListCategory.general:
        return 'General';
    }
  }
}
