import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/models/notification.dart' as app_notification;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'realtime_service.dart';

/// Live notification service for real-time notifications
class LiveNotificationService {
  LiveNotificationService._();
  static LiveNotificationService? _instance;
  static LiveNotificationService get instance =>
      _instance ??= LiveNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<app_notification.Notification>? _notificationSubscription;
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize(RealtimeService realtimeService) async {
    if (_isInitialized) return;

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize timezone data for scheduled notifications
    tzdata.initializeTimeZones();

    // Create notification channels
    await _createNotificationChannels();

    // Listen to real-time notifications
    _notificationSubscription = realtimeService.notificationStream.listen(
      _handleRealtimeNotification,
      onError: (error) => print('Notification stream error: $error'),
    );

    // Listen to real-time data for smart notifications
    _dataSubscription = realtimeService.dataStream.listen(
      _handleRealtimeData,
      onError: (error) => print('Data stream error: $error'),
    );

    _isInitialized = true;
  }

  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel workoutChannel =
        AndroidNotificationChannel(
      'workout_reminders',
      'Workout Reminders',
      description: 'Notifications for workout reminders and achievements',
      importance: Importance.high,
    );

    const AndroidNotificationChannel nutritionChannel =
        AndroidNotificationChannel(
      'nutrition_reminders',
      'Nutrition Reminders',
      description: 'Notifications for meal logging and nutrition goals',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel moodChannel = AndroidNotificationChannel(
      'mood_reminders',
      'Mood Reminders',
      description: 'Notifications for mood check-ins and wellness insights',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel meditationChannel =
        AndroidNotificationChannel(
      'meditation_reminders',
      'Meditation Reminders',
      description: 'Notifications for meditation sessions and mindfulness',
      importance: Importance.low,
    );

    const AndroidNotificationChannel liveChannel = AndroidNotificationChannel(
      'live_updates',
      'Live Updates',
      description: 'Real-time updates and live data notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(workoutChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(nutritionChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(moodChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(meditationChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(liveChannel);
  }

  /// Handle real-time notifications
  void _handleRealtimeNotification(app_notification.Notification notification) {
    _showNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
      channelId: _getChannelId(notification.type),
      payload: notification.actionUrl,
    );
  }

  /// Handle real-time data for smart notifications
  void _handleRealtimeData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final action = data['action'] as String?;

    switch (type) {
      case 'workout':
        _handleWorkoutData(data, action);
        break;
      case 'food_log':
        _handleNutritionData(data, action);
        break;
      case 'mood_log':
        _handleMoodData(data, action);
        break;
      case 'meditation_log':
        _handleMeditationData(data, action);
        break;
      case 'live_metrics':
        _handleLiveMetrics(data);
        break;
      case 'ai_insight':
        _handleAIInsight(data);
        break;
    }
  }

  /// Handle workout data for smart notifications
  void _handleWorkoutData(Map<String, dynamic> data, String? action) {
    if (action == 'INSERT') {
      _showNotification(
        id: 'workout_completed_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode,
        title: 'Workout Completed! 🏋️',
        body: 'Great job! You\'ve completed your workout.',
        channelId: 'workout_reminders',
      );
    }
  }

  /// Handle nutrition data for smart notifications
  void _handleNutritionData(Map<String, dynamic> data, String? action) {
    if (action == 'INSERT') {
      _showNotification(
        id: 'nutrition_logged_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode,
        title: 'Food Logged! 🍎',
        body: 'Your nutrition has been tracked successfully.',
        channelId: 'nutrition_reminders',
      );
    }
  }

  /// Handle mood data for smart notifications
  void _handleMoodData(Map<String, dynamic> data, String? action) {
    if (action == 'INSERT') {
      _showNotification(
        id: 'mood_logged_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
        title: 'Mood Check-in Complete! 😊',
        body: 'Thank you for tracking your emotional wellness.',
        channelId: 'mood_reminders',
      );
    }
  }

  /// Handle meditation data for smart notifications
  void _handleMeditationData(Map<String, dynamic> data, String? action) {
    if (action == 'INSERT') {
      _showNotification(
        id: 'meditation_completed_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode,
        title: 'Meditation Complete! 🧘',
        body: 'You\'ve taken a moment for mindfulness.',
        channelId: 'meditation_reminders',
      );
    }
  }

  /// Handle live metrics for real-time notifications
  void _handleLiveMetrics(Map<String, dynamic> data) {
    final metrics = data['data'] as Map<String, dynamic>?;
    if (metrics != null) {
      final heartRate = metrics['heart_rate'] as int?;
      if (heartRate != null && heartRate > 120) {
        _showNotification(
          id: 'high_heart_rate_${DateTime.now().millisecondsSinceEpoch}'
              .hashCode,
          title: 'High Heart Rate Alert! ❤️',
          body: 'Your heart rate is $heartRate BPM. Consider taking a break.',
          channelId: 'live_updates',
        );
      }
    }
  }

  /// Handle AI insights for smart notifications
  void _handleAIInsight(Map<String, dynamic> data) {
    final insight = data['data'] as Map<String, dynamic>?;
    if (insight != null) {
      _showNotification(
        id: 'ai_insight_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
        title: 'AI Insight! 🤖',
        body: insight['message'] ?? 'You have a new wellness insight.',
        channelId: 'live_updates',
      );
    }
  }

  /// Show a notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'truresetx_channel',
      'TruResetX Notifications',
      channelDescription: 'Notifications for TruResetX wellness app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(id, title, body, notificationDetails,
        payload: payload);
  }

  /// Get channel ID based on notification type
  String _getChannelId(String type) {
    switch (type.toLowerCase()) {
      case 'workout':
        return 'workout_reminders';
      case 'nutrition':
        return 'nutrition_reminders';
      case 'mood':
        return 'mood_reminders';
      case 'meditation':
        return 'meditation_reminders';
      case 'live':
        return 'live_updates';
      default:
        return 'truresetx_channel';
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String channelId = 'truresetx_channel',
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'truresetx_reminders',
      'TruResetX Reminders',
      channelDescription: 'Scheduled reminders for TruResetX',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final tz.TZDateTime tzScheduled =
        tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Dispose resources
  void dispose() {
    _notificationSubscription?.cancel();
    _dataSubscription?.cancel();
  }
}

/// Provider for LiveNotificationService
final liveNotificationServiceProvider =
    Provider<LiveNotificationService>((ref) {
  return LiveNotificationService.instance;
});
