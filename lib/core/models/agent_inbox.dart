/// Agent chat inbox with messages and insights
class AgentMessage {
  final String id;
  final String text;
  final bool isFromAgent;
  final DateTime timestamp;
  final String? persona; // 'trainer', 'sage', 'friend'
  final Map<String, dynamic>? metadata;

  AgentMessage({
    required this.id,
    required this.text,
    required this.isFromAgent,
    DateTime? timestamp,
    this.persona,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AgentMessage.fromJson(Map<String, dynamic> json) {
    return AgentMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isFromAgent: json['isFromAgent'] as bool,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : null,
      persona: json['persona'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isFromAgent': isFromAgent,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'persona': persona,
      'metadata': metadata,
    };
  }
}

class AgentInbox {
  final List<AgentMessage> messages;
  final List<String> insights; // Auto-generated insights from activity

  AgentInbox({
    required this.messages,
    required this.insights,
  });

  factory AgentInbox.empty() {
    return AgentInbox(messages: [], insights: []);
  }
}

