// ignore_for_file: avoid_print

/*
Firestore-backed repository + Riverpod providers for TruResetX Wellness (real-time)
Zero-investment: uses Firebase free tier for realtime sync.

What you get:
 - Realtime lists stream per user (users/{userId}/wellness_lists)
 - Realtime items stream per list (users/{userId}/wellness_lists/{listId}/items)
 - Add list / add item / toggle item complete
 - Optional: Daily check-ins and live metrics collection hooks
 - Extensible mappers so you can plug your existing models without changing them

Requirements (pubspec.yaml):
  firebase_core: ^2.30.1
  cloud_firestore: ^5.5.1
  firebase_auth: ^4.19.0
  flutter_riverpod: ^2.5.1
  # Optional (poll-based health data; Android/iOS permissions required)
  health: ^10.2.0

Init Firebase in main() before using this:
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

Folder structure used in Firestore:
  users/{userId}/wellness_lists/{listId}
  users/{userId}/wellness_lists/{listId}/items/{itemId}
  users/{userId}/checkins/{checkinId}
  users/{userId}/live_metrics/{metricId}   (for last-known HR/HRV/sleep)

NOTE: This file is drop-in and does not depend on your model classes. You pass
mapping lambdas to convert between your models and Map<String, dynamic>.
*/

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// If you want optional health data collection (polling), uncomment these lines
// and add the package + platform permissions.
// import 'package:health/health.dart';

// --- Generic model interfaces (keep your existing models in your project) --- //

/// Minimal interface your WellnessList should satisfy (id + title + timestamps).
/// If you already have a WellnessList class, you don't need to use this; just
/// supply toMap/fromMap mappers when constructing the repository.
class WellnessListLite {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> extra; // tags, color, ownerId, etc.

  WellnessListLite({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.extra = const {},
  });
}

class ListItemLite {
  final String id;
  final String text;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> extra; // priority, notes, score, etc.

  ListItemLite({
    required this.id,
    required this.text,
    required this.completed,
    required this.createdAt,
    this.completedAt,
    this.extra = const {},
  });
}

class DailyCheckInLite {
  final String id;
  final DateTime timestamp;

  /// 1-5 scales for energy/focus; social: 0/1; mood: -2..+2
  final int energy;
  final int focus;
  final int social; // 0/1
  final int mood;
  final Map<String, dynamic> extra; // notes, tags

  DailyCheckInLite({
    required this.id,
    required this.timestamp,
    required this.energy,
    required this.focus,
    required this.social,
    required this.mood,
    this.extra = const {},
  });
}

// --- Firestore paths helper --- //
DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
    FirebaseFirestore.instance.collection('users').doc(userId);

CollectionReference<Map<String, dynamic>> _listsCol(String userId) =>
    _userDoc(userId).collection('wellness_lists');

CollectionReference<Map<String, dynamic>> _itemsCol(
  String userId,
  String listId,
) =>
    _listsCol(userId).doc(listId).collection('items');

CollectionReference<Map<String, dynamic>> _checkinsCol(String userId) =>
    _userDoc(userId).collection('checkins');

DocumentReference<Map<String, dynamic>> _liveMetricsDoc(String userId) =>
    _userDoc(userId).collection('live_metrics').doc('current');

// --- Repository --- //

typedef ListToMap<TList> = Map<String, dynamic> Function(TList list);
typedef MapToList<TList> = TList Function(String id, Map<String, dynamic> map);

typedef ItemToMap<TItem> = Map<String, dynamic> Function(TItem item);
typedef MapToItem<TItem> = TItem Function(String id, Map<String, dynamic> map);

typedef CheckInToMap<TCheckIn> = Map<String, dynamic> Function(TCheckIn c);
typedef MapToCheckIn<TCheckIn> = TCheckIn Function(
    String id, Map<String, dynamic> map);

class WellnessRepository<TList, TItem, TCheckIn> {
  WellnessRepository({
    required this.listToMap,
    required this.mapToList,
    required this.itemToMap,
    required this.mapToItem,
    required this.checkInToMap,
    required this.mapToCheckIn,
  });

