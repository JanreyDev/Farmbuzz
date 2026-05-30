import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';

class ConversationModel {
  ConversationModel({
    required this.id,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isUnread,
  });

  final int id;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final String lastMessageTime;
  final bool isUnread;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      otherUserName: (json['other_user_name'] as String?) ?? 'User',
      otherUserAvatar: (json['other_user_avatar'] as String?) ?? '',
      lastMessage: (json['last_message'] as String?) ?? '',
      lastMessageTime: (json['last_message_time'] as String?) ?? '',
      isUnread: (json['is_unread'] as bool?) ?? false,
    );
  }
}

class ChatMessageModel {
  ChatMessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.isMe,
    required this.time,
  });

  final int id;
  final String content;
  final int senderId;
  final bool isMe;
  final String time;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      content: (json['content'] as String?) ?? '',
      senderId: (json['sender_id'] as num?)?.toInt() ?? 0,
      isMe: (json['is_me'] as bool?) ?? false,
      time: (json['time'] as String?) ?? '',
    );
  }
}

class MessageApi {
  MessageApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<List<ConversationModel>> fetchConversations({
    required String mobileNumber,
  }) async {
    final uri = _buildUri(
      '/messages',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List?;
      return (list ?? [])
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch conversations');
  }

  Future<List<ChatMessageModel>> fetchHistory({
    required String mobileNumber,
    required int conversationId,
  }) async {
    final uri = _buildUri('/messages/history').replace(
      queryParameters: {
        'mobile_number': mobileNumber,
        'conversation_id': conversationId.toString(),
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List?;
      return (list ?? [])
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch messages');
  }

  Future<int> startConversation({
    required String mobileNumber,
    required String targetName,
  }) async {
    final uri = _buildUri('/messages/start');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'target_name': targetName,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['data']['id'] as int;
    }
    throw Exception('Failed to start conversation');
  }

  Future<ChatMessageModel> sendMessage({
    required String mobileNumber,
    required int conversationId,
    required String content,
  }) async {
    final uri = _buildUri('/messages/send');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'conversation_id': conversationId,
        'content': content,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ChatMessageModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to send message');
  }
}
