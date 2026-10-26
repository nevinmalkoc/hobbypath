import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';
import 'starter_gear_screen.dart';
import 'daily_puzzle_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  final String? initialHobby;

  const AiAssistantScreen({super.key, this.initialHobby});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiMessageItem {
  final String sender; // 'user' or 'ai'
  final String text;
  final List<String> suggestions;
  final String? category;
  final DateTime time;

  _AiMessageItem({
    required this.sender,
    required this.text,
    this.suggestions = const [],
    this.category,
    required this.time,
  });
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_AiMessageItem> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '🐎 Binicilik için minimum ne gerekli?',
    '🏺 Seramik tornasında kili nasıl merkezlerim?',
    '🏃 5K koşu başlangıç antrenman planı',
    '📸 Bokeh etkisi ve pozlama üçgeni',
    '🍳 Taze el yapımı makarna tüyoları',
    '🌲 Doğa yürüyüşü katmanlı giyim rehberi',
  ];

  @override
  void initState() {
    super.initState();
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    _messages.add(
      _AiMessageItem(
        sender: 'ai',
        text: 'Merhaba Hobi Dostu! 👋 Ben senin kişisel HobbyPath AI Koçunum.\n\n'
            'Binicilikten seramiğe, koşudan fotoğrafçılığa kadar başlangıç ekipmanları, '
            'teknikler ve antrenman rehberleri konusunda sana yardımcı olmak için buradayım. '
            'Aşağıdaki önerilerden birini seçebilir veya aklındaki soruyu yazabilirsin!',
        suggestions: [
          'Binicilik için minimum ne gerekli?',
          '5K koşu başlangıç planı',
          'Kili nasıl merkezlerim?',
        ],
        category: 'Genel',
        time: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        _AiMessageItem(
          sender: 'user',
          text: query,
          time: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await ApiClient().dio.post(
        '/ai/chat',
        data: {
          'message': query,
          'hobby': widget.initialHobby,
        },
      );

      final aiRes = AiChatModel.fromJson(response.data as Map<String, dynamic>);

      if (mounted) {
        setState(() {
          _messages.add(
            _AiMessageItem(
              sender: 'ai',
              text: aiRes.reply,
              suggestions: aiRes.suggestions,
              category: aiRes.category,
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            _AiMessageItem(
              sender: 'ai',
              text: 'Bağlantı hatası oluştu. Lütfen tekrar deneyin.',
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
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

  Widget _buildMessageBubble(_AiMessageItem msg) {
    final isUser = msg.sender == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: const Text('🤖', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.deepOrange : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser && msg.category != null && msg.category != 'Genel')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              msg.category!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                        ),
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isUser ? Colors.white : Colors.black87,
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
                  backgroundColor: Colors.blue.shade100,
                  child: const Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),

          // Suggestion Chips
          if (!isUser && msg.suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.suggestions.map((sug) {
                  return ActionChip(
                    avatar: const Icon(Icons.arrow_forward, size: 12, color: Colors.deepOrange),
                    label: Text(sug, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.deepOrange.shade200),
                    onPressed: () => _sendMessage(sug),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🤖 HobbyPath AI'),
            SizedBox(width: 6),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text('Koç & Rehber', style: TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Colors.deepOrange,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backpack_outlined),
            tooltip: 'Acemi Çantası',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StarterGearScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videogame_asset_outlined),
            tooltip: 'Hobi Oyunları',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyPuzzleScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Prompts Banner
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final prompt = _quickPrompts[i];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Message Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i]),
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'HobbyPath AI yanıt hazırlıyor...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

          // Bottom Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Bir hobi sorusu sorun...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                    onPressed: () => _sendMessage(_textController.text),
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
