import 'dart:async';

class Recommendation {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  Recommendation(
      {required this.id,
      required this.title,
      required this.body,
      DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
}

class RecommendationsRepository {
  RecommendationsRepository._internal();
  static final RecommendationsRepository _instance =
      RecommendationsRepository._internal();
  static RecommendationsRepository get instance => _instance;

  final _controller = StreamController<List<Recommendation>>.broadcast();
  final List<Recommendation> _items = [];
  int _nextId = 1;

  Stream<List<Recommendation>> streamRecommendations(String userId) =>
      _controller.stream;

  Future<void> addRecommendation(
      String userId, String title, String body) async {
    final r = Recommendation(id: _nextId++, title: title, body: body);
    _items.add(r);
    _controller.add(List.unmodifiable(_items));
  }

  Future<List<Recommendation>> fetch(String userId) async =>
      List.unmodifiable(_items);

  void dispose() => _controller.close();
}
