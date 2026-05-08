import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/core/session/app_session.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class BantayAiView extends StatefulWidget {
  const BantayAiView({super.key});

  @override
  State<BantayAiView> createState() => _BantayAiViewState();
}

class _BantayAiViewState extends State<BantayAiView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Haha, kamusta ${AppSession.userName}! 😊 Mukhang may sinasabi ka? Andito lang ako kung may tanong ka about sa farm mo, sa mga birds, o sa FarmBuzz. Ano'ng maitutulong ko sa'yo today?",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
    _scrollToBottom();
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

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChatHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _AiHeader(onHistoryTap: () => _showHistory(context)),
          Expanded(
            child: _messages.isEmpty 
              ? _buildWelcomeScreen()
              : _buildConversationView(),
          ),
          _AiInputSection(
            controller: _textController,
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const _AiHeroAvatar(),
          const SizedBox(height: 24),
          Text(
            'Magandang araw, ${AppSession.userName}!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Your private farm assistant. Ask about flock health, breeding, feed, weather, or how to use FarmBuzz. Pick a starter below or type your own.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _PromptGrid(onPromptTap: _handleSubmitted),
          const SizedBox(height: 40),
          Text(
            'Bantay gives farm guidance, not veterinary prescriptions. For a seriously sick bird, call your local vet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConversationView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _ChatBubble(message: message);
      },
    );
  }
}

class _ChatHistorySheet extends StatelessWidget {
  const _ChatHistorySheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Text(
                  'Chat history',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
                  icon: Icon(Icons.search_rounded, size: 20, color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chat List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _HistoryItem(title: 'adad', count: 2, isActive: true),
                _HistoryItem(title: 'Is Test thunder healthy?', count: 2),
                _HistoryItem(title: 'Weight targets by age', count: 2),
                _HistoryItem(title: 'Improve hatch rate', count: 2),
                _HistoryItem(title: 'Conditioning feed for Test thunder', count: 2),
                _HistoryItem(title: 'where can i see the list of my bird?', count: 8),
              ],
            ),
          ),

          // Plan Banner
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlimited Plan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Unlimited - 9 today - ₱5.52 today',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final int count;
  final bool isActive;

  const _HistoryItem({
    required this.title,
    required this.count,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFFBEB) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          Icons.chat_bubble_outline_rounded,
          size: 20,
          color: isActive ? const Color(0xFFD97706) : Colors.grey[400],
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$count msg',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        trailing: Icon(Icons.edit_outlined, size: 16, color: Colors.grey[300]),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.aiAmberBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security_rounded, size: 14, color: AppColors.aiAmberIcon),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.premiumGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                border: message.isUser ? null : Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  if (!message.isUser)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: message.isUser ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 32),
          if (!message.isUser) const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  final VoidCallback onHistoryTap;

  const _AiHeader({required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.aiAmberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security_rounded, color: AppColors.aiAmberIcon, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bantay AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Your personal farm assistant',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.aiGreenText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onHistoryTap,
            icon: const Icon(Icons.history_rounded, size: 20, color: Colors.grey),
            tooltip: 'History',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            tooltip: 'New Chat',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiHeroAvatar extends StatelessWidget {
  const _AiHeroAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.aiAmberBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.aiAmberIcon.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.security_rounded, size: 40, color: AppColors.aiAmberIcon),
      ),
    );
  }
}

class _PromptGrid extends StatelessWidget {
  final Function(String) onPromptTap;

  const _PromptGrid({required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _PromptCard(
          icon: Icons.monitor_heart_outlined,
          title: 'Is Test thunder healthy?',
          subtitle: 'Red flags to watch + what to do next',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          onTap: () => onPromptTap('Is Test thunder healthy?'),
        ),
        _PromptCard(
          icon: Icons.medication_outlined,
          title: 'Build a vaccine schedule',
          subtitle: 'Newcastle, pox, coryza — timed for my region',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          onTap: () => onPromptTap('Build a vaccine schedule'),
        ),
        _PromptCard(
          icon: Icons.grass_outlined,
          title: 'Conditioning feed for Test thunder',
          subtitle: '21-day program, ingredients + ratios',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          onTap: () => onPromptTap('Conditioning feed for Test thunder'),
        ),
        _PromptCard(
          icon: Icons.egg_outlined,
          title: 'Improve hatch rate',
          subtitle: 'Fertility + incubation troubleshooting',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          isActive: true,
          onTap: () => onPromptTap('Improve hatch rate'),
        ),
        _PromptCard(
          icon: Icons.thermostat_outlined,
          title: 'Prep for this week\'s weather',
          subtitle: 'Electrolytes, shade, pen changes',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          onTap: () => onPromptTap('Prep for this week\'s weather'),
        ),
        _PromptCard(
          icon: Icons.scale_outlined,
          title: 'Weight targets by age',
          subtitle: 'Weekly milestones, per flock line',
          iconColor: AppColors.aiAmberText,
          bgColor: AppColors.aiAmberBg,
          onTap: () => onPromptTap('Weight targets by age'),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color bgColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFFFCD34D) : Colors.grey[200]!,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiInputSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const _AiInputSection({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // Tight alignment for integrated menu
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.image_outlined, color: Colors.grey[400]),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Ask Bantay anything about your farm...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.premiumGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => onSubmitted(controller.text),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
