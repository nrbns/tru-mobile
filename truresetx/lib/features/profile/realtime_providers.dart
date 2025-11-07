// realtime_providers.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple user profile model used by the screen.
class UserProfile {
  final String id;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final bool isOnline;
  final DateTime lastSeen;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.isOnline,
    required this.lastSeen,
  });

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
      );
}

/// Minimal list model used for stats
class SimpleListModel {
  final String id;
  final String title;
  final String category;
  final int totalCount;
  final int completedCount;
  final List<SimpleItem> items;

  SimpleListModel({
    required this.id,
    required this.title,
    required this.category,
    required this.totalCount,
    required this.completedCount,
    required this.items,
  });
}

class SimpleItem {
  final String id;
  final String title;
  final bool isCompleted;

  SimpleItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
}

/// Abstract RealtimeService - implement with Supabase/Firebase/WebSocket in your app
abstract class RealtimeService {
  Stream<UserProfile> getProfileStream(String userId);
  Stream<List<SimpleListModel>> getListsStream(String userId);

  /// Optional: trigger remote refresh
  Future<void> refreshLists(String userId);
}

/// Mock realtime implementation for local testing - emits changing data over time.
class MockRealtimeService implements RealtimeService {
  final String userId;
  Timer? _timer;
  final StreamController<UserProfile> _profileController =
      StreamController<UserProfile>.broadcast();
  final StreamController<List<SimpleListModel>> _listsController =
      StreamController<List<SimpleListModel>>.broadcast();

  // keep some mutable state to simulate updates
  bool _online = true;
  int _completedDelta = 0;

  MockRealtimeService(this.userId) {
    // seed initial values
    final initialProfile = UserProfile(
      id: userId,
      displayName: 'Wellness Enthusiast',
      bio: 'Loving the journey 🌱',
      avatarUrl: '', // empty string -> show initial
      isOnline: _online,
      lastSeen: DateTime.now(),
    );
    _profileController.add(initialProfile);

    final lists = _generateLists();
    _listsController.add(lists);

    // every 5 seconds toggle presence and add small progress updates
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _online = !_online;
      _completedDelta = (_completedDelta + 1) % 6;
      _profileController.add(initialProfile.copyWith(
        isOnline: _online,
        lastSeen: DateTime.now(),
      ));
      _listsController.add(_generateLists());
    });
  }

  List<SimpleListModel> _generateLists() {
    return [
      SimpleListModel(
        id: 'fitness',
        title: 'Fitness',
        category: 'Fitness',
        totalCount: 10,
        completedCount: 2 + _completedDelta,
        items: List.generate(
            10,
            (i) => SimpleItem(
                id: 'f_$i',
                title: 'Workout ${i + 1}',
                isCompleted: i < (2 + _completedDelta))),
      ),
      SimpleListModel(
        id: 'nutrition',
        title: 'Nutrition',
        category: 'Nutrition',
        totalCount: 8,
        completedCount: 3 + (_completedDelta % 3),
        items: List.generate(
            8,
            (i) => SimpleItem(
                id: 'n_$i',
                title: 'Meal ${i + 1}',
                isCompleted: i < (3 + (_completedDelta % 3)))),
      ),
      SimpleListModel(
        id: 'mental',
        title: 'Mental Health',
        category: 'Mental Health',
        totalCount: 5,
        completedCount: 1 + (_completedDelta % 2),
        items: List.generate(
            5,
            (i) => SimpleItem(
                id: 'm_$i',
                title: 'Meditation ${i + 1}',
                isCompleted: i < (1 + (_completedDelta % 2)))),
      ),
    ];
  }

  @override
  Stream<UserProfile> getProfileStream(String userId) =>
      _profileController.stream;

  @override
  Stream<List<SimpleListModel>> getListsStream(String userId) =>
      _listsController.stream;

  @override
  Future<void> refreshLists(String userId) async {
    // simulate a quick remote refresh by pushing a new lists snapshot
    _listsController.add(_generateLists());
  }

  void dispose() {
    _timer?.cancel();
    _profileController.close();
    _listsController.close();
  }
}

/// Providers
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  // Replace MockRealtimeService with your real service (Supabase/Firebase/etc)
  final mock = MockRealtimeService('user_123');
  ref.onDispose(() => mock.dispose());
  return mock;
});

final userProfileStreamProvider =
    StreamProvider.autoDispose.family<UserProfile, String>((ref, userId) {
  final service = ref.watch(realtimeServiceProvider);
  return service.getProfileStream(userId);
});

final listsStreamProvider = StreamProvider.autoDispose
    .family<List<SimpleListModel>, String>((ref, userId) {
  final service = ref.watch(realtimeServiceProvider);
  return service.getListsStream(userId);
});
