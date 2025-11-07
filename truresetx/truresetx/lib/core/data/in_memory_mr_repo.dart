import 'dart:async';

import '../models/mr_models.dart';
import 'recommendations_repository.dart';

class InMemoryMRRepository {
  InMemoryMRRepository._internal();
  static final InMemoryMRRepository _instance =
      InMemoryMRRepository._internal();
  static InMemoryMRRepository get instance => _instance;

  final _events = <MREvent>[];
  final _protocols = <MRProtocol>[];
  final _incidents = <MRIncident>[];

  final _eventsController = StreamController<List<MREvent>>.broadcast();
  final _protocolsController = StreamController<List<MRProtocol>>.broadcast();
  final _incidentsController = StreamController<List<MRIncident>>.broadcast();

  int _nextEventId = 1;
  int _nextProtocolId = 1;
  int _nextIncidentId = 1;

  Stream<List<MREvent>> streamEvents(String userId) => _eventsController.stream;
  Stream<List<MRProtocol>> streamProtocols(String userId) =>
      _protocolsController.stream;
  Stream<List<MRIncident>> streamIncidents(String userId) =>
      _incidentsController.stream;

  Future<MREvent> addEvent(String userId, String kind, int intensity,
      {String? note}) async {
    final e = MREvent(
        id: _nextEventId++,
        userId: userId,
        kind: kind,
        intensity: intensity,
        note: note);
    _events.add(e);
    _eventsController.add(List.unmodifiable(_events));

    // Auto-generate simple recommendations using the in-memory RecommendationsRepository
    final recRepo = RecommendationsRepository.instance;
    if (kind == 'love_failure') {
      await recRepo.addRecommendation(
          userId, 'Heartbreak Grounding', '2‑min breath + 5‑4‑3‑2‑1 now.');
    } else if (kind == 'debt_pressure') {
      await recRepo.addRecommendation(userId, 'Calm Agent Call',
          'Read the script. Schedule a call in 24–48h.');
    } else if (kind == 'anger_surge') {
      await recRepo.addRecommendation(
          userId, 'Anger Reset', 'Count‑down + breath + release.');
    }

    return e;
  }

  Future<MRProtocol> addProtocol(
      String userId, MRProtocolKind kind, Map<String, dynamic> payload,
      {int minutes = 0}) async {
    final p = MRProtocol(
        id: _nextProtocolId++,
        userId: userId,
        kind: kind,
        payload: payload,
        minutes: minutes);
    _protocols.add(p);
    _protocolsController.add(List.unmodifiable(_protocols));
    return p;
  }

  Future<MRIncident> addIncident(String userId, String source,
      {String? description, String? location, List<String>? tags}) async {
    final i = MRIncident(
        id: _nextIncidentId++,
        userId: userId,
        source: source,
        description: description,
        location: location,
        tags: tags);
    _incidents.add(i);
    _incidentsController.add(List.unmodifiable(_incidents));
    return i;
  }

  Future<List<MREvent>> fetchEvents(String userId) async =>
      List.unmodifiable(_events);
  Future<List<MRProtocol>> fetchProtocols(String userId) async =>
      List.unmodifiable(_protocols);
  Future<List<MRIncident>> fetchIncidents(String userId) async =>
      List.unmodifiable(_incidents);

  void dispose() {
    _eventsController.close();
    _protocolsController.close();
    _incidentsController.close();
  }
}
