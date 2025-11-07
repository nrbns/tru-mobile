import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/proactive_notifications_service.dart';

final proactiveNotificationsServiceProvider =
    Provider((ref) => ProactiveNotificationsService());

final proactiveSuggestionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(proactiveNotificationsServiceProvider)
      .getProactiveSuggestions();
});

final notificationPreferencesProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  return ref
      .watch(proactiveNotificationsServiceProvider)
      .getNotificationPreferences();
});

final shouldPromptMoodCheckinProvider = FutureProvider<bool>((ref) async {
  return ref
      .watch(proactiveNotificationsServiceProvider)
      .shouldPromptMoodCheckin();
});
