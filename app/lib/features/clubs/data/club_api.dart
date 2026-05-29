import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';

class ClubApi {
  ClubApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Map<String, String> _jsonHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<Map<String, dynamic>> createClub({
    required String mobileNumber,
    required String name,
    String? description,
    String? category,
    String? region,
    List<String>? focusTags,
    bool? isPublic,
    int? minBirds,
    bool? verifiedOnly,
    String? coverImageUrl,
  }) async {
    final bodyData = <String, dynamic>{
      'mobile_number': mobileNumber,
      'name': name,
    };
    if (description != null && description.isNotEmpty) bodyData['description'] = description;
    if (category != null && category.isNotEmpty) bodyData['category'] = category;
    if (region != null && region.isNotEmpty) bodyData['region'] = region;
    if (focusTags != null && focusTags.isNotEmpty) bodyData['focus_tags'] = focusTags;
    if (isPublic != null) bodyData['is_public'] = isPublic;
    if (minBirds != null) bodyData['min_birds'] = minBirds;
    if (verifiedOnly != null) bodyData['verified_only'] = verifiedOnly;
    if (coverImageUrl != null && coverImageUrl.isNotEmpty) bodyData['cover_image_url'] = coverImageUrl;

    final response = await _client.post(
      _buildUri('/clubs'),
      headers: _jsonHeaders,
      body: jsonEncode(bodyData),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ClubApiException(
        _extractMessage(body, fallback: 'Failed to create club.'),
      );
    }

    return body;
  }

  Map<String, dynamic> _decodeJson(String raw) {
    if (raw.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  String _extractMessage(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final errors = body['errors'];
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

class ClubApiException implements Exception {
  const ClubApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
