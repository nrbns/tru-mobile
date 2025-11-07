/// Represents an agent suggestion/intent that surfaces in the UI
class AgentIntent {
  final String intentId;
  final String title;
  final String? subtitle;
  final String cta; // "Begin", "Start", "Explore", etc.
  final String icon; // Material icon name or asset path
  final double priority; // 0.0 to 1.0
  final int? expiresInSec; // Optional TTL
  final Map<String, dynamic>? metadata; // Extra context (route, params, etc.)
  final DateTime createdAt;

  AgentIntent({
    required this.intentId,
    required this.title,
    this.subtitle,
    required this.cta,
    required this.icon,
    required this.priority,
    this.expiresInSec,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from JSON (e.g., from rules engine or backend)
  factory AgentIntent.fromJson(Map<String, dynamic> json) {
    return AgentIntent(
      intentId: json['intentId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      cta: json['cta'] as String? ?? 'Start',
      icon: json['icon'] as String,
      priority: (json['priority'] as num?)?.toDouble() ?? 0.5,
      expiresInSec: json['expiresInSec'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intentId': intentId,
      'title': title,
      'subtitle': subtitle,
      'cta': cta,
      'icon': icon,
      'priority': priority,
      'expiresInSec': expiresInSec,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Check if intent is expired
  bool get isExpired {
    if (expiresInSec == null) return false;
    final expiry = createdAt.add(Duration(seconds: expiresInSec!));
    return DateTime.now().isAfter(expiry);
  }
}

