import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:farmbuzz/core/network/api_config.dart';

class SocialApi {
  SocialApi();

  static String get _baseUrl {
    return ApiConfig.baseUrl;
  }

  Future<Map<String, dynamic>> getStatus({
    required String mobileNumber,
    required String targetName,
  }) async {
    final uri = Uri.parse('$_baseUrl/social/status').replace(
      queryParameters: {
        'mobile_number': mobileNumber,
        'target_name': targetName,
      },
    );
    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw SocialApiException(
        _extractMessage(data, fallback: 'Failed to load follow status.'),
      );
    }
    return (data['data'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getCounts({
    required String mobileNumber,
    String? targetName,
  }) async {
    final query = <String, String>{'mobile_number': mobileNumber};
    if (targetName != null && targetName.trim().isNotEmpty) {
      query['target_name'] = targetName.trim();
    }
    final uri = Uri.parse(
      '$_baseUrl/social/counts',
    ).replace(queryParameters: query);
    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw SocialApiException(
        _extractMessage(data, fallback: 'Failed to load social counts.'),
      );
    }
    return (data['data'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
  }

  Future<void> follow({
    required String mobileNumber,
    required String targetName,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/social/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'target_name': targetName,
      }),
    );
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw SocialApiException(
        _extractMessage(data, fallback: 'Failed to follow user.'),
      );
    }
  }

  Future<void> unfollow({
    required String mobileNumber,
    required String targetName,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/social/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'target_name': targetName,
      }),
    );
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw SocialApiException(
        _extractMessage(data, fallback: 'Failed to unfollow user.'),
      );
    }
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
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
    if (message is String && message.trim().isNotEmpty) return message;
    return fallback;
  }
}

class SocialApiException implements Exception {
  const SocialApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
