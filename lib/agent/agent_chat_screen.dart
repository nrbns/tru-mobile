import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/agent_providers.dart';
import '../core/models/agent_inbox.dart';
import 'agent_styles.dart';

/// Agent chat screen with persona-aware messages
class AgentChatScreen extends ConsumerStatefulWidget {
  const AgentChatScreen({super.key});

  @override
  ConsumerState<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends ConsumerState<AgentChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final service = ref.read(agentServiceProvider);
    ref.read(agentInboxProvider).value ?? AgentInbox.empty();

    // Add user message
    final userMsg = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isFromAgent: false,
    );
    await service.saveMessage(userMsg);

    // Clear input
    _textController.clear();

    // Get agent response
    final response = await service.sendMessage(text);
    final agentMsg = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: response,
      isFromAgent: true,
    );
    await service.saveMessage(agentMsg);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(agentInboxProvider);
    final mood = ref.watch(agentMoodProvider);
    final theme = AgentTheme.of(context, mood);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tru Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Open agent settings
            },
          ),
        ],
      ),
      body: inboxAsync.when(
        data: (inbox) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: inbox.messages.length,
                itemBuilder: (context, index) {
                  final msg = inbox.messages[index];
                  return _ChatBubble(
                    message: msg,
                    theme: theme,
                  );
                },
              ),
            ),
            _Composer(
              controller: _textController,
              onSend: _sendMessage,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AgentMessage message;
  final AgentTheme theme;

  const _ChatBubble({
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = message.isFromAgent ? Alignment.centerLeft : Alignment.centerRight;
    final color = message.isFromAgent ? theme.surface : theme.primary;
    final textColor = message.isFromAgent ? theme.text : Colors.white;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

