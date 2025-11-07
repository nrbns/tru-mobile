class RealtimeDetectedFood {
  final String clientMsgId;
  final String id;
  final String name;
  final double servingQty;
  final String? servingUnit;
  final Map<String, dynamic> nutrients;
  final String source;
  final DateTime detectedAt;
  final double? confidence;

  RealtimeDetectedFood({
    required this.clientMsgId,
    required this.id,
    required this.name,
    required this.servingQty,
    this.servingUnit,
    required this.nutrients,
    required this.source,
    required this.detectedAt,
    this.confidence,
  });

  factory RealtimeDetectedFood.fromJson(Map<String, dynamic> j) {
    final payload = j['payload'] as Map<String, dynamic>? ?? {};
    final detectedAt =
        DateTime.tryParse(payload['detectedAt']?.toString() ?? '') ??
            DateTime.now();
    return RealtimeDetectedFood(
      clientMsgId: j['clientMsgId']?.toString() ?? '',
      id: payload['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: payload['name']?.toString() ?? 'Unknown',
      servingQty: (payload['servingQty'] is num)
          ? (payload['servingQty'] as num).toDouble()
          : (double.tryParse(payload['servingQty']?.toString() ?? '') ?? 1.0),
      servingUnit: payload['servingUnit'] as String?,
      nutrients: Map<String, dynamic>.from(
          payload['nutrients'] ?? <String, dynamic>{}),
      source: payload['source']?.toString() ?? 'local',
      detectedAt: detectedAt,
      confidence: payload['confidence'] != null
          ? (payload['confidence'] as num).toDouble()
          : null,
    );
  }

  /// Optional brief description synthesized from available fields
  String? get brief {
    final parts = <String>[];
    if (servingQty > 0) {
      parts.add('${servingQty.toStringAsFixed(1)} ${servingUnit ?? ''}'.trim());
    }
    if (nutrients.containsKey('calories')) {
      final c = nutrients['calories'];
      if (c is num) parts.add('${c.toInt()} kcal');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Convert back to a JSON-serializable map for logging to the server
  Map<String, dynamic> toMap() {
    return {
      'clientMsgId': clientMsgId,
      'id': id,
      'name': name,
      'servingQty': servingQty,
      'servingUnit': servingUnit,
      'nutrients': nutrients,
      'source': source,
      'detectedAt': detectedAt.toIso8601String(),
      'confidence': confidence,
    };
  }
}
