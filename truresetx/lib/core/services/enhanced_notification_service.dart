import 'dart:async';
// flutter material intentionally not required here; remove to avoid name collisions
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// env not used in this service
import '../../data/models/notification.dart' as app_notification;
import 'realtime_service.dart';

/// Enhanced notification service with popups and device integration
class EnhancedNotificationService {
  EnhancedNotificationService._();
  static EnhancedNotificationService? _instance;
  static EnhancedNotificationService get instance =>
      _instance ??= EnhancedNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<app_notification.Notification>? _notificationSubscription;
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  bool _popupEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Notification settings
  Map<String, bool> _categorySettings = {
    'workout': true,
    'nutrition': true,
    'mood': true,
    'meditation': true,
    'reminder': true,
    'achievement': true,
    'live_update': true,
  };

  /// Initialize the enhanced notification service
  Future<void> initialize(RealtimeService realtimeService) async {
    if (_isInitialized) return;

    // Request notification permissions
    await _requestPermissions();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

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

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();

    if (notificationStatus.isDenied) {
      // Show dialog to enable notifications
      _showPermissionDialog();
    }

    // Request other permissions for device integration
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
    await Permission.bluetooth.request();
  }

  /// Show permission dialog
  void _showPermissionDialog() {
    // This would typically be called from a UI context
    // For now, we'll just log it
    print('Notification permission denied. Please enable in settings.');
  }

  /// Create comprehensive notification channels
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'workout_reminders',
        'Workout Reminders',
        description: 'Notifications for workout reminders and achievements',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'nutrition_reminders',
        'Nutrition Reminders',
        description: 'Notifications for meal logging and nutrition goals',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'mood_reminders',
        'Mood Reminders',
        description: 'Notifications for mood check-ins and wellness insights',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'meditation_reminders',
        'Meditation Reminders',
        description: 'Notifications for meditation sessions and mindfulness',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
      AndroidNotificationChannel(
        'live_updates',
        'Live Updates',
        description: 'Real-time updates and live data notifications',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'device_sync',
        'Device Sync',
        description: 'Notifications for fitness device synchronization',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'achievements',
        'Achievements',
        description: 'Notifications for wellness achievements and milestones',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    ];

