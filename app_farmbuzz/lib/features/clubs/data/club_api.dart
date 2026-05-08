import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ClubApi {
  ClubApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String get _baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  Future<List<Map<String, dynamic>>> getMyClubs({
    required String mobileNumber,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/clubs',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await _client.get(uri);

    if (response.statusCode >= 400) {
      throw const ClubApiException('Failed to load clubs.');
    }

    final decoded = _decode(response.body);
    final data = decoded['data'];
    if (data is! List) {
      return <Map<String, dynamic>>[];
    }

    return data.whereType<Map<String, dynamic>>().toList();
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
    final response = await _client.post(
      Uri.parse('$_baseUrl/clubs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'name': name,
        'description': description,
        'category': category,
        'region': region,
        'focus_tags': focusTags ?? <String>[],
        'is_public': isPublic ?? true,
        'min_birds': minBirds ?? 0,
        'verified_only': verifiedOnly ?? false,
        'cover_image_url': coverImageUrl,
      }),
    );

    final decoded = _decode(response.body);
    if (response.statusCode >= 400) {
      throw ClubApiException(
        _extractMessage(decoded, fallback: 'Failed to create club.'),
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const ClubApiException('Invalid club response.');
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getDiscoverClubs({
    String? mobileNumber,
    String? category,
  }) async {
    final query = <String, String>{};
    final trimmedMobile = mobileNumber?.trim() ?? '';
    final trimmedCategory = category?.trim() ?? '';

    if (trimmedMobile.isNotEmpty) {
      query['mobile_number'] = trimmedMobile;
    }
    if (trimmedCategory.isNotEmpty && trimmedCategory != 'All') {
      query['category'] = trimmedCategory;
    }

    final uri = Uri.parse(
      '$_baseUrl/clubs/discover',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final response = await _client.get(uri);

    if (response.statusCode >= 400) {
      throw const ClubApiException('Failed to load discover clubs.');
    }

    final decoded = _decode(response.body);
    final data = decoded['data'];
    if (data is! List) {
      return <Map<String, dynamic>>[];
    }

    return data.whereType<Map<String, dynamic>>().toList();
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

class ClubApiException implements Exception {
  const ClubApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
