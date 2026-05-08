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

final List<ChatPreview> mockChats = [
  ChatPreview(
    id: '1',
    name: 'Chelsy De Leon',
    lastMessage: 'ostrich egg sana sir sayangg...',
    time: '1d',
    avatarUrl: 'https://i.pravatar.cc/150?u=chelsy',
    type: 'Direct',
    isUnread: true,
  ),
  ChatPreview(
    id: '2',
    name: 'Ostrich Lovers PH',
    lastMessage: 'Admin: New breeding guidelines posted!',
    time: '2h',
    avatarUrl: 'https://i.pravatar.cc/150?u=club1',
    type: 'Club',
  ),
  ChatPreview(
    id: '3',
    name: 'Juan Dela Cruz',
    lastMessage: 'Magkano po yung premium feeds?',
    time: '5h',
    avatarUrl: 'https://i.pravatar.cc/150?u=juan',
    type: 'Direct',
    isUnread: true,
  ),
  ChatPreview(
    id: '4',
    name: 'Maria Clara',
    lastMessage: 'Sige po, send ko yung photos later.',
    time: '1d',
    avatarUrl: 'https://i.pravatar.cc/150?u=maria',
    type: 'Direct',
  ),
  ChatPreview(
    id: '5',
    name: 'Poultry Experts',
    lastMessage: 'Doc: Check the vaccination schedule.',
    time: '3d',
    avatarUrl: 'https://i.pravatar.cc/150?u=club2',
    type: 'Club',
  ),
  ChatPreview(
    id: '6',
    name: 'Rico Blanco',
    lastMessage: 'Available pa ba yung incubated eggs?',
    time: '4d',
    avatarUrl: 'https://i.pravatar.cc/150?u=rico',
    type: 'Direct',
  ),
];

final Map<String, List<ChatMessage>> mockConversations = {
  '1': [
    ChatMessage(text: 'okay okay I think bug sya palist nalng po maam thank you', isMe: true, time: '3:45 PM'),
    ChatMessage(text: 'sige po sir noted po', isMe: false, time: '3:47 PM'),
    ChatMessage(text: '😊', isMe: true, time: '3:48 PM', isEmoji: true),
    ChatMessage(text: 'sir triny namin manudo may quail egg pala hahahahaha', isMe: false, time: '3:49 PM'),
    ChatMessage(text: 'ahaha mahirap nyan dragon yan egg maam', isMe: true, time: '3:50 PM'),
    ChatMessage(text: 'ostrich egg sana sir sayangg...', isMe: false, time: '3:51 PM'),
  ],
  '3': [
    ChatMessage(text: 'Hi Juan, available pa yung feeds?', isMe: true, time: '10:00 AM'),
    ChatMessage(text: 'Yes sir, ilan sako po kailangan nyo?', isMe: false, time: '10:05 AM'),
    ChatMessage(text: 'Magkano po yung premium feeds?', isMe: false, time: '10:06 AM'),
  ],
};
