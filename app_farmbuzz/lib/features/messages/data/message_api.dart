import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MessageApi {
  MessageApi();

  static String get _baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    if (Platform.isAndroid) return 'http://167.172.89.188:8083/api';
    return 'http://167.172.89.188:8083/api';
  }

  Future<List<Map<String, dynamic>>> getConversations({required String mobileNumber}) async {
    final uri = Uri.parse('$_baseUrl/messages').replace(queryParameters: {
      'mobile_number': mobileNumber,
    });
    final response = await http.get(uri);

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw MessageApiException(data['message'] ?? 'Failed to load conversations.');
    }

    return (data['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getMessages({
    required String mobileNumber,
    required int conversationId,
  }) async {
    final uri = Uri.parse('$_baseUrl/messages/history').replace(queryParameters: {
      'mobile_number': mobileNumber,
      'conversation_id': conversationId.toString(),
    });
    final response = await http.get(uri);

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw MessageApiException(data['message'] ?? 'Failed to load messages.');
    }

    return (data['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<int> startConversation({
    required String mobileNumber,
    required String targetName,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/messages/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'target_name': targetName,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw MessageApiException(data['message'] ?? 'Failed to start conversation.');
    }

    return data['data']['id'] as int;
  }

  Future<Map<String, dynamic>> sendMessage({
    required String mobileNumber,
    required int conversationId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/messages/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'conversation_id': conversationId,
        'content': content,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw MessageApiException(data['message'] ?? 'Failed to send message.');
    }

    return data['data'] as Map<String, dynamic>;
  }
}

class MessageApiException implements Exception {
  const MessageApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
