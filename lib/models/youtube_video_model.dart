class YoutubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final DateTime publishedAt;

  YoutubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.publishedAt,
  });

  factory YoutubeVideo.fromSearchJson(Map<String, dynamic> json) {
    final idField = json['id'] ?? {};
    final videoId = idField['videoId'] ?? '';
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};
    final thumb =
        (thumbnails['medium'] ?? thumbnails['high'] ?? thumbnails['default']) ??
            {};

    return YoutubeVideo(
      id: videoId,
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnailUrl: thumb['url'] ?? '',
      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
