import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/network/api_config.dart';

class FeedImageUpload {
  FeedImageUpload({
    this.path,
    this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final String? path;
  final List<int>? bytes;
  final String fileName;
  final MediaType contentType;
}

class FeedPost {
  FeedPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.postText,
    required this.metaEmoji,
    required this.metaFeeling,
    required this.metaLocation,
    required this.likesCount,
    required this.commentsCount,
    required this.topReactions,
    required this.imageUrls,
  });

  final int id;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String postText;
  final String metaEmoji;
  final String metaFeeling;
  final String metaLocation;
  final int likesCount;
  final int commentsCount;
  final List<String> topReactions;
  final List<String> imageUrls;

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName: (json['userName'] as String?) ?? 'FarmBuzz User',
      userAvatar: (json['userAvatar'] as String?) ?? '',
      timeAgo: (json['timeAgo'] as String?) ?? 'Just now',
      postText: (json['postText'] as String?) ?? '',
      metaEmoji: (json['metaEmoji'] as String?) ?? '',
      metaFeeling: (json['metaFeeling'] as String?) ?? '',
      metaLocation: (json['metaLocation'] as String?) ?? '',
      likesCount: int.tryParse('${json['likesCount'] ?? 0}') ?? 0,
      commentsCount: int.tryParse('${json['commentsCount'] ?? 0}') ?? 0,
      topReactions: ((json['topReactions'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      imageUrls: ((json['imageUrls'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

class FeedApi {
  FeedApi({http.Client? client}) : _client = client ?? http.Client();

  static const int _maxBase64RetryBytes = 8 * 1024 * 1024; // 8MB raw bytes
  final http.Client _client;

  Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<List<FeedPost>> fetchPosts() async {
    final response = await _client.get(
      _buildUri('/posts'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch posts.');
    }

    final decoded = jsonDecode(response.body);
    final data =
        (decoded is Map<String, dynamic> ? decoded['data'] : null) as List?;
    if (data == null) return <FeedPost>[];

    return data
        .whereType<Map>()
        .map((e) => FeedPost.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FeedPost> createPost({
    required String authorName,
    required String content,
    required List<FeedImageUpload> images,
    String? metaFeeling,
    String? metaLocation,
    String? authorAvatar,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri('/posts'));
    request.headers['Accept'] = 'application/json';
    request.fields['author_name'] = authorName;
    request.fields['content'] = content;
    if (metaFeeling != null && metaFeeling.trim().isNotEmpty) {
      request.fields['meta_feeling'] = metaFeeling.trim();
    }
    if (metaLocation != null && metaLocation.trim().isNotEmpty) {
      request.fields['meta_location'] = metaLocation.trim();
    }
    if (authorAvatar != null && authorAvatar.trim().isNotEmpty) {
      request.fields['author_avatar'] = authorAvatar.trim();
    }

    for (final image in images) {
      final bytes = image.bytes;
      if (bytes != null && bytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[]',
            bytes,
            filename: image.fileName,
            contentType: image.contentType,
          ),
        );
        continue;
      }

      final path = image.path;
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]',
          path,
          filename: image.fileName,
          contentType: image.contentType,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? message;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final raw = decoded['message'];
          if (raw is String && raw.trim().isNotEmpty) {
            message = raw.trim();
          }
          final errors = decoded['errors'];
          if (message == null && errors is Map) {
            for (final value in errors.values) {
              if (value is List && value.isNotEmpty && value.first is String) {
                message = (value.first as String).trim();
                break;
              }
            }
          }
        }
      } catch (_) {}
      final shouldRetryBase64 =
          images.isNotEmpty &&
          message != null &&
          message.toLowerCase().contains('failed to upload') &&
          _estimateTotalBytes(images) <= _maxBase64RetryBytes;
      if (shouldRetryBase64) {
        return _createPostWithBase64(
          authorName: authorName,
          content: content,
          images: images,
          metaFeeling: metaFeeling,
          metaLocation: metaLocation,
          authorAvatar: authorAvatar,
        );
      }
      if (message != null) {
        if (message.toLowerCase().contains('post data is too large')) {
          throw Exception(
            'Selected images are too large. Please upload fewer or smaller photos.',
          );
        }
        throw Exception(message);
      }
      throw Exception('Failed to create post.');
    }

    final decoded = jsonDecode(response.body);
    final data = (decoded is Map<String, dynamic> ? decoded['data'] : null);
    if (data is Map<String, dynamic>) {
      return FeedPost.fromJson(data);
    }

    throw Exception('Invalid post response.');
  }

  Future<FeedPost> _createPostWithBase64({
    required String authorName,
    required String content,
    required List<FeedImageUpload> images,
    String? metaFeeling,
    String? metaLocation,
    String? authorAvatar,
  }) async {
    final payloads = <String>[];
    for (final image in images) {
      final bytes = image.bytes ?? await _readBytesFromPath(image.path);
      if (bytes == null || bytes.isEmpty) continue;
      payloads.add('data:${image.contentType};base64,${base64Encode(bytes)}');
    }

    final response = await _client.post(
      _buildUri('/posts'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'author_name': authorName,
        'author_avatar':
            (authorAvatar != null && authorAvatar.trim().isNotEmpty)
            ? authorAvatar.trim()
            : null,
        'content': content,
        'meta_feeling': (metaFeeling != null && metaFeeling.trim().isNotEmpty)
            ? metaFeeling.trim()
            : null,
        'meta_location':
            (metaLocation != null && metaLocation.trim().isNotEmpty)
            ? metaLocation.trim()
            : null,
        'image_payloads': payloads,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? message;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final raw = decoded['message'];
          if (raw is String && raw.trim().isNotEmpty) {
            message = raw.trim();
          }
          final errors = decoded['errors'];
          if (message == null && errors is Map) {
            for (final value in errors.values) {
              if (value is List && value.isNotEmpty && value.first is String) {
                message = (value.first as String).trim();
                break;
              }
            }
          }
        }
      } catch (_) {}
      final normalized = (message ?? '').toLowerCase();
      if (normalized.contains('post data is too large')) {
        throw Exception(
          'Selected images are too large. Please upload fewer or smaller photos.',
        );
      }
      throw Exception(message ?? 'Failed to create post.');
    }

    final decoded = jsonDecode(response.body);
    final data = (decoded is Map<String, dynamic> ? decoded['data'] : null);
    if (data is Map<String, dynamic>) {
      return FeedPost.fromJson(data);
    }
    throw Exception('Invalid post response.');
  }

  Future<List<int>?> _readBytesFromPath(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  int _estimateTotalBytes(List<FeedImageUpload> images) {
    var total = 0;
    for (final image in images) {
      final bytes = image.bytes;
      if (bytes != null && bytes.isNotEmpty) {
        total += bytes.length;
      }
    }
    return total;
  }
}