    for (final channel in channels) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle real-time notifications with enhanced features
  void _handleRealtimeNotification(app_notification.Notification notification) {
    if (!_notificationsEnabled) return;
    if (!(_categorySettings[notification.type] ?? true)) return;

    _showEnhancedNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.body,
      channelId: _getChannelId(notification.type),
      payload: notification.actionUrl,
      category: notification.type,
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
      case 'device_sync':
        _handleDeviceSync(data);
        break;
    }
  }

  /// Handle workout data for smart notifications
  void _handleWorkoutData(Map<String, dynamic> data, String? action) {
    if (!_categorySettings['workout']!) return;

    if (action == 'INSERT') {
      _showEnhancedNotification(
        id: 'workout_completed_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode,
        title: '🏋️ Workout Completed!',
        body:
            'Great job! You\'ve completed your workout. Keep up the momentum!',
        channelId: 'workout_reminders',
        category: 'workout',
        actions: [
          NotificationAction('view_progress', 'View Progress'),
          NotificationAction('share_achievement', 'Share'),
        ],
      );
    }
  }

  /// Handle nutrition data for smart notifications
  void _handleNutritionData(Map<String, dynamic> data, String? action) {
    if (!_categorySettings['nutrition']!) return;

    if (action == 'INSERT') {
      _showEnhancedNotification(
        id: 'nutrition_logged_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode,
        title: '🍎 Food Logged!',
        body: 'Your nutrition has been tracked successfully. Stay on track!',
        channelId: 'nutrition_reminders',
        category: 'nutrition',
        actions: [
          NotificationAction('view_macros', 'View Macros'),
          NotificationAction('log_water', 'Log Water'),
        ],
      );
    }
  }

  /// Handle mood data for smart notifications
  void _handleMoodData(Map<String, dynamic> data, String? action) {
    if (!_categorySettings['mood']!) return;

    if (action == 'INSERT') {
      _showEnhancedNotification(
        id: 'mood_logged_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
        title: '😊 Mood Check-in Complete!',
        body:
            'Thank you for tracking your emotional wellness. Every check-in matters!',
        channelId: 'mood_reminders',
        category: 'mood',
        actions: [
          NotificationAction('view_insights', 'View Insights'),
          NotificationAction('meditation', 'Meditate'),
        ],
      );
    }
  }

  /// Handle meditation data for smart notifications
  void _handleMeditationData(Map<String, dynamic> data, String? action) {
    if (!_categorySettings['meditation']!) return;

    if (action == 'INSERT') {
      _showEnhancedNotification(
        id: 'meditation_completed_${DateTime.now().millisecondsSinceEpoch}'
            .hashCode,
        title: '🧘 Meditation Complete!',
        body: 'You\'ve taken a moment for mindfulness. Inner peace achieved!',
        channelId: 'meditation_reminders',
        category: 'meditation',
        actions: [
          NotificationAction('view_streak', 'View Streak'),
          NotificationAction('next_session', 'Next Session'),
        ],
      );
    }
  }

  /// Handle live metrics for real-time notifications
  void _handleLiveMetrics(Map<String, dynamic> data) {
    if (!_categorySettings['live_update']!) return;

    final metrics = data['data'] as Map<String, dynamic>?;
    if (metrics != null) {
      final heartRate = metrics['heart_rate'] as int?;
      if (heartRate != null && heartRate > 120) {
        _showEnhancedNotification(
          id: 'high_heart_rate_${DateTime.now().millisecondsSinceEpoch}'
              .hashCode,
          title: '❤️ High Heart Rate Alert!',
          body: 'Your heart rate is $heartRate BPM. Consider taking a break.',
          channelId: 'live_updates',
          category: 'live_update',
          priority: Priority.high,
        );
      }
    }
  }

  /// Handle AI insights for smart notifications
  void _handleAIInsight(Map<String, dynamic> data) {
    if (!_categorySettings['achievement']!) return;

    final insight = data['data'] as Map<String, dynamic>?;
    if (insight != null) {
      _showEnhancedNotification(
        id: 'ai_insight_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
        title: '🤖 AI Insight!',
        body: insight['message'] ?? 'You have a new wellness insight.',
        channelId: 'achievements',
        category: 'achievement',
        actions: [
          NotificationAction('view_insight', 'View Insight'),
          NotificationAction('dismiss', 'Dismiss'),
        ],
      );
    }
  }

  /// Handle device sync notifications
  void _handleDeviceSync(Map<String, dynamic> data) {
    if (!_categorySettings['live_update']!) return;

    final deviceData = data['data'] as Map<String, dynamic>?;
    if (deviceData != null) {
      _showEnhancedNotification(
        id: 'device_sync_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
        title: '⌚ Device Synced!',
        body: 'Your fitness device data has been synchronized successfully.',
        channelId: 'device_sync',
        category: 'device_sync',
        actions: [
          NotificationAction('view_data', 'View Data'),
          NotificationAction('sync_settings', 'Settings'),
        ],
      );
    }
  }

  /// Show enhanced notification with actions and customization
  Future<void> _showEnhancedNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
    String? category,
    List<NotificationAction>? actions,
    Priority priority = Priority.high,
  }) async {
    if (!_notificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportance(priority),
      priority: priority,
      enableVibration: _vibrationEnabled,
      playSound: _soundEnabled,
      actions: actions
          ?.map((action) => AndroidNotificationAction(
                action.id,
                action.title,
                icon:
                    const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              ))
          .toList(),
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
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
      case 'device':
        return 'device_sync';
      case 'achievement':
        return 'achievements';
      default:
        return 'truresetx_channel';
    }
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'workout_reminders':
        return 'Workout Reminders';
      case 'nutrition_reminders':
        return 'Nutrition Reminders';
      case 'mood_reminders':
        return 'Mood Reminders';
      case 'meditation_reminders':
        return 'Meditation Reminders';
      case 'live_updates':
        return 'Live Updates';
      case 'device_sync':
        return 'Device Sync';
      case 'achievements':
        return 'Achievements';
      default:
        return 'TruResetX Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'workout_reminders':
        return 'Notifications for workout reminders and achievements';
      case 'nutrition_reminders':
        return 'Notifications for meal logging and nutrition goals';
      case 'mood_reminders':
        return 'Notifications for mood check-ins and wellness insights';
      case 'meditation_reminders':
        return 'Notifications for meditation sessions and mindfulness';
      case 'live_updates':
        return 'Real-time updates and live data notifications';
      case 'device_sync':
        return 'Notifications for fitness device synchronization';
      case 'achievements':
        return 'Notifications for wellness achievements and milestones';
      default:
        return 'General notifications for TruResetX';
    }
  }

  Importance _getImportance(Priority priority) {
    switch (priority) {
      case Priority.max:
        return Importance.max;
      case Priority.high:
        return Importance.high;
      case Priority.defaultPriority:
        return Importance.defaultImportance;
      case Priority.low:
        return Importance.low;
      case Priority.min:
        return Importance.min;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;

    // Log payload and handle different notification actions
    print('Notification tapped with payload: $payload');

    switch (actionId) {
      case 'view_progress':
        // Navigate to progress screen
        break;
      case 'share_achievement':
        // Open share dialog
        break;
      case 'view_macros':
        // Navigate to nutrition screen
        break;
      case 'log_water':
        // Open water logging
        break;
      case 'view_insights':
        // Navigate to insights
        break;
      case 'meditation':
        // Start meditation
        break;
      case 'view_streak':
        // Show streak info
        break;
      case 'next_session':
        // Start next session
        break;
      case 'view_data':
        // Show device data
        break;
      case 'sync_settings':
        // Open sync settings
        break;
      default:
        // Handle default tap
        break;
    }
  }

  /// Notification settings
  void updateNotificationSettings({
    bool? enabled,
    bool? popup,
    bool? sound,
    bool? vibration,
    Map<String, bool>? categorySettings,
  }) {
    if (enabled != null) _notificationsEnabled = enabled;
    if (popup != null) _popupEnabled = popup;
    if (sound != null) _soundEnabled = sound;
    if (vibration != null) _vibrationEnabled = vibration;
    if (categorySettings != null) _categorySettings = categorySettings;
  }

  Map<String, dynamic> getNotificationSettings() {
    return {
      'enabled': _notificationsEnabled,
      'popup': _popupEnabled,
      'sound': _soundEnabled,
      'vibration': _vibrationEnabled,
      'categories': _categorySettings,
    };
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String channelId = 'truresetx_channel',
    String? category,
    List<NotificationAction>? actions,
  }) async {
    if (!_notificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: _vibrationEnabled,
      playSound: _soundEnabled,
      actions: actions
          ?.map((action) => AndroidNotificationAction(
                action.id,
                action.title,
              ))
          .toList(),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
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

/// Notification action class
class NotificationAction {
  NotificationAction(this.id, this.title);
  final String id;
  final String title;
}

/// Provider for EnhancedNotificationService
final enhancedNotificationServiceProvider =
    Provider<EnhancedNotificationService>((ref) {
  return EnhancedNotificationService.instance;
});
