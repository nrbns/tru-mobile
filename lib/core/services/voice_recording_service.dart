import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoiceRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('VoiceRecordingService: no authenticated user');
    }
    return currentUser.uid;
  }

  /// Check and request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Start recording
  Future<String?> startRecording() async {
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission denied');
      }
    }

    if (await _recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/voice_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      return path;
    } else {
      throw Exception('Recording permission denied');
    }
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Upload audio file to Firebase Storage
  Future<String> uploadAudioFile(String filePath) async {
    final uid = _requireUid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'voice_recordings/$uid/${timestamp}_recording.m4a';

    final file = File(filePath);
    final ref = _storage.ref().child(fileName);

    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    // Delete local file after upload
    await file.delete();

    return downloadUrl;
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    if (await isRecording()) {
      await _recorder.stop();
    }
  }

  /// Dispose recorder
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
