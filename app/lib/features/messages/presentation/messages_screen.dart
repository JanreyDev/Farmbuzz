import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'conversation_screen.dart';
import '../data/message_api.dart';
import 'user_search_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageApi _api = MessageApi();
  List<ConversationModel>? _conversations;
  bool _isLoading = true;
  String? _mobile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _mobile =
          prefs.getString('auth_mobile_number') ??
          prefs.getString('mobile_number');
      if (_mobile != null && _mobile!.isNotEmpty) {
        final data = await _api.fetchConversations(mobileNumber: _mobile!);
        if (mounted) {
          setState(() {
            _conversations = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return 'now';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh, color: Color(0xFF16A34A)),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserSearchScreen()),
              );
              _load();
            },
            icon: const Icon(Icons.edit_note, color: Color(0xFF16A34A)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.black87),
                  cursorColor: Colors.black87,
                  decoration: InputDecoration(
                    hintText: 'Search chats and messages...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                  )
                : (_conversations == null || _conversations!.isEmpty)
                ? const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _conversations!.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final c = _conversations![index];
                      final initial = c.otherUserName.isNotEmpty
                          ? c.otherUserName[0].toUpperCase()
                          : 'U';
                      return InkWell(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  ConversationScreen(conversation: c),
                            ),
                          );
                          _load(); // reload when back
                        },
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFE5E7EB),
                                backgroundImage: c.otherUserAvatar.isNotEmpty
                                    ? NetworkImage(c.otherUserAvatar)
                                    : null,
                                child: c.otherUserAvatar.isEmpty
                                    ? Text(
                                        initial,
                                        style: const TextStyle(
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.otherUserName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      c.lastMessage.isEmpty
                                          ? 'Tap to start chatting'
                                          : c.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: c.isUnread
                                            ? Colors.black87
                                            : const Color(0xFF6B7280),
                                        fontWeight: c.isUnread
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatTime(c.lastMessageTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (c.isUnread)
                                    const CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Color(0xFF16A34A),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
