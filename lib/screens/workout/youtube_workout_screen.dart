import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../models/youtube_video_model.dart';
import '../../providers/workout_provider.dart';

class YouTubeWorkoutScreen extends ConsumerStatefulWidget {
  final String channelId;
  const YouTubeWorkoutScreen({super.key, required this.channelId});

  @override
  ConsumerState<YouTubeWorkoutScreen> createState() =>
      _YouTubeWorkoutScreenState();
}

class _YouTubeWorkoutScreenState extends ConsumerState<YouTubeWorkoutScreen> {
  YoutubePlayerController? _controller;
  YoutubeVideo? _currentVideo;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    // load videos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(channelVideosProvider.notifier).load(widget.channelId);
    });
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _playVideo(YoutubeVideo video) {
    _currentVideo = video;
    _startedAt = DateTime.now();
    ref.read(channelVideosProvider.notifier).logStart(ref, video);

    _controller?.close();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: video.id,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
      autoPlay: true,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(channelVideosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('WORKOUTBody workouts')),
      body: videosAsync.when(
        data: (videos) => Column(
          children: [
            if (_controller != null) ...[
              SizedBox(
                  height: 220, child: YoutubePlayer(controller: _controller!)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_currentVideo != null && _startedAt != null) {
                          final durationSec =
                              DateTime.now().difference(_startedAt!).inSeconds;
                          ref.read(channelVideosProvider.notifier).logComplete(
                              ref, _currentVideo!,
                              durationSeconds: durationSec);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Workout session recorded')));
                          // Clear player
                          _controller?.close();
                          _controller = null;
                          _currentVideo = null;
                          _startedAt = null;
                          setState(() {});
                        }
                      },
                      child: const Text('Mark Complete'),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final v = videos[index];
                  return ListTile(
                    leading: v.thumbnailUrl.isNotEmpty
                        ? Image.network(v.thumbnailUrl,
                            width: 96, fit: BoxFit.cover)
                        : const SizedBox(width: 96),
                    title: Text(v.title),
                    subtitle: Text(
                        v.publishedAt.toLocal().toString().split(' ').first),
                    trailing: ElevatedButton(
                      onPressed: () => _playVideo(v),
                      child: const Text('Play'),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load videos: $e')),
      ),
    );
  }
}
