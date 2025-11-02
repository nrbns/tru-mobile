import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/youtube_video_model.dart';

class WorkoutService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch videos for a channel using YouTube Data API.
  /// Requires YOUTUBE_API_KEY and YOUTUBE_CHANNEL_ID to be set in .env.
  Future<List<YoutubeVideo>> fetchChannelVideos(
      {required String channelId, int maxResults = 25}) async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('YOUTUBE_API_KEY not set; returning empty sample list');
      }
      return _sampleVideos();
    }

    final url = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'channelId': channelId,
      'maxResults': maxResults.toString(),
      'order': 'date',
      'type': 'video',
      'key': apiKey,
    });

    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      if (kDebugMode) {
        debugPrint('YouTube API fetch failed: ${resp.statusCode} ${resp.body}');
      }
      return _sampleVideos();
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => YoutubeVideo.fromSearchJson(e as Map<String, dynamic>))
        .where((v) => v.id.isNotEmpty)
        .toList();
  }

  /// Record a workout session to Firestore.
  Future<void> logWorkoutSession(
      {required String uid,
      required String videoId,
      required String title,
      required DateTime startedAt,
      DateTime? completedAt,
      int? durationSeconds}) async {
    final doc = _db.collection('workout_sessions').doc();
    await doc.set({
      'userId': uid,
      'videoId': videoId,
      'title': title,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt) : null,
      'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  List<YoutubeVideo> _sampleVideos() {
    return [
      YoutubeVideo(
        id: 'dQw4w9WgXcQ',
        title: 'Sample Workout 1',
        description: 'Placeholder sample workout video',
        thumbnailUrl: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        publishedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      YoutubeVideo(
        id: '3JZ_D3ELwOQ',
        title: 'Sample Workout 2',
        description: 'Placeholder sample workout video',
        thumbnailUrl: 'https://i.ytimg.com/vi/3JZ_D3ELwOQ/mqdefault.jpg',
        publishedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }
}
