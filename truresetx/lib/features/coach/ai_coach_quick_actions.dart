import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// no longer need realtime_ai_service import here

/// Quick Actions Widget for AI Coach
class AICoachQuickActions extends ConsumerWidget {
  const AICoachQuickActions({
    super.key,
    required this.persona,
    required this.onActionSelected,
  });
  final String persona;
  final Function(String) onActionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _getPersonaActions(persona);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((action) {
              return _buildActionChip(context, action);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, Map<String, dynamic> action) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action['emoji']),
          const SizedBox(width: 4),
          Text(action['label']),
        ],
      ),
      onPressed: () => onActionSelected(action['action']),
      backgroundColor: action['color'].withAlpha((0.1 * 255).round()),
      labelStyle: TextStyle(
        color: action['color'],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<Map<String, dynamic>> _getPersonaActions(String persona) {
    switch (persona) {
      case 'astra':
        return [
          {
            'label': 'Create Workout',
            'action': 'workout_plan',
            'emoji': '💪',
            'color': Colors.green,
          },
          {
            'label': 'Form Check',
            'action': 'form_check',
            'emoji': '🎯',
            'color': Colors.blue,
          },
          {
            'label': 'Motivation',
            'action': 'motivation',
            'emoji': '🔥',
            'color': Colors.orange,
          },
          {
            'label': 'Recovery',
            'action': 'recovery',
            'emoji': '🛌',
            'color': Colors.purple,
          },
        ];
      case 'sage':
        return [
          {
            'label': 'Meditation',
            'action': 'meditation_guide',
            'emoji': '🧘',
            'color': Colors.purple,
          },
          {
            'label': 'Stress Help',
            'action': 'stress_help',
            'emoji': '😌',
            'color': Colors.blue,
          },
          {
            'label': 'Breathing',
            'action': 'breathing',
            'emoji': '🫁',
            'color': Colors.green,
          },
          {
            'label': 'Sleep',
            'action': 'sleep',
            'emoji': '😴',
            'color': Colors.indigo,
          },
        ];
      case 'fuel':
        return [
          {
            'label': 'Meal Plan',
            'action': 'meal_plan',
            'emoji': '🍽️',
            'color': Colors.orange,
          },
          {
            'label': 'Nutrition Advice',
            'action': 'nutrition_advice',
            'emoji': '🍎',
            'color': Colors.green,
          },
          {
            'label': 'Hydration',
            'action': 'hydration',
            'emoji': '💧',
            'color': Colors.blue,
          },
          {
            'label': 'Supplements',
            'action': 'supplements',
            'emoji': '💊',
            'color': Colors.purple,
          },
        ];
      default:
        return [
          {
            'label': 'Workout Help',
            'action': 'workout_plan',
            'emoji': '💪',
            'color': Colors.green,
          },
          {
            'label': 'Nutrition',
            'action': 'nutrition_advice',
            'emoji': '🍎',
            'color': Colors.orange,
          },
          {
            'label': 'Meditation',
            'action': 'meditation_guide',
            'emoji': '🧘',
            'color': Colors.purple,
          },
          {
            'label': 'Motivation',
            'action': 'motivation',
            'emoji': '🔥',
            'color': Colors.red,
          },
        ];
    }
  }
}