  final ListToMap<TList> listToMap;
  final MapToList<TList> mapToList;
  final ItemToMap<TItem> itemToMap;
  final MapToItem<TItem> mapToItem;
  final CheckInToMap<TCheckIn> checkInToMap;
  final MapToCheckIn<TCheckIn> mapToCheckIn;

  // --- Lists --- //
  Future<String> addList(String userId, TList list) async {
    final data = listToMap(list)
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    final doc = await _listsCol(userId).add(data);
    return doc.id;
  }

  Future<void> updateList(
      String userId, String listId, Map<String, dynamic> patch) async {
    await _listsCol(userId).doc(listId).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TList>> streamLists(String userId) {
    return _listsCol(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => mapToList(d.id, {
                  ...d.data(),
                  'createdAt': (d.data()['createdAt'] as Timestamp?)?.toDate(),
                  'updatedAt': (d.data()['updatedAt'] as Timestamp?)?.toDate(),
                }))
            .toList());
  }

  // --- Items --- //
  Future<String> addItem(String userId, String listId, TItem item) async {
    final data = itemToMap(item)
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'completed': (itemToMap(item)['completed'] as bool?) ?? false,
      });
    final doc = await _itemsCol(userId, listId).add(data);
    await updateList(userId, listId, {}); // bump updatedAt
    return doc.id;
  }

  Future<void> toggleComplete(
    String userId,
    String listId,
    String itemId,
    bool value,
  ) async {
    await _itemsCol(userId, listId).doc(itemId).update({
      'completed': value,
      'completedAt': value ? FieldValue.serverTimestamp() : null,
    });
    await updateList(userId, listId, {}); // bump updatedAt
  }

  Stream<List<TItem>> streamItems(String userId, String listId) {
    return _itemsCol(userId, listId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => mapToItem(d.id, {
                  ...d.data(),
                  'createdAt': (d.data()['createdAt'] as Timestamp?)?.toDate(),
                  'completedAt':
                      (d.data()['completedAt'] as Timestamp?)?.toDate(),
                }))
            .toList());
  }

  // --- Check-ins (daily micro surveys) --- //
  Future<String> addCheckIn(String userId, TCheckIn checkIn) async {
    final data = checkInToMap(checkIn)
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
      });
    final doc = await _checkinsCol(userId).add(data);
    return doc.id;
  }

  Stream<List<TCheckIn>> streamCheckIns(String userId, {int days = 14}) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _checkinsCol(userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => mapToCheckIn(d.id, {
                  ...d.data(),
                  'timestamp': (d.data()['timestamp'] as Timestamp).toDate(),
                }))
            .toList());
  }

  // --- Live metrics (HR, HRV, sleep) last-known values for dashboard cards --- //
  Future<void> upsertLiveMetrics(
    String userId, {
    int? heartRate,
    int? hrv,
    double? sleepHours,
    double? stressIndex,
    double? mentalScore,
    Map<String, dynamic> extra = const {},
  }) async {
    final doc = _liveMetricsDoc(userId);
    await doc.set({
      if (heartRate != null) 'heartRate': heartRate,
      if (hrv != null) 'hrv': hrv,
      if (sleepHours != null) 'sleepHours': sleepHours,
      if (stressIndex != null) 'stressIndex': stressIndex,
      if (mentalScore != null) 'mentalScore': mentalScore,
      ...extra,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> streamLiveMetrics(String userId) {
    return _liveMetricsDoc(userId).snapshots().map((doc) => {
          ...?doc.data(),
          'updatedAt': (doc.data()?['updatedAt'] as Timestamp?)?.toDate(),
        });
  }
}

// ----------------- Riverpod Providers ----------------- //

/// Provide a repository by wiring your own mappers to your existing models.
final wellnessRepositoryProvider =
    Provider<WellnessRepository<dynamic, dynamic, dynamic>>((ref) {
  return WellnessRepository(
    listToMap: (list) => list.toMap() as Map<String, dynamic>,
    mapToList: (id, map) => (map..['id'] = id),
    itemToMap: (item) => item.toMap() as Map<String, dynamic>,
    mapToItem: (id, map) => (map..['id'] = id),
    checkInToMap: (c) => c.toMap() as Map<String, dynamic>,
    mapToCheckIn: (id, map) => (map..['id'] = id),
  );
});

/// Real-time lists for a user
final wellnessListsStreamProvider =
    StreamProvider.autoDispose.family<List<dynamic>, String>((ref, userId) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return repo.streamLists(userId);
});

/// Real-time items for a specific list
final wellnessItemsStreamProvider = StreamProvider.autoDispose
    .family<List<dynamic>, ({String userId, String listId})>((ref, key) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return repo.streamItems(key.userId, key.listId);
});

