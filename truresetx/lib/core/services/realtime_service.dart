import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../../config.dart';
import '../../data/models/notification.dart' as app_notification;
// storage and list models are intentionally not imported here; realtime
// service emits generic map events so repositories can decide how to merge.

/// Real-time service for live data tracking and updates
class RealtimeService {
  RealtimeService._();
  static RealtimeService? _instance;
  static RealtimeService get instance => _instance ??= RealtimeService._();

  SupabaseClient? _client;
  RealtimeChannel? _userDataChannel;
  RealtimeChannel? _notificationsChannel;
  WebSocketChannel? _customSocket;

  final StreamController<Map<String, dynamic>> _dataController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<app_notification.Notification>
      _notificationController =
      StreamController<app_notification.Notification>.broadcast();
  final StreamController<String> _connectionController =
      StreamController<String>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  Stream<app_notification.Notification> get notificationStream =>
      _notificationController.stream;
  Stream<String> get connectionStream => _connectionController.stream;

  bool get isConnected => _userDataChannel != null;

  /// Initialize real-time service
  Future<void> initialize(SupabaseClient client) async {
    _client = client;
    await _setupRealtimeSubscriptions();
    await _setupCustomWebSocket();
  }

  /// Setup Supabase real-time subscriptions
  Future<void> _setupRealtimeSubscriptions() async {
    if (_client == null) return;

    try {
      // Subscribe to user data changes
      _userDataChannel = _client!
          .channel('user_data_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'workouts',
            callback: _handleWorkoutChange,
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'food_logs',
            callback: _handleFoodLogChange,
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'mood_logs',
            callback: _handleMoodLogChange,
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'meditation_logs',
            callback: _handleMeditationLogChange,
          )
          // Listen for wellness lists and list items so the UI can react
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'wellness_lists',
            callback: _handleWellnessListChange,
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'list_items',
            callback: _handleListItemChange,
          )
          .subscribe((status, error) {
        if (error != null) {
          _connectionController.add('error: ${error.toString()}');
        } else {
          _connectionController.add('connected');
        }
      });

      // Subscribe to notifications
      _notificationsChannel = _client!
          .channel('notifications')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            callback: _handleNotificationChange,
          )
          .subscribe();
    } catch (e) {
      _connectionController.add('error: $e');
    }
  }

  void _handleWellnessListChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    _dataController.add({
      'type': 'wellness_list',
      'action': payload.eventType.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleListItemChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    _dataController.add({
      'type': 'list_item',
      'action': payload.eventType.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Setup custom WebSocket for additional real-time features
  Future<void> _setupCustomWebSocket() async {
    try {
      const wsUrl = Config.socketUrl;
      _customSocket = WebSocketChannel.connect(Uri.parse(wsUrl));

      _customSocket!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _handleCustomMessage(message);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          _connectionController.add('websocket_error: $error');
        },
        onDone: () {
          _connectionController.add('websocket_disconnected');
        },
      );
    } catch (e) {
      _connectionController.add('websocket_error: $e');
    }
  }

  /// Handle workout data changes
  void _handleWorkoutChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    _dataController.add({
      'type': 'workout',
      'action': payload.eventType.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle food log changes
  void _handleFoodLogChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    _dataController.add({
      'type': 'food_log',
      'action': payload.eventType.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle mood log changes
  void _handleMoodLogChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    _dataController.add({
      'type': 'mood_log',
      'action': payload.eventType.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle meditation log changes
  void _handleMeditationLogChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    _dataController.add({
      'type': 'meditation_log',
      'action': payload.eventType.name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle notification changes
  void _handleNotificationChange(PostgresChangePayload payload) {
    final data = payload.newRecord;
    try {
      final notification = app_notification.Notification.fromJson(data);
      _notificationController.add(notification);
    } catch (e) {
      print('Error parsing notification: $e');
    }
  }

  /// Handle custom WebSocket messages
  void _handleCustomMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;

    switch (type) {
      case 'live_metrics':
        _dataController.add({
          'type': 'live_metrics',
          'data': message['data'],
          'timestamp': DateTime.now().toIso8601String(),
        });
        break;
      case 'ai_insight':
        _dataController.add({
          'type': 'ai_insight',
          'data': message['data'],
          'timestamp': DateTime.now().toIso8601String(),
        });
        break;
      case 'community_update':
        _dataController.add({
          'type': 'community_update',
          'data': message['data'],
          'timestamp': DateTime.now().toIso8601String(),
        });
        break;
      default:
        _dataController.add({
          'type': 'unknown',
          'data': message,
          'timestamp': DateTime.now().toIso8601String(),
        });
    }
  }

  /// Send real-time data to server
  Future<void> sendRealtimeData(String type, Map<String, dynamic> data) async {
    if (_customSocket != null) {
      final message = {
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _customSocket!.sink.add(jsonEncode(message));
    }
  }

  /// Send live workout metrics
  Future<void> sendWorkoutMetrics(
      String workoutId, Map<String, dynamic> metrics) async {
    await sendRealtimeData('workout_metrics', {
      'workout_id': workoutId,
      'metrics': metrics,
    });
  }

  /// Send live mood update
  Future<void> sendMoodUpdate(Map<String, dynamic> moodData) async {
    await sendRealtimeData('mood_update', moodData);
  }

  /// Send live nutrition update
  Future<void> sendNutritionUpdate(Map<String, dynamic> nutritionData) async {
    await sendRealtimeData('nutrition_update', nutritionData);
  }

  /// Send live meditation progress
  Future<void> sendMeditationProgress(
      String sessionId, Map<String, dynamic> progress) async {
    await sendRealtimeData('meditation_progress', {
      'session_id': sessionId,
      'progress': progress,
    });
  }

  /// Subscribe to specific user data
  Future<void> subscribeToUser(String userId) async {
    if (_userDataChannel != null) {
      await _userDataChannel!.unsubscribe();
    }

    _userDataChannel = _client!
        .channel('user_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'workouts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleWorkoutChange,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'food_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleFoodLogChange,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mood_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleMoodLogChange,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'meditation_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleMeditationLogChange,
        )
        .subscribe();
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribe() async {
    await _userDataChannel?.unsubscribe();
    await _notificationsChannel?.unsubscribe();
    await _customSocket?.sink.close(status.goingAway);

    _userDataChannel = null;
    _notificationsChannel = null;
    _customSocket = null;
  }

  /// Dispose resources
  void dispose() {
    unsubscribe();
    _dataController.close();
    _notificationController.close();
    _connectionController.close();
  }
}

/// Provider for RealtimeService
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  return RealtimeService.instance;
});

/// Provider for real-time data stream
final realtimeDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.dataStream;
});

/// Provider for notification stream
final realtimeNotificationProvider =
    StreamProvider<app_notification.Notification>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.notificationStream;
});

/// Provider for connection status
final realtimeConnectionProvider = StreamProvider<String>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  return service.connectionStream;
});
