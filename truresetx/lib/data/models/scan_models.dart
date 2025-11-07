/// Scan models for body scans and measurements
class ScanResult {
  ScanResult({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.estimatedBodyFat,
    required this.bodyMeasures,
    required this.composition,
    required this.timestamp,
    required this.confidence,
    required this.metadata,
  });

  factory ScanResult.fromJsonSafe(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] ?? 'scan-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] ?? '',
      imagePath: json['image_path'] ?? '',
      estimatedBodyFat: (json['estimated_body_fat_pct'] is num)
          ? (json['estimated_body_fat_pct'] as num).toDouble()
          : 0.0,
      bodyMeasures: Map<String, double>.from(json['body_measures'] ?? {}),
      composition: Map<String, double>.from(json['composition'] ?? {}),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 0.0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  final String id;
  final String userId;
  final String imagePath;
  final double estimatedBodyFat;
  final Map<String, double> bodyMeasures;
  final Map<String, double> composition;
  final DateTime timestamp;
  final double confidence;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'estimated_body_fat_pct': estimatedBodyFat,
      'body_measures': bodyMeasures,
      'composition': composition,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'metadata': metadata,
    };
  }
}