/// Real-time check-ins (last 14 days by default)
final checkInsStreamProvider =
    StreamProvider.autoDispose.family<List<dynamic>, String>((ref, userId) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return repo.streamCheckIns(userId);
});

/// Real-time live metrics for dashboard cards
final liveMetricsStreamProvider = StreamProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, userId) {
  final repo = ref.watch(wellnessRepositoryProvider);
  return repo.streamLiveMetrics(userId);
});

// ----------------- Convenience Mutations ----------------- //

final addListProvider = FutureProvider.autoDispose
    .family<String, ({String userId, dynamic list})>((ref, args) async {
  final repo = ref.read(wellnessRepositoryProvider);
  return repo.addList(args.userId, args.list);
});

final addItemProvider = FutureProvider.autoDispose
    .family<String, ({String userId, String listId, dynamic item})>(
        (ref, args) async {
  final repo = ref.read(wellnessRepositoryProvider);
  return repo.addItem(args.userId, args.listId, args.item);
});

final toggleItemProvider = FutureProvider.autoDispose
    .family<void, ({String userId, String listId, String itemId, bool value})>(
        (ref, args) async {
  final repo = ref.read(wellnessRepositoryProvider);
  await repo.toggleComplete(args.userId, args.listId, args.itemId, args.value);
});

final addCheckInProvider = FutureProvider.autoDispose
    .family<String, ({String userId, dynamic checkIn})>((ref, args) async {
  final repo = ref.read(wellnessRepositoryProvider);
  return repo.addCheckIn(args.userId, args.checkIn);
});

// ----------------- OPTIONAL: Health polling hook (Android/iOS) ----------------- //
// This demonstrates how you might poll heart rate and write last-known values
// into Firestore for a live dashboard. Uncomment imports and add permissions
// to enable. Polling is used because not all platforms expose realtime streams.
/*
class HealthPollingService {
  final _health = Health();

  Future<void> requestPermissions() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.HR_VARIABILITY_SDNN,
      HealthDataType.SLEEP_ASLEEP,
    ];
    await _health.requestAuthorization(types);
  }

  Future<void> pollAndPush(String userId, WellnessRepository repo) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 6));

    final hr = await _health.getHealthDataFromTypes(start, now, [HealthDataType.HEART_RATE]);
    final hrv = await _health.getHealthDataFromTypes(start, now, [HealthDataType.HR_VARIABILITY_SDNN]);
    final sleep = await _health.getHealthDataFromTypes(now.subtract(const Duration(days: 1)), now, [HealthDataType.SLEEP_ASLEEP]);

    int? latestHR;
    if (hr.isNotEmpty) {
      hr.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      latestHR = (hr.last.value as num?)?.round();
    }

    int? latestHRV;
    if (hrv.isNotEmpty) {
      hrv.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      latestHRV = (hrv.last.value as num?)?.round();
    }

    double? sleepHours;
    if (sleep.isNotEmpty) {
      final total = sleep.fold<Duration>(Duration.zero, (acc, s) => acc + s.dateTo.difference(s.dateFrom));
      sleepHours = total.inMinutes / 60.0;
    }

    // Simple stress index demo: high HR & low sleep → higher stress
    final stressIndex = (latestHR ?? 70) / 100.0 * (1.0 + (7.0 - (sleepHours ?? 7.0)) / 7.0);

    await repo.upsertLiveMetrics(
      userId,
      heartRate: latestHR,
      hrv: latestHRV,
      sleepHours: sleepHours,
      stressIndex: stressIndex,
    );
  }
}
*/
