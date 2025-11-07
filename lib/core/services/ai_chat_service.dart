import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import 'rag_service.dart';

class AIChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  final RAGService _ragService = RAGService();

  CollectionReference get _chatSessionsRef {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('AIChatService: no authenticated user');
    }
    final uid = currentUser.uid;
    return _firestore.collection('users').doc(uid).collection('chat_sessions');
  }

  CollectionReference _getMessagesRef(String sessionId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('AIChatService: no authenticated user');
    }
    final uid = currentUser.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages');
  }

  /// Send a message to the AI chatbot with RAG
  Future<ChatMessageModel> sendMessage({
    required String message,
    String? sessionId,
    bool useRAG = true,
  }) async {
    // Create or get session
    final session = sessionId ?? await _createChatSession();

    // Save user message
    await _saveMessage(
      sessionId: session,
      role: 'user',
      content: message,
    );

    try {
      // If RAG is enabled, retrieve relevant context
      List<String> retrievedDocs = [];
      String context = '';

      if (useRAG) {
        final ragResults = await _ragService.retrieveRelevantContext(message);
        retrievedDocs = ragResults['doc_ids'] ?? [];
        context = ragResults['context'] ?? '';
      }

      // Get conversation history
      final history = await _getConversationHistory(session);

      // Call Cloud Function for AI response
      final response = await _callChatFunction(
        message: message,
        history: history,
        context: context,
      );

      // Save assistant response
      final assistantMessage = await _saveMessage(
        sessionId: session,
        role: 'assistant',
        content: response['content'] ?? 'I apologize, I encountered an error.',
        retrievedDocs: retrievedDocs,
        metadata: {
          'model': response['model'] ?? 'gpt-4',
          'tokens': response['tokens'] ?? 0,
        },
      );

      return assistantMessage;
    } catch (e) {
      // Save error message
      final errorMessage = await _saveMessage(
        sessionId: session,
        role: 'assistant',
        content: 'I apologize, but I encountered an error. Please try again.',
        metadata: {'error': e.toString()},
      );
      return errorMessage;
    }
  }

  /// Create a new chat session
  Future<String> createChatSession({String? title}) async {
    return await _createChatSession(title: title);
  }

  Future<String> _createChatSession({String? title}) async {
    final docRef = await _chatSessionsRef.add({
      'title': title ?? 'New Chat',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'message_count': 0,
    });

    return docRef.id;
  }

  /// Save a message to Firestore
  Future<ChatMessageModel> _saveMessage({
    required String sessionId,
    required String role,
    required String content,
    List<String>? retrievedDocs,
    Map<String, dynamic>? metadata,
  }) async {
    final messagesRef = _getMessagesRef(sessionId);
    final docRef = await messagesRef.add({
      'role': role,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'retrieved_docs': retrievedDocs,
      'metadata': metadata,
    });

    // Update session
    await _chatSessionsRef.doc(sessionId).update({
      'updated_at': FieldValue.serverTimestamp(),
      'message_count': FieldValue.increment(1),
    });

    final doc = await docRef.get();
    return ChatMessageModel.fromFirestore(doc);
  }

  /// Call Cloud Function for AI chat
  Future<Map<String, dynamic>> _callChatFunction({
    required String message,
    required List<Map<String, dynamic>> history,
    String? context,
  }) async {
    try {
      final callable = _functions.httpsCallable('chatCompletion');
      final result = await callable.call({
        'message': message,
        'history': history,
        'context': context,
      });

      return result.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Get conversation history
  Future<List<Map<String, dynamic>>> _getConversationHistory(
      String sessionId) async {
    final messagesRef = _getMessagesRef(sessionId);
    final snapshot = await messagesRef
        .orderBy('timestamp', descending: false)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'role': data['role'],
        'content': data['content'],
      };
    }).toList();
  }

  /// Stream messages for a session
  Stream<List<ChatMessageModel>> streamMessages(String sessionId) {
    return _getMessagesRef(sessionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  /// Get all chat sessions
  Future<List<Map<String, dynamic>>> getChatSessions() async {
    final snapshot =
        await _chatSessionsRef.orderBy('updated_at', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    // Delete messages subcollection
    final messagesRef = _getMessagesRef(sessionId);
    final messagesSnapshot = await messagesRef.get();
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete session
    await _chatSessionsRef.doc(sessionId).delete();
  }

  /// Public wrapper to save a message. Some UI code needs to save assistant
  /// messages directly (e.g., when using an external coach response).
  Future<ChatMessageModel> saveMessage({
    required String sessionId,
    required String role,
    required String content,
    List<String>? retrievedDocs,
    Map<String, dynamic>? metadata,
  }) async {
    return await _saveMessage(
      sessionId: sessionId,
      role: role,
      content: content,
      retrievedDocs: retrievedDocs,
      metadata: metadata,
    );
  }
}
