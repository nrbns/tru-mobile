import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/youtube_video_model.dart';
import '../services/workout_service.dart';
import '../core/providers/auth_provider.dart';

final workoutServiceProvider =
    Provider<WorkoutService>((ref) => WorkoutService());

final channelVideosProvider = StateNotifierProvider<ChannelVideosNotifier,
    AsyncValue<List<YoutubeVideo>>>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return ChannelVideosNotifier(service);
});

class ChannelVideosNotifier
    extends StateNotifier<AsyncValue<List<YoutubeVideo>>> {
  final WorkoutService _service;
  ChannelVideosNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> load(String channelId) async {
    try {
      state = const AsyncValue.loading();
      final videos = await _service.fetchChannelVideos(channelId: channelId);
      state = AsyncValue.data(videos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logStart(WidgetRef ref, YoutubeVideo video) async {
    final user = ref.read(currentUserProvider);
    final uid = user?.uid ?? 'anonymous';
    await _service.logWorkoutSession(
        uid: uid,
        videoId: video.id,
        title: video.title,
        startedAt: DateTime.now());
  }

  Future<void> logComplete(WidgetRef ref, YoutubeVideo video,
      {required int durationSeconds}) async {
    final user = ref.read(currentUserProvider);
    final uid = user?.uid ?? 'anonymous';
    await _service.logWorkoutSession(
        uid: uid,
        videoId: video.id,
        title: video.title,
        startedAt: DateTime.now().subtract(Duration(seconds: durationSeconds)),
        completedAt: DateTime.now(),
        durationSeconds: durationSeconds);
  }
}
