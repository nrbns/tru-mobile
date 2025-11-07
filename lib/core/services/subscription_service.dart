import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Subscription Service - Premium tier management
enum SubscriptionTier {
  free,
  premium,
  premiumPlus,
}

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('SubscriptionService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _subscriptionsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('subscriptions');
  }

  /// Get current subscription tier
  Future<SubscriptionTier> getCurrentTier() async {
    final uid = _requireUid();
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};
    final tier = data['subscription_tier'] as String? ?? 'free';

    switch (tier) {
      case 'premium':
        return SubscriptionTier.premium;
      case 'premium_plus':
        return SubscriptionTier.premiumPlus;
      default:
        return SubscriptionTier.free;
    }
  }

  /// Check if feature is available for current tier
  Future<bool> isFeatureAvailable(String feature) async {
    final tier = await getCurrentTier();

    final featureLimits = {
      'ai_chat_unlimited': [
        SubscriptionTier.premium,
        SubscriptionTier.premiumPlus
      ],
      'meal_planning': [SubscriptionTier.premium, SubscriptionTier.premiumPlus],
      'advanced_analytics': [
        SubscriptionTier.premium,
        SubscriptionTier.premiumPlus
      ],
      'exercise_videos': [
        SubscriptionTier.premium,
        SubscriptionTier.premiumPlus
      ],
      'wearable_sync': [SubscriptionTier.premiumPlus],
      'priority_support': [
        SubscriptionTier.premium,
        SubscriptionTier.premiumPlus
      ],
      'ad_free': [SubscriptionTier.premium, SubscriptionTier.premiumPlus],
      'offline_mode': [SubscriptionTier.premium, SubscriptionTier.premiumPlus],
      'custom_challenges': [
        SubscriptionTier.premium,
        SubscriptionTier.premiumPlus
      ],
    };

    final allowedTiers = featureLimits[feature] ?? [];
    return allowedTiers.contains(tier);
  }

  /// Get subscription limits for current tier
  Future<Map<String, dynamic>> getLimits() async {
    final tier = await getCurrentTier();

    switch (tier) {
      case SubscriptionTier.free:
        return {
          'ai_chat_messages_per_day': 10,
          'meal_plans_per_month': 0,
          'workout_plans_per_week': 3,
          'analytics_history_days': 7,
          'exercise_videos': false,
          'wearable_sync': false,
          'ads': true,
        };
      case SubscriptionTier.premium:
        return {
          'ai_chat_messages_per_day': -1, // Unlimited
          'meal_plans_per_month': 4,
          'workout_plans_per_week': -1, // Unlimited
          'analytics_history_days': 365,
          'exercise_videos': true,
          'wearable_sync': false,
          'ads': false,
        };
      case SubscriptionTier.premiumPlus:
        return {
          'ai_chat_messages_per_day': -1,
          'meal_plans_per_month': -1,
          'workout_plans_per_week': -1,
          'analytics_history_days': -1,
          'exercise_videos': true,
          'wearable_sync': true,
          'ads': false,
        };
    }
  }

  /// Check if user has reached daily limit
  Future<bool> hasReachedLimit(String feature) async {
    final limits = await getLimits();
    final limit = limits[feature];

    if (limit == null || limit == -1 || limit == false) return false;

    final uid = _requireUid();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Check usage for today
    switch (feature) {
      case 'ai_chat_messages_per_day':
        break;
      default:
        return false;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .snapshots()
        .first;

    int count = 0;
    for (var session in snapshot.docs) {
      final messagesSnapshot = await session.reference
          .collection('messages')
          .where('timestamp',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime.parse('$today 00:00:00')))
          .get();
      count += messagesSnapshot.docs.length;
    }

    return count >= (limit as int);
  }

  /// Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final tier = await getCurrentTier();
    final limits = await getLimits();

    final subscriptionDoc = await _subscriptionsRef
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    DateTime? expiresAt;
    bool isActive = false;

    if (subscriptionDoc.docs.isNotEmpty) {
      final data =
          (subscriptionDoc.docs.first.data() as Map<String, dynamic>?) ?? {};
      expiresAt = (data['expires_at'] as Timestamp?)?.toDate();
      isActive = expiresAt?.isAfter(DateTime.now()) ?? false;
    }

    return {
      'tier': tier.name,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'limits': limits,
    };
  }

  /// Update subscription (called after payment)
  Future<void> updateSubscription({
    required SubscriptionTier tier,
    required DateTime expiresAt,
    String? transactionId,
  }) async {
    final uid = _requireUid();

    // Update user document
    await _firestore.collection('users').doc(uid).update({
      'subscription_tier': tier.name,
      'subscription_expires_at': Timestamp.fromDate(expiresAt),
    });

    // Create subscription record
    await _subscriptionsRef.add({
      'tier': tier.name,
      'status': 'active',
      'expires_at': Timestamp.fromDate(expiresAt),
      'transaction_id': transactionId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
