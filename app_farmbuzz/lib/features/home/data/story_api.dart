import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:farmbuzz/core/network/api_config.dart';

class StoryApi {
  StoryApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String get _baseUrl {
    return ApiConfig.baseUrl;
  }

  Future<List<Map<String, dynamic>>> getStories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/stories'));
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw StoryApiException('Failed to load stories.');
    }

    final payload = data['data'];
    if (payload is! List) {
      return const <Map<String, dynamic>>[];
    }

    return payload
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> createStory({
    required String mobileNumber,
    String? imagePath,
    String? textContent,
    String visibility = 'public',
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/stories'))
          ..headers['Accept'] = 'application/json'
          ..fields['mobile_number'] = mobileNumber
          ..fields['visibility'] = visibility;

    if (textContent != null && textContent.trim().isNotEmpty) {
      request.fields['text_content'] = textContent.trim();
    }

    if (imagePath != null && imagePath.trim().isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = _decode(response.body);

    if (response.statusCode >= 400) {
      throw StoryApiException(
        _extractMessage(data, fallback: 'Failed to create story.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const StoryApiException('Invalid story response.');
    }

    return payload;
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
}

class StoryApiException implements Exception {
  const StoryApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
