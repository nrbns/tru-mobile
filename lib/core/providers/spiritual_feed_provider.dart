import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spiritual_feed_service.dart';

final spiritualFeedServiceProvider = Provider((ref) => SpiritualFeedService());

final dailySpiritualFeedProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(spiritualFeedServiceProvider);
  return service.getDailyFeed();
});
