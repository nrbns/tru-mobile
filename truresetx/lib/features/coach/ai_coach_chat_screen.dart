import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_message.dart';
import '../../core/services/ai_service.dart';
// removed unused import: realtime_service

/// AI Coach Chat Screen with real-time messaging
class AICoachChatScreen extends ConsumerStatefulWidget {
  const AICoachChatScreen({
    super.key,
    this.initialPersona,
  });
  final String? initialPersona;

  @override
  ConsumerState<AICoachChatScreen> createState() => _AICoachChatScreenState();
}

class _AICoachChatScreenState extends ConsumerState<AICoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String _selectedPersona = 'general';
  bool _isTyping = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _personas = [
    {
      'id': 'general',
      'name': 'AI Assistant',
      'emoji': '🤖',
      'description': 'Your general wellness assistant',
      'color': Colors.blue,
    },
    {
      'id': 'astra',
      'name': 'Astra',
      'emoji': '💪',
      'description': 'Your fitness and wellness coach',
      'color': Colors.green,
    },
    {
      'id': 'sage',
      'name': 'Sage',
      'emoji': '🧘',
      'description': 'Your mindfulness mentor',
      'color': Colors.purple,
    },
    {
      'id': 'fuel',
      'name': 'Fuel',
      'emoji': '🍎',
      'description': 'Your nutrition expert',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPersona = widget.initialPersona ?? 'general';
    _loadChatHistory();
    _sendWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    // Load chat history from local storage or database
    // For now, we'll start with an empty chat
    setState(() {
      _isLoading = false;
    });
  }

  void _sendWelcomeMessage() {
    final welcomeMessage = ChatMessage.create(
      userId: 'current_user',
      role: 'assistant',
      message: _getWelcomeMessage(_selectedPersona),
      persona: _selectedPersona,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  String _getWelcomeMessage(String persona) {
    switch (persona) {
      case 'astra':
        return 'Hi! I\'m Astra, your fitness coach 💪\n\nI\'m here to help you with workouts, form guidance, and achieving your fitness goals. What would you like to work on today?';
      case 'sage':
        return 'Hello! I\'m Sage, your mindfulness mentor 🧘\n\nI can help you with meditation, stress management, and mental wellness. How are you feeling today?';
      case 'fuel':
        return 'Hey there! I\'m Fuel, your nutrition expert 🍎\n\nI\'m here to help you with meal planning, nutrition tracking, and healthy eating habits. What\'s on your mind?';
      default:
        return 'Hello! I\'m your AI wellness assistant 🤖\n\nI can help you with fitness, nutrition, mindfulness, and overall wellness. How can I assist you today?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_getCurrentPersona()['emoji']),
            const SizedBox(width: 8),
            Text(_getCurrentPersona()['name']),
          ],
        ),
        backgroundColor:
            _getCurrentPersona()['color'].withAlpha((0.1 * 255).round()),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _changePersona,
            itemBuilder: (context) => _personas.map((persona) {
              return PopupMenuItem<String>(
                value: persona['id'],
                child: Row(
                  children: [
                    Text(persona['emoji']),
                    const SizedBox(width: 8),
                    Text(persona['name']),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Persona Info
          _buildPersonaInfo(),

          // Messages
          Expanded(
            child: _buildMessagesList(),
          ),

          // Typing Indicator
          if (_isTyping) _buildTypingIndicator(),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildPersonaInfo() {
    final persona = _getCurrentPersona();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: persona['color'].withAlpha((0.1 * 255).round()),
        border: Border(
          bottom: BorderSide(
            color: persona['color'].withAlpha((0.3 * 255).round()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            persona['emoji'],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  persona['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  persona['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Start a conversation with your AI coach!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final persona = _getCurrentPersona();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: persona['color'].withAlpha((0.2 * 255).round()),
              child: Text(
                persona['emoji'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? persona['color'] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.timeDisplayText,
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: persona['color'].withAlpha((0.2 * 255).round()),
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                _getCurrentPersona()['color'].withAlpha((0.2 * 255).round()),
            child: Text(
              _getCurrentPersona()['emoji'],
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: (Colors.grey[400] ?? Colors.grey)
                .withAlpha((value * 255).round()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: _getCurrentPersona()['color'],
            mini: true,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCurrentPersona() {
    return _personas.firstWhere((p) => p['id'] == _selectedPersona);
  }

  void _changePersona(String personaId) {
    if (personaId != _selectedPersona) {
      setState(() {
        _selectedPersona = personaId;
      });

      // Send persona change message
      final persona = _personas.firstWhere((p) => p['id'] == personaId);
      final changeMessage = ChatMessage.create(
        userId: 'current_user',
        role: 'assistant',
        message: 'Switched to ${persona['name']} - ${persona['description']}',
        persona: personaId,
      );

      setState(() {
        _messages.add(changeMessage);
      });

      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    // Add user message
    final userMessage = ChatMessage.create(
      userId: 'current_user',
      role: 'user',
      message: messageText,
      persona: _selectedPersona,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get AI response
      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.chatCompletion(
        _buildPrompt(messageText),
        model: 'gpt-4',
        temperature: 0.7,
      );

      // Add AI response
      final aiMessage = ChatMessage.create(
        userId: 'current_user',
        role: 'assistant',
        message: response,
        persona: _selectedPersona,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      // Handle error
      final errorMessage = ChatMessage.create(
        userId: 'current_user',
        role: 'assistant',
        message: 'I apologize, but I encountered an error. Please try again.',
        persona: _selectedPersona,
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
        _isTyping = false;
      });

      _scrollToBottom();
    }
  }

  String _buildPrompt(String userMessage) {
    final persona = _getCurrentPersona();
    final personaName = persona['name'];
    final personaDescription = persona['description'];

    return '''
You are $personaName, $personaDescription.

Context: You are part of the TruResetX wellness platform, helping users with their holistic wellness journey.

User Message: $userMessage

Please respond as $personaName would, staying true to your persona and providing helpful, supportive guidance. Keep responses conversational and engaging.
''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
