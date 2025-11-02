import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/community_service.dart';

final communityServiceProvider = Provider((ref) => CommunityService());

final communityOptInProvider = FutureProvider<bool>((ref) async {
  return ref.watch(communityServiceProvider).isOptedIn();
});

final communityFeedProvider =
    StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) {
  return ref.watch(communityServiceProvider).streamCommunityFeed(
        category: params['category'] as String?,
        limit: params['limit'] as int? ?? 20,
      );
});

final supportGroupsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(communityServiceProvider).getSupportGroups();
});

final communitySettingsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(communityServiceProvider).getCommunitySettings();
});
