import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_message.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/realtime_ai_service.dart';
import '../../core/services/supabase_service.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  final ai = ref.read(aiServiceProvider);
  final realtime = ref.read(realtimeAIServiceProvider);
  return ChatMessagesNotifier(aiService: ai, realtime: realtime, ref: ref);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier({
    required AIService aiService,
    required RealtimeAIService realtime,
    required this.ref,
  })  : _ai = aiService,
        _realtime = realtime,
        super([]) {
    _initRealtimeListener();
  }

  final AIService _ai;
  final RealtimeAIService _realtime;
  final Ref ref;

  StreamSubscription<ChatMessage>? _realtimeSub;
  bool _isSending = false;
  DateTime? _lastSentAt;
  final Duration _minSendInterval = const Duration(seconds: 1);

  // Typing indicator exposed to UI via a stream
  final _typingController = StreamController<bool>.broadcast();
  Stream<bool> get typingStream => _typingController.stream;

  void _initRealtimeListener() {
    try {
      _realtimeSub = _realtime.messageStreamController.stream.listen((msg) {
        if (!state.any((m) => m.id == msg.id)) {
          state = [...state, msg];
          // persist incoming message
          unawaited(_persistMessage(msg));
        }
      }, onError: (e) {
        debugPrint('Realtime message stream error: $e');
      });
    } catch (e) {
      debugPrint('Failed to init realtime listener: $e');
    }
  }

  /// Load persisted history (wire this to Supabase/local DB)
  Future<void> loadHistory(String userId, {String? sessionId}) async {
    try {
      final svc = ref.read(supabaseServiceProvider);
      final history = await svc.getChatHistory(userId, sessionId: sessionId);
      state = history;
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  /// Optimistic send: add user message, call AI, add assistant response
  Future<void> sendMessage({
    required String userId,
    required String persona,
    required String text,
    Duration aiTimeout = const Duration(seconds: 15),
  }) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    if (_lastSentAt != null &&
        now.difference(_lastSentAt!) < _minSendInterval) {
      return; // prevent accidental double-sends
    }
    _lastSentAt = now;

    if (_isSending) {
      debugPrint('Send in progress, ignoring new send.');
      return;
    }

    _isSending = true;

    final userMsg = ChatMessage.create(
      userId: userId,
      role: 'user',
      message: text,
      persona: persona,
    );

    // optimistic add
    state = [...state, userMsg];

    // persist user message async
    unawaited(_persistMessage(userMsg));

    // Notify UI that AI is typing
    _typingController.add(true);

    try {
      // Try to send to realtime pipeline (server-side agents) first
      try {
        await _realtime.sendMessage(
          userId: userMsg.userId,
          message: userMsg.message,
          persona: userMsg.persona ?? 'general',
          sessionId: userMsg.sessionId,
        );
      } catch (e) {
        debugPrint('Realtime send failed, falling back to local AI: $e');
      }

      // Local AI call as fallback / immediate response path
      final aiResponse = await _ai
          .chatCompletion(_buildPromptForPersona(persona, text))
          .timeout(aiTimeout);

      final assistantMsg = ChatMessage.create(
        userId: userId,
        role: 'assistant',
        message: aiResponse,
        persona: persona,
      );

      // Add assistant message (avoid duplication if server pushed same message)
      if (!state.any((m) => m.id == assistantMsg.id)) {
        state = [...state, assistantMsg];
      }

      // persist assistant message async
      unawaited(_persistMessage(assistantMsg));

      // push assistant msg to realtime pipeline so other clients sync
      try {
        await _realtime.sendMessage(
          userId: assistantMsg.userId,
          message: assistantMsg.message,
          persona: assistantMsg.persona ?? 'general',
          sessionId: assistantMsg.sessionId,
        );
      } catch (e) {
        debugPrint('Realtime push assistant message failed: $e');
      }
    } catch (e, st) {
      debugPrint('sendMessage error: $e\n$st');
      final errMsg = ChatMessage.create(
        userId: userId,
        role: 'assistant',
        message:
            'I\'m sorry — something went wrong while sending that message. Please try again.',
        persona: persona,
      );
      state = [...state, errMsg];
    } finally {
      _typingController.add(false);
      _isSending = false;
    }
  }

  Future<void> addIncomingMessage(ChatMessage message) async {
    if (!state.any((m) => m.id == message.id)) {
      state = [...state, message];
      unawaited(_persistMessage(message));
    }
  }

  Future<void> _persistMessage(ChatMessage message) async {
    try {
      final svc = ref.read(supabaseServiceProvider);
      await svc.createChatMessage(message);
    } catch (e) {
      debugPrint('Failed to persist message: $e');
    }
  }

  String _buildPromptForPersona(String persona, String userMessage) {
    return '''
You are a TruResetX assistant with persona: $persona.
User: $userMessage

Respond helpfully and concisely as $persona.
''';
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _typingController.close();
    super.dispose();
  }
}
