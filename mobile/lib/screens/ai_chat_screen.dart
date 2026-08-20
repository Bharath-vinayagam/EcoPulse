import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smart_expense_co2/services/api_service.dart';
import 'package:smart_expense_co2/utils/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Hello! I am EcoPulse AI ⚡🌱 your personal Carbon & Sustainability Assistant. How can I help optimize your carbon footprint today?'
    }
  ];
  bool _isSending = false;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isSending = true;
    });
    _msgCtrl.clear();

    final reply = await apiService.sendChatMessage(text);

    if (mounted) {
      setState(() {
        _isSending = false;
        _messages.add({
          'sender': 'bot',
          'text': reply ?? 'Analyzing your carbon emissions profile. Try asking about transport savings or food impact!'
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentCyan, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EcoPulse AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Real-time Carbon Intelligence', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildQuickPrompts(isDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isUser = msg['sender'] == 'user';

                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        gradient: isUser ? AppTheme.greenGradient : null,
                        color: isUser
                            ? null
                            : isDark
                                ? AppTheme.cardDark
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 20),
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                          color: isUser
                              ? Colors.white
                              : isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSending)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
                  const SizedBox(width: 8),
                  Text('GreenBot is calculating advice...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts(bool isDark) {
    final prompts = [
      '🚗 Lower Transport CO₂',
      '🥗 Food Carbon Savings',
      '🎯 Quest XP Status',
      '💡 Energy Tips',
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final prompt = prompts[idx];
          return ActionChip(
            label: Text(prompt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
            side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        boxShadow: AppTheme.cardShadow,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                decoration: InputDecoration(
                  hintText: 'Ask GreenBot AI...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  filled: true,
                  fillColor: isDark ? AppTheme.bgDark : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.greenGradient,
                boxShadow: AppTheme.emeraldGlow,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(_msgCtrl.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
