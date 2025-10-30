import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mood_service.dart';
import '../models/mood_log_model.dart';

final moodServiceProvider = Provider<MoodService>((ref) => MoodService());

/// StreamProvider for mood logs (real-time)
final moodLogsStreamProvider = StreamProvider<List<MoodLogModel>>((ref) {
  final moodService = ref.watch(moodServiceProvider);
  return moodService.streamMoodLogs(limit: 30);
});

