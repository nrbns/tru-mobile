// Motivation & Resilience (MR) models — lightweight, serializable, and safe for in-memory use
// Ignore unconventional constant/enum naming used for demo fixtures.
// The enum values intentionally match domain labels used in sample data.
// analyzer: constant_identifier_names
// ignore_for_file: constant_identifier_names
enum MRProtocolKind {
  grounding,
  breath,
  anger_reset,
  boundary_script,
  no_contact,
  agent_call,
  boss_debrief,
  incident_log,
  walk_reset,
  journal_reframe,
  finance_action,
}

class MREvent {
  final int id;
  final String userId;
  final String kind; // use string to allow flexibility in demo
  final int intensity; // 1..10
  final DateTime recordedAt;
  final String? note;

  MREvent(
      {required this.id,
      required this.userId,
      required this.kind,
      required this.intensity,
      DateTime? recordedAt,
      this.note})
      : recordedAt = recordedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'kind': kind,
        'intensity': intensity,
        'recordedAt': recordedAt.toIso8601String(),
        'note': note,
      };
}

class MRProtocol {
  final int id;
  final String userId;
  final MRProtocolKind kind;
  final Map<String, dynamic> payload;
  final int minutes;
  final int? reliefDelta;
  final bool completed;
  final DateTime createdAt;

  MRProtocol(
      {required this.id,
      required this.userId,
      required this.kind,
      required this.payload,
      this.minutes = 0,
      this.reliefDelta,
      this.completed = false,
      DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'kind': kind.toString().split('.').last,
        'payload': payload,
        'minutes': minutes,
        'reliefDelta': reliefDelta,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
      };
}

class MRIncident {
  final int id;
  final String userId;
  final String source; // voice/text/photo/video/mix
  final String? description;
  final String? location;
  final List<String>? tags;
  final DateTime recordedAt;

  MRIncident(
      {required this.id,
      required this.userId,
      required this.source,
      this.description,
      this.location,
      this.tags,
      DateTime? recordedAt})
      : recordedAt = recordedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'source': source,
        'description': description,
        'location': location,
        'tags': tags,
        'recordedAt': recordedAt.toIso8601String(),
      };
}
