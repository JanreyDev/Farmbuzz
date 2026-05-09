import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:farmbuzz/core/session/app_session.dart';

class PostApi {
  PostApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String get _baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    if (Platform.isAndroid) {
      return 'http://167.172.89.188:8083/api';
    }

    return 'http://167.172.89.188:8083/api';
  }

  Future<List<Map<String, dynamic>>> getPosts({
    String? reactorName,
    String? authorName,
  }) async {
    final reactor = reactorName ?? AppSession.userName;
    final queryParams = <String, String>{'reactor_name': reactor};
    final author = authorName?.trim() ?? '';
    if (author.isNotEmpty) {
      queryParams['author_name'] = author;
    }

    final uri = Uri.parse(
      '$_baseUrl/posts',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(uri);

    if (response.statusCode >= 400) {
      throw PostApiException('Failed to load posts.');
    }

    final decoded = _decode(response.body);
    final list = decoded['data'];

    if (list is! List) {
      return [];
    }

    return list.whereType<Map<String, dynamic>>().map(_normalizePost).toList();
  }

  Future<Map<String, dynamic>> createPost({
    required String authorName,
    required String authorAvatar,
    required String content,
    required List<String> imagePaths,
  }) async {
    final response = await _postJson('/posts', {
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'content': content,
      'image_paths': imagePaths,
    });

    final decoded = _decode(response.body);

    if (response.statusCode != 201) {
      throw PostApiException(
        _extractMessage(decoded, fallback: 'Failed to create post.'),
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const PostApiException('Invalid response from server.');
    }

    return _normalizePost(data);
  }

  Future<Map<String, dynamic>> likePost({
    required int postId,
    required String reactorName,
    required String reaction,
  }) async {
    final response = await _postJson('/posts/$postId/like', {
      'reactor_name': reactorName,
      'reaction': reaction,
    });
    final decoded = _decode(response.body);

    if (response.statusCode >= 400) {
      throw PostApiException(
        _extractMessage(decoded, fallback: 'Failed to like post.'),
      );
    }

    return {
      'likesCount': (decoded['likesCount'] ?? '0').toString(),
      'userReaction': decoded['userReaction']?.toString(),
      'topReactions': _coerceTopReactions(decoded['topReactions']),
    };
  }

  Future<Map<String, dynamic>> unlikePost({
    required int postId,
    required String reactorName,
  }) async {
    final response = await _postJson('/posts/$postId/unlike', {
      'reactor_name': reactorName,
    });
    final decoded = _decode(response.body);

    if (response.statusCode >= 400) {
      throw PostApiException(
        _extractMessage(decoded, fallback: 'Failed to unlike post.'),
      );
    }

    return {
      'likesCount': (decoded['likesCount'] ?? '0').toString(),
      'userReaction': decoded['userReaction']?.toString(),
      'topReactions': _coerceTopReactions(decoded['topReactions']),
    };
  }

  Future<List<Map<String, dynamic>>> getComments(int postId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/posts/$postId/comments'),
    );

    if (response.statusCode >= 400) {
      throw const PostApiException('Failed to load comments.');
    }

    final decoded = _decode(response.body);
    final list = decoded['data'];

    if (list is! List) {
      return [];
    }

    return list.whereType<Map<String, dynamic>>().map((item) {
      return {
        'id': item['id'],
        'name': (item['name'] ?? '').toString(),
        'avatar':
            (item['avatar'] ?? 'https://i.pravatar.cc/150?u=farmbuzz-comment')
                .toString(),
        'text': (item['text'] ?? '').toString(),
        'time': (item['time'] ?? 'now').toString(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>> addComment({
    required int postId,
    required String authorName,
    required String authorAvatar,
    required String content,
  }) async {
    final response = await _postJson('/posts/$postId/comments', {
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'content': content,
    });

    final decoded = _decode(response.body);

    if (response.statusCode != 201) {
      throw PostApiException(
        _extractMessage(decoded, fallback: 'Failed to add comment.'),
      );
    }

    return {
      'comment': decoded['comment'],
      'commentsCount': (decoded['commentsCount'] ?? '0').toString(),
    };
  }

  Future<http.Response> _postJson(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } on SocketException catch (error) {
      throw PostApiException('Network error: $error. API URL: $_baseUrl');
    } on http.ClientException catch (error) {
      throw PostApiException(
        'HTTP client error: ${error.message}. API URL: $_baseUrl',
      );
    }
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static String _extractMessage(
    Map<String, dynamic> data, {
    required String fallback,
  }) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final errors = data['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          return value.first as String;
        }
      }
    }

    return fallback;
  }

  static Map<String, dynamic> _normalizePost(Map<String, dynamic> item) {
    final paths = item['localImagePaths'] ?? item['image_paths'];
    final localImagePaths = paths is List
        ? paths.whereType<String>().toList()
        : <String>[];

    return <String, dynamic>{
      'id': item['id'],
      'userName': (item['userName'] ?? item['author_name'] ?? 'Unknown')
          .toString(),
      'userAvatar': (item['userAvatar'] ?? item['author_avatar'] ?? '')
          .toString(),
      'timeAgo': (item['timeAgo'] ?? 'Just now').toString(),
      'postText': (item['postText'] ?? item['content'] ?? '').toString(),
      'postImageUrl': item['postImageUrl'],
      'localImagePaths': localImagePaths,
      'likesCount': (item['likesCount'] ?? '0').toString(),
      'commentsCount': (item['commentsCount'] ?? '0').toString(),
      'userReaction': item['userReaction']?.toString(),
      'topReactions': _coerceTopReactions(item['topReactions']),
    };
  }

  static List<String> _coerceTopReactions(dynamic value) {
    if (value is! List) {
      return <String>[];
    }
    return value.whereType<String>().take(3).toList();
  }
}

class PostApiException implements Exception {
  const PostApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
