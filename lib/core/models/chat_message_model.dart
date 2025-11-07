import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String uid;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final List<String>? retrievedDocs; // For RAG

  ChatMessageModel({
    required this.id,
    required this.uid,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
    this.retrievedDocs,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessageModel(
      id: doc.id,
      uid: doc.reference.parent.parent!.id,
      role: data['role'] ?? 'user',
      content: data['content'] ?? '',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      retrievedDocs: data['retrieved_docs'] != null
          ? List<String>.from(data['retrieved_docs'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
      'retrieved_docs': retrievedDocs,
    };
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
