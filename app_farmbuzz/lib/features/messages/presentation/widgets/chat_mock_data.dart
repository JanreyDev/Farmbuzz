class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isEmoji;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isEmoji = false,
  });
}

class ChatPreview {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final String type; // 'Direct', 'Club'
  final bool isUnread;

  ChatPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.type,
    this.isUnread = false,
  });
}

final List<ChatPreview> mockChats = [];

final Map<String, List<ChatMessage>> mockConversations = {};
