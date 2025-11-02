import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../core/providers/agent_providers.dart';

/// Voice input screen for hold-to-talk
class AgentVoiceScreen extends ConsumerStatefulWidget {
  const AgentVoiceScreen({super.key});

  @override
  ConsumerState<AgentVoiceScreen> createState() => _AgentVoiceScreenState();
}

class _AgentVoiceScreenState extends ConsumerState<AgentVoiceScreen> {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _transcript;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/voice_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );
        setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        // TODO: Transcribe audio and send to agent
        setState(() {
          _isRecording = false;
          _transcript = 'Voice input received (transcription coming soon)';
        });
        
        // Send to agent after a delay (simulating transcription)
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          final service = ref.read(agentServiceProvider);
          service.sendMessage(_transcript ?? 'Voice message');
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      debugPrint('Stop recording error: $e');
      setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Theme.of(context).primaryColor,
                ),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isRecording ? 'Recording...' : 'Hold to talk',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_transcript != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _transcript!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

