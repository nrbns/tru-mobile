import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_chat_service.dart';
import '../models/chat_message_model.dart';

final aiChatServiceProvider = Provider<AIChatService>((ref) {
  return AIChatService();
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, sessionId) {
  final chatService = ref.watch(aiChatServiceProvider);
  return chatService.streamMessages(sessionId);
});

final chatSessionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final chatService = ref.watch(aiChatServiceProvider);
  return await chatService.getChatSessions();
});
