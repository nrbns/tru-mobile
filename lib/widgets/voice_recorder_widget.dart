import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import '../theme/app_colors.dart';
import '../core/services/voice_recording_service.dart';
import '../core/services/speech_to_text_service.dart';
import '../core/services/voice_analysis_service.dart';

/// Voice recorder widget for CBT journaling
class VoiceRecorderWidget extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAnalysisComplete;
  final Function(String)? onTranscriptReceived;

  const VoiceRecorderWidget({
    super.key,
    this.onAnalysisComplete,
    this.onTranscriptReceived,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final VoiceRecordingService _recordingService = VoiceRecordingService();
  final SpeechToTextService _speechService = SpeechToTextService();
  final VoiceAnalysisService _analysisService = VoiceAnalysisService();

  late AnimationController _pulseController;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _currentTranscript;
  String? _recordedFilePath;
  // removed unused recording duration field

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _speechService.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordingService.dispose();
    _speechService.stopListening();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isRecording = true;
        _currentTranscript = null;
      });

      // Start audio recording
      await _recordingService.startRecording();

      // Start speech-to-text
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _currentTranscript = text;
          });
          widget.onTranscriptReceived?.call(text);
        },
        onPartialResults: (text) {
          setState(() {
            _currentTranscript = text;
          });
        },
      );

      _pulseController.repeat();
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error starting recording: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      _pulseController.stop();

      // Stop speech-to-text
      await _speechService.stopListening();

      // Stop audio recording
      _recordedFilePath = await _recordingService.stopRecording();

      // Process the recording
      await _processRecording();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error stopping recording: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _processRecording() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      String? audioUrl;

      // Upload audio file if recording was successful
      if (_recordedFilePath != null) {
        audioUrl = await _recordingService.uploadAudioFile(_recordedFilePath!);
      }

      // Analyze transcript if available
      if (_currentTranscript != null && _currentTranscript!.isNotEmpty) {
        final analysis = await _analysisService.analyzeTranscript(
          transcript: _currentTranscript!,
          audioUrl: audioUrl,
        );

        widget.onAnalysisComplete?.call({
          'transcript': _currentTranscript,
          'audio_url': audioUrl,
          ...analysis,
        });

        setState(() {
          _isProcessing = false;
        });
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Voice analysis complete!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() {
          _isProcessing = false;
        });
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No speech detected. Please try again.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error analyzing recording: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Recording Button
        GestureDetector(
          onTap: _isRecording
              ? _stopRecording
              : (_isProcessing ? null : _startRecording),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: _isRecording
                      ? AppColors.aiGradient
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            // compute color with alpha without using deprecated withOpacity or color channel accessors
                            color: AppColors.primaryGlow.withAlpha(
                              ((0.5 + (_pulseController.value * 0.3)) * 255)
                                  .round(),
                            ),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _isRecording
                      ? LucideIcons.stop
                      : _isProcessing
                          ? LucideIcons.loader
                          : LucideIcons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Status Text
        Text(
          _isProcessing
              ? 'Analyzing...'
              : _isRecording
                  ? 'Recording... Tap to stop'
                  : 'Tap to record your thoughts',
          style: TextStyle(
            fontSize: 14,
            color: _isRecording ? AppColors.primary : Colors.grey[400],
            fontWeight: _isRecording ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        // Transcript Preview
        if (_currentTranscript != null && _currentTranscript!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentTranscript!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[300],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
