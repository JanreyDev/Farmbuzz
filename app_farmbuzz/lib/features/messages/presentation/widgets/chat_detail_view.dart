import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'message_bubble.dart';
import 'chat_mock_data.dart';

/// A premium, interactive chat detail view.
/// Supports real-time message sending simulation and threaded conversations.
class ChatDetailView extends StatefulWidget {
  const ChatDetailView({
    super.key,
    required this.chatId,
    this.onBack,
  });

  final String chatId;
  final VoidCallback? onBack;

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> _messages;
  late ChatPreview _chatPreview;

  @override
  void initState() {
    super.initState();
    _chatPreview = mockChats.isNotEmpty
        ? mockChats.firstWhere(
            (c) => c.id == widget.chatId,
            orElse: () => mockChats.first,
          )
        : ChatPreview(
            id: widget.chatId,
            name: 'Chat',
            lastMessage: '',
            time: '',
            avatarUrl: '',
            type: 'Direct',
          );
    // Create a local copy of messages to allow mutations
    _messages = List<ChatMessage>.from(mockConversations[widget.chatId] ?? []);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: _getCurrentTime(),
      ));
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate a simple automated response for "interactivity"
    _simulateResponse(text);
  }

  void _simulateResponse(String userText) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      String response = "Got it! Let me check on that.";
      if (userText.toLowerCase().contains('hi') || userText.toLowerCase().contains('hello')) {
        response = "Hello! How can I help you today?";
      } else if (userText.toLowerCase().contains('price') || userText.toLowerCase().contains('magkano')) {
        response = "I'll send the price list in a moment. Hold on!";
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isMe: false,
          time: _getCurrentTime(),
        ));
      });
      _scrollToBottom();
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (widget.onBack != null)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: widget.onBack,
              ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[100],
              backgroundImage: _chatPreview.avatarUrl.trim().isNotEmpty
                  ? NetworkImage(_chatPreview.avatarUrl)
                  : null,
              child: _chatPreview.avatarUrl.trim().isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chatPreview.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Online',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _HeaderIcon(icon: Icons.videocam_outlined),
            const SizedBox(width: 8),
            _HeaderIcon(icon: Icons.phone_outlined),
            const SizedBox(width: 8),
            _HeaderIcon(icon: Icons.more_vert),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MessageBubble(
            message: msg.text,
            isMe: msg.isMe,
            time: msg.time,
            isEmoji: msg.isEmoji,
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const _InputIconButton(icon: Icons.add_circle_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _sendMessage(),
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.grey[700], size: 22);
  }
}

class _InputIconButton extends StatelessWidget {
  const _InputIconButton({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.grey[600], size: 24);
  }
}
