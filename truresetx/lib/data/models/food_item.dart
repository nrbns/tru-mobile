/// Food Item model for nutrition tracking
class FoodItem {

  FoodItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.macros,
    required this.micronutrients,
    required this.healthBenefits,
    required this.allergens,
    required this.portionEstimate,
    required this.metadata,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      servingSize: json['serving_size'],
      calories: json['calories'].toDouble(),
      macros: Map<String, double>.from(json['macros']),
      micronutrients: Map<String, double>.from(json['micronutrients']),
      healthBenefits: List<String>.from(json['health_benefits']),
      allergens: List<String>.from(json['allergens']),
      portionEstimate: json['portion_estimate'],
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
  final String id;
  final String name;
  final String servingSize;
  final double calories;
  final Map<String, double> macros;
  final Map<String, double> micronutrients;
  final List<String> healthBenefits;
  final List<String> allergens;
  final String portionEstimate;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serving_size': servingSize,
      'calories': calories,
      'macros': macros,
      'micronutrients': micronutrients,
      'health_benefits': healthBenefits,
      'allergens': allergens,
      'portion_estimate': portionEstimate,
      'metadata': metadata,
    };
  }

  /// Adjust portion size
  FoodItem adjustPortion(double multiplier) {
    return FoodItem(
      id: id,
      name: name,
      servingSize: servingSize,
      calories: calories * multiplier,
      macros: macros.map((key, value) => MapEntry(key, value * multiplier)),
      micronutrients: micronutrients.map((key, value) => MapEntry(key, value * multiplier)),
      healthBenefits: healthBenefits,
      allergens: allergens,
      portionEstimate: portionEstimate,
      metadata: metadata,
    );
  }
}
