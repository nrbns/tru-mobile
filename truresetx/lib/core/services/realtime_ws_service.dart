import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/models/realtime_models.dart';

/// Lightweight WebSocket-backed realtime service for detected food events.
/// - reconnect backoff
/// - ping to keep alive
/// - broadcasts parsed RealtimeDetectedFood objects
class RealtimeWsService {
  final String wsUrl;
  final String? token;
  WebSocketChannel? _channel;
  final StreamController<RealtimeDetectedFood> _controller = StreamController.broadcast();
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  final int maxReconnect = 6;

  RealtimeWsService({required this.wsUrl, this.token});

  Stream<RealtimeDetectedFood> get detections => _controller.stream;

  void connect() {
    _disposeChannel();
    try {
      final uri = Uri.parse(wsUrl);
      final uriWithToken = token != null
          ? uri.replace(queryParameters: {...uri.queryParameters, 'token': token!})
          : uri;
      _channel = WebSocketChannel.connect(uriWithToken);

      _channel!.stream.listen((raw) {
        _onMessage(raw);
      }, onError: (err) {
        _scheduleReconnect();
      }, onDone: () {
        _scheduleReconnect();
      }, cancelOnError: true);

      _startPing();
      _reconnectAttempts = 0;
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      if (raw is String) {
        final parsed = json.decode(raw) as Map<String, dynamic>;
        final type = parsed['type']?.toString() ?? '';
        if (type == 'detected_food' || parsed['payload'] != null) {
          final detection = RealtimeDetectedFood.fromJson(parsed);
          _controller.add(detection);
        }
      }
    } catch (e) {
      // ignore parse errors
    }
  }

  void send(Map<String, dynamic> message) {
    try {
      if (_channel != null) {
        _channel!.sink.add(json.encode(message));
      }
    } catch (e) {
      // ignore
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _channel?.sink.add(json.encode({'type': 'ping', 'ts': DateTime.now().toUtc().toIso8601String()}));
      } catch (_) {}
    });
  }

  void _disposeChannel() {
    try {
      _pingTimer?.cancel();
      _pingTimer = null;
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _scheduleReconnect() {
    _disposeChannel();
    if (_reconnectAttempts >= maxReconnect) {
      return;
    }
    _reconnectAttempts += 1;
    final backoffMs = (1000 * (1 << _reconnectAttempts)).clamp(1000, 16000);
    Future.delayed(Duration(milliseconds: backoffMs), () {
      connect();
    });
  }

  void dispose() {
    _disposeChannel();
    try {
      _controller.close();
    } catch (_) {}
  }
}
