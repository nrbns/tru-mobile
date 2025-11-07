import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

typedef SocketCallback = void Function(dynamic data);

class SocketService {
  io.Socket? _socket;
  final Map<String, StreamController<dynamic>> _controllers = {};
  final StreamController<bool> _connectionState =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionState => _connectionState.stream;

  void connect(String url) {
    disconnect();
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      _addLog('connected');
      _addEvent('connect', null);
      _connectionState.add(true);
    });

    _socket?.onDisconnect((_) {
      _addLog('disconnected');
      _addEvent('disconnect', null);
      _connectionState.add(false);
    });

    _socket?.onError((err) {
      _addLog('socket_error: $err');
    });
  }

  void on(String event, SocketCallback cb) {
    _socket?.on(event, cb);
  }

  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    if (_socket != null) {
      try {
        _socket?.disconnect();
      } catch (_) {}
      _socket = null;
    }
    _controllers.forEach((_, c) => c.close());
    _controllers.clear();
    _connectionState.add(false);
  }

  Stream<dynamic> stream(String event) {
    final controller =
        _controllers[event] ??= StreamController<dynamic>.broadcast();
    // Wire up socket listener
    _socket?.on(event, (data) {
      controller.add(data);
    });
    return controller.stream;
  }

  void _addEvent(String event, dynamic data) {
    if (_controllers.containsKey(event)) _controllers[event]!.add(data);
  }

  void _addLog(String message) {
    _addEvent('log', message);
  }
}
