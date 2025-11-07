import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/services/socket_service.dart';
import '../../config.dart';

class RealtimeLoaderScreen extends StatefulWidget {
  const RealtimeLoaderScreen({super.key});

  @override
  State<RealtimeLoaderScreen> createState() => _RealtimeLoaderScreenState();
}

class _RealtimeLoaderScreenState extends State<RealtimeLoaderScreen> {
  final SocketService _socket = SocketService();
  final List<String> _logs = [];
  double _progress = 0.0;
  final TextEditingController _queryController = TextEditingController();
  bool _querying = false;
  StreamSubscription<bool>? _connSub;
  StreamSubscription? _logSub;
  StreamSubscription? _progressSub;

  @override
  void initState() {
    super.initState();
    // Connect using the configured socket URL (can be overridden with --dart-define)
    _socket.connect(Config.socketUrl);

    // listen to connection state for UI
    _connSub = _socket.connectionState.listen((connected) {
      setState(() => _logs.insert(
          0, connected ? 'Socket connected' : 'Socket disconnected'));
      if (connected) {
        // Start demo process once connected
        _socket.emit('start');
      }
    });

    _logSub = _socket.stream('log').listen((data) {
      setState(() => _logs.insert(0, data?.toString() ?? 'log'));
    });

    _progressSub = _socket.stream('progress').listen((data) {
      final value =
          (data is num) ? data.toDouble() : double.tryParse('$data') ?? 0.0;
      setState(() => _progress = value.clamp(0.0, 1.0));
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _logSub?.cancel();
    _progressSub?.cancel();
    _socket.disconnect();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Loader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  title: Text(_logs[index]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // RAG quick query
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'Ask the coach (RAG search)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _querying ? null : () => _queryRag(_queryController.text),
                  child: _querying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Query'),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _socket.emit('pause'),
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _socket.emit('resume'),
                  child: const Text('Resume'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // toggle connection
                    _socket.disconnect();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      _socket.connect(Config.socketUrl);
                    });
                  },
                  child: const Text('Reconnect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _queryRag(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _querying = true);
    try {
      final uri = Uri.parse(Config.ragEndpoint);
      final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: Uri.encodeFull('{"query":"${q.replaceAll('"', '\\"')}"}'));
      if (resp.statusCode == 200) {
        final text = resp.body;
        setState(() => _logs.insert(
            0, 'RAG: ${text.substring(0, text.length.clamp(0, 200))}'));
      } else {
        setState(() => _logs.insert(0, 'RAG error: ${resp.statusCode}'));
      }
    } catch (e) {
      setState(() => _logs.insert(0, 'RAG query failed: $e'));
    } finally {
      setState(() => _querying = false);
    }
  }
}
