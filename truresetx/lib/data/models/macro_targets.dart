/// Macro Targets model for nutrition tracking
class MacroTargets {
  MacroTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.additionalTargets = const {},
  });

  factory MacroTargets.fromJson(Map<String, dynamic> json) {
    return MacroTargets(
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      additionalTargets:
          Map<String, dynamic>.from(json['additional_targets'] ?? {}),
    );
  }
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final Map<String, dynamic> additionalTargets;

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'additional_targets': additionalTargets,
    };
  }

  /// Calculate percentage of each macro
  Map<String, double> getMacroPercentages() {
    final totalCalories = calories;
    return {
      'protein': (protein * 4) / totalCalories * 100,
      'carbs': (carbs * 4) / totalCalories * 100,
      'fat': (fat * 9) / totalCalories * 100,
    };
  }

  /// Check if targets are met
  bool areTargetsMet(MacroTargets current) {
    const double tolerance = 0.1; // 10% tolerance
    return (current.calories / calories - 1).abs() <= tolerance &&
        (current.protein / protein - 1).abs() <= tolerance &&
        (current.carbs / carbs - 1).abs() <= tolerance &&
        (current.fat / fat - 1).abs() <= tolerance;
  }

  /// Get remaining macros
  MacroTargets getRemaining(MacroTargets current) {
    return MacroTargets(
      calories: calories - current.calories,
      protein: protein - current.protein,
      carbs: carbs - current.carbs,
      fat: fat - current.fat,
      fiber: fiber != null && current.fiber != null
          ? fiber! - current.fiber!
          : null,
      sugar: sugar != null && current.sugar != null
          ? sugar! - current.sugar!
          : null,
      sodium: sodium != null && current.sodium != null
          ? sodium! - current.sodium!
          : null,
      additionalTargets: additionalTargets,
    );
  }

  /// Copy with new values
  MacroTargets copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    Map<String, dynamic>? additionalTargets,
  }) {
    return MacroTargets(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      additionalTargets: additionalTargets ?? this.additionalTargets,
    );
  }
}
