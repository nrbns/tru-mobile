import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';

final subscriptionServiceProvider = Provider((ref) => SubscriptionService());

final currentTierProvider = FutureProvider<SubscriptionTier>((ref) async {
  return ref.watch(subscriptionServiceProvider).getCurrentTier();
});

final subscriptionStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getSubscriptionStatus();
});

final subscriptionLimitsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getLimits();
});

final featureAvailableProvider = FutureProvider.family<bool, String>((ref, feature) async {
  return ref.watch(subscriptionServiceProvider).isFeatureAvailable(feature);
});

