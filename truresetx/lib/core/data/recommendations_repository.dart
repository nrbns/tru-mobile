import 'dart:async';

import '../config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recommendation {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  Recommendation(
      {required this.id,
      required this.title,
      required this.body,
      DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  factory Recommendation.fromMap(Map<String, dynamic> m) {
    // normalize id/title/body safely to avoid type errors from various backends
    final id = (m['id'] ?? m['doc_id'] ?? '').toString();
    final title = (m['title'] ?? '').toString();
    final body = (m['body'] ?? '').toString();

    final created = m['created_at'] ?? m['createdAt'] ?? m['created_at_tz'];
    DateTime dt;
    // Handle common shapes:
    // - Firestore Timestamp
    // - native DateTime
    // - ISO-8601 String
    // - numeric (epoch milliseconds)
    if (created is DateTime) {
      dt = created;
    } else if (created is Timestamp) {
      dt = created.toDate();
    } else if (created is String) {
      dt = DateTime.tryParse(created) ??
          (int.tryParse(created) != null
              ? DateTime.fromMillisecondsSinceEpoch(int.parse(created))
              : DateTime.now());
    } else if (created is num) {
      dt = DateTime.fromMillisecondsSinceEpoch(created.toInt());
    } else {
      dt = DateTime.now();
    }
    return Recommendation(id: id, title: title, body: body, createdAt: dt);
  }
}

/// Internal interface for backend implementations
abstract class _IRecommendationsImpl {
  Stream<List<Recommendation>> streamRecommendations(String userId);
  Future<void> addRecommendation(String userId, String title, String body);
  Future<List<Recommendation>> fetch(String userId);
  void dispose();
}

/// Public facade. Keeps the old API (RecommendationsRepository.instance)
class RecommendationsRepository {
  RecommendationsRepository._internal() {
    // choose backend implementation
    try {
      if (Environment.supabaseUrl != 'https://your-project.supabase.co' &&
          Environment.supabaseAnonKey.isNotEmpty) {
        _impl = _SupabaseRecommendationsImpl();
      } else if (Environment.firebaseProjectId.isNotEmpty) {
        _impl = _FirestoreRecommendationsImpl();
      } else {
        _impl = _InMemoryRecommendationsImpl();
      }
    } catch (_) {
      _impl = _InMemoryRecommendationsImpl();
    }
  }

  static final RecommendationsRepository _instance =
      RecommendationsRepository._internal();
  static RecommendationsRepository get instance => _instance;

  late final _IRecommendationsImpl _impl;

  Stream<List<Recommendation>> streamRecommendations(String userId) =>
      _impl.streamRecommendations(userId);
  Future<void> addRecommendation(String userId, String title, String body) =>
      _impl.addRecommendation(userId, title, body);
  Future<List<Recommendation>> fetch(String userId) => _impl.fetch(userId);
  void dispose() => _impl.dispose();
}

/// In-memory implementation (preserves previous behavior)
class _InMemoryRecommendationsImpl implements _IRecommendationsImpl {
  final _controller = StreamController<List<Recommendation>>.broadcast();
  final List<Recommendation> _items = [];
  int _nextId = 1;

  @override
  Stream<List<Recommendation>> streamRecommendations(String userId) =>
      _controller.stream;

  @override
  Future<void> addRecommendation(
      String userId, String title, String body) async {
    final r =
        Recommendation(id: (_nextId++).toString(), title: title, body: body);
    _items.add(r);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<List<Recommendation>> fetch(String userId) async =>
      List.unmodifiable(_items);

  @override
  void dispose() => _controller.close();
}

/// Supabase-backed implementation. Writes to `mw_recommendations` table.
class _SupabaseRecommendationsImpl implements _IRecommendationsImpl {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  Stream<List<Recommendation>> streamRecommendations(String userId) {
    final controller = StreamController<List<Recommendation>>();

    try {
      _channel = _supabase.channel('user:recommendations:$userId');

      _channel!
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'mw_recommendations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) async {
              try {
                final rows = await fetch(userId);
                if (!controller.isClosed) controller.add(rows);
              } catch (e) {
                // ignore for stream
              }
            },
          )
          .subscribe();

      // prime initial data
      fetch(userId).then((rows) {
        if (!controller.isClosed) controller.add(rows);
      });
    } catch (e) {
      controller.addError(e);
    }

    controller.onCancel = () {
      try {
        _channel?.unsubscribe();
        _channel = null;
      } catch (_) {}
    };

    return controller.stream;
  }

  @override
  Future<void> addRecommendation(
      String userId, String title, String body) async {
    try {
      await _supabase.from('mw_recommendations').insert({
        'user_id': userId,
        'title': title,
        'body': body,
      });
    } catch (e) {
      // fall back silently to in-memory if supabase fails
      await _InMemoryRecommendationsImpl()
          .addRecommendation(userId, title, body);
    }
  }

  @override
  Future<List<Recommendation>> fetch(String userId) async {
    try {
      final dynamic res = await _supabase
          .from('mw_recommendations')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      List<dynamic> list;
      if (res is List) {
        list = res;
      } else if (res is Map && res['data'] is List) {
        list = res['data'] as List<dynamic>;
      } else {
        list = [];
      }

      final rows = list
          .map((r) => Recommendation.fromMap(
              Map<String, dynamic>.from(r as Map<dynamic, dynamic>)))
          .toList();
      return rows;
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    try {
      _channel?.unsubscribe();
      _channel = null;
    } catch (_) {}
  }
}

/// Firestore-backed implementation (fallback)
class _FirestoreRecommendationsImpl implements _IRecommendationsImpl {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  Stream<List<Recommendation>> streamRecommendations(String userId) {
    final controller = StreamController<List<Recommendation>>();

    try {
      _sub = _db
          .collection('mw_recommendations')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .listen((snap) {
        final rows = snap.docs.map((d) {
          final m = {'id': d.id, ...d.data()};
          return Recommendation.fromMap(m);
        }).toList();
        controller.add(rows);
      }, onError: (e) {
        controller.addError(e);
      });

      // no-op: initial snapshot will arrive via listener
    } catch (e) {
      controller.addError(e);
    }

    controller.onCancel = () async {
      await _sub?.cancel();
      _sub = null;
    };

    return controller.stream;
  }

  @override
  Future<void> addRecommendation(
      String userId, String title, String body) async {
    try {
      await _db.collection('mw_recommendations').add({
        'user_id': userId,
        'title': title,
        'body': body,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await _InMemoryRecommendationsImpl()
          .addRecommendation(userId, title, body);
    }
  }

  @override
  Future<List<Recommendation>> fetch(String userId) async {
    try {
      final snap = await _db
          .collection('mw_recommendations')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs
          .map((d) => Recommendation.fromMap({'id': d.id, ...d.data()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
