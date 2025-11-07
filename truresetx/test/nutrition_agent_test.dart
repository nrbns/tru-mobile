import 'package:flutter_test/flutter_test.dart';
import 'package:truresetx/core/ai/nutrition_agent.dart';

void main() {
  group('RecognizedFood.fromJsonSafe', () {
    test('parses ints and doubles and strings safely', () {
      final json = {
        'name': 'Test Food',
        'serving_size': '1 cup',
        'calories': 150,
        'macros': {
          'protein_g': '5.0',
          'carbs_g': 30,
          'fat_g': 2.0,
          'fiber_g': null
        },
        'micronutrients': {
          'vitamin_c_mg': '45',
          'iron_mg': 2.1,
          'calcium_mg': 100
        },
        'health_benefits': ['high_fiber'],
        'allergens': [],
        'portion_estimate': 'medium'
      };

      final food = RecognizedFood.fromJsonSafe(json);

      expect(food.name, 'Test Food');
      expect(food.servingSize, '1 cup');
      expect(food.calories, 150.0);
      expect(food.macros['protein_g'], 5.0);
      expect(food.macros['carbs_g'], 30.0);
      expect(food.macros['fiber_g'], 0.0);
      expect(food.micronutrients['vitamin_c_mg'], 45.0);
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'name': 'Partial',
        'calories': '200',
        'macros': null,
        'micronutrients': null,
      };

      final food = RecognizedFood.fromJsonSafe(json);

      expect(food.name, 'Partial');
      expect(food.calories, 200.0);
      expect(food.macros.isEmpty, true);
      expect(food.micronutrients.isEmpty, true);
    });
  });
}
