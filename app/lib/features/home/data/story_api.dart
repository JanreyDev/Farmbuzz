import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';

class FeedStory {
  FeedStory({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.imageUrl,
    required this.textContent,
    required this.timeAgo,
  });

  final int id;
  final String name;
  final String avatarUrl;
  final String imageUrl;
  final String textContent;
  final String timeAgo;

  factory FeedStory.fromJson(Map<String, dynamic> json) {
    return FeedStory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      textContent: (json['textContent'] as String?) ?? '',
      timeAgo: (json['timeAgo'] as String?) ?? 'Just now',
    );
  }
}

class StoryApi {
  StoryApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<List<FeedStory>> fetchStories() async {
    final response = await _client.get(
      _buildUri('/stories'),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch stories.');
    }

    final decoded = jsonDecode(response.body);
    final data =
        (decoded is Map<String, dynamic> ? decoded['data'] : null) as List?;
    if (data == null) return <FeedStory>[];
    return data
        .whereType<Map>()
        .map((e) => FeedStory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FeedStory> createStory({
    required String mobileNumber,
    String? imagePath,
    String? textContent,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri('/stories'));
    request.headers['Accept'] = 'application/json';
    request.fields['mobile_number'] = mobileNumber.trim();
    request.fields['visibility'] = 'public';

    final normalizedText = textContent?.trim() ?? '';
    if (normalizedText.isNotEmpty) {
      request.fields['text_content'] = normalizedText;
    }

    final normalizedPath = imagePath?.trim() ?? '';
    if (normalizedPath.isNotEmpty) {
      final file = File(normalizedPath);
      if (!await file.exists()) {
        throw Exception('Selected media was not found.');
      }
      request.files.add(
        await http.MultipartFile.fromPath('image', normalizedPath),
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
        }
      } catch (_) {}
      throw Exception(message ?? 'Failed to create story.');
    }

    final decoded = jsonDecode(response.body);
    final data = (decoded is Map<String, dynamic> ? decoded['data'] : null);
    if (data is Map<String, dynamic>) {
      return FeedStory.fromJson(data);
    }
    throw Exception('Invalid story response.');
  }
}
