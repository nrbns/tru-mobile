/// Nutrition Plan model for comprehensive nutrition planning
class NutritionPlan {

  NutritionPlan({
    required this.planId,
    required this.userId,
    required this.dailyTargets,
    required this.mealTiming,
    required this.mealDistribution,
    required this.recommendations,
    required this.foodPreferences,
    required this.metadata,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    return NutritionPlan(
      planId: json['plan_id'],
      userId: json['user_id'],
      dailyTargets: Map<String, double>.from(json['daily_targets']),
      mealTiming: Map<String, String>.from(json['meal_timing']),
      mealDistribution: Map<String, Map<String, double>>.from(
        json['meal_distribution'].map((key, value) => 
          MapEntry(key, Map<String, double>.from(value))
        )
      ),
      recommendations: List<String>.from(json['recommendations']),
      foodPreferences: Map<String, bool>.from(json['food_preferences']),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
  final String planId;
  final String userId;
  final Map<String, double> dailyTargets;
  final Map<String, String> mealTiming;
  final Map<String, Map<String, double>> mealDistribution;
  final List<String> recommendations;
  final Map<String, bool> foodPreferences;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'user_id': userId,
      'daily_targets': dailyTargets,
      'meal_timing': mealTiming,
      'meal_distribution': mealDistribution,
      'recommendations': recommendations,
      'food_preferences': foodPreferences,
      'metadata': metadata,
    };
  }
}
