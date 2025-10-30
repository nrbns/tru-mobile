import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());

final correlationsProvider = FutureProvider<Map<String, double>>((ref) async {
  return ref.watch(analyticsServiceProvider).getMoodCorrelations();
});

final crossDomainInsightsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(analyticsServiceProvider).getCrossDomainInsights();
});

final weeklyComparisonProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(analyticsServiceProvider).getWeeklyComparison();
});

final metricTrendProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, metric) async {
  return ref.watch(analyticsServiceProvider).getMetricTrend(metric: metric);
});

/// Trend providers for dashboard
final moodTrendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(analyticsServiceProvider).getMoodTrends();
});

final nutritionTrendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(analyticsServiceProvider).getNutritionTrends();
});

final workoutTrendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(analyticsServiceProvider).getWorkoutTrends();
});

final spiritualTrendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(analyticsServiceProvider).getSpiritualTrends();
});

