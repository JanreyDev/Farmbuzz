import 'package:flutter/material.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'message_bubble.dart';
import 'chat_mock_data.dart';

class ChatDetailView extends StatelessWidget {
  final String chatId;
  final VoidCallback? onBack;

  const ChatDetailView({
    super.key,
    required this.chatId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final chatPreview = mockChats.firstWhere((c) => c.id == chatId, orElse: () => mockChats.first);
    final messages = mockConversations[chatId] ?? [];

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(chatPreview.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatPreview.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      chatPreview.type == 'Club' ? 'Active Club' : '@${chatPreview.name.toLowerCase().replaceAll(' ', '')}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ),
        
        // Reconnecting Bar (Optional, from image)
        if (chatId == '1') // Just for demonstration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: const Color(0xFFFEF3C7),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                ),
                SizedBox(width: 8),
                Text(
                  'Reconnecting...',
                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

        // Message List
        Expanded(
          child: Container(
            color: Colors.white,
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        message: msg.text,
                        isMe: msg.isMe,
                        time: msg.time,
                        isEmoji: msg.isEmoji,
                      );
                    },
                  ),
          ),
        ),

        // Input Field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.mic_none, color: Colors.grey),
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Message ${chatPreview.name}...',
                      border: InputBorder.none,
                      hintStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.accentGreen),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
