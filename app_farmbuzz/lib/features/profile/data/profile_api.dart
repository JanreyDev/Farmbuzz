import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ProfileApi {
  ProfileApi();

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

  Future<Map<String, String>> updateProfile({
    required String mobileNumber,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile_number': mobileNumber, 'name': name}),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw ProfileApiException(
        _extractMessage(data, fallback: 'Failed to update profile.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const ProfileApiException('Invalid profile update response.');
    }

    return {
      'name': (payload['name'] ?? '').toString(),
      'avatar_url': (payload['avatar_url'] ?? '').toString(),
      'cover_photo_url': (payload['cover_photo_url'] ?? '').toString(),
    };
  }

  Future<Map<String, String>> getProfile({required String mobileNumber}) async {
    final uri = Uri.parse(
      '$_baseUrl/profile',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await http.get(uri);

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw ProfileApiException(
        _extractMessage(data, fallback: 'Failed to load profile.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const ProfileApiException('Invalid profile response.');
    }

    return {
      'name': (payload['name'] ?? '').toString(),
      'avatar_url': (payload['avatar_url'] ?? '').toString(),
      'cover_photo_url': (payload['cover_photo_url'] ?? '').toString(),
    };
  }

  Future<Map<String, String>> updateProfileMedia({
    required String mobileNumber,
    String? avatarPath,
    String? coverPhotoPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/profile/media'),
    )..fields['mobile_number'] = mobileNumber;

    if (avatarPath != null && avatarPath.trim().isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarPath),
      );
    }

    if (coverPhotoPath != null && coverPhotoPath.trim().isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('cover_photo', coverPhotoPath),
      );
    }

    if (request.files.isEmpty) {
      throw const ProfileApiException('Please select an image first.');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final data = _decode(response.body);

    if (response.statusCode >= 400) {
      throw ProfileApiException(
        _extractMessage(data, fallback: 'Failed to update profile media.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const ProfileApiException('Invalid profile media response.');
    }

    return {
      'avatar_url': (payload['avatar_url'] ?? '').toString(),
      'cover_photo_url': (payload['cover_photo_url'] ?? '').toString(),
    };
  }

  Future<void> deleteAccount({required String mobileNumber}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile_number': mobileNumber}),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw ProfileApiException(
        _extractMessage(data, fallback: 'Failed to delete account.'),
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
      return <String, dynamic>{'_raw_body': body};
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

    final rawBody = data['_raw_body'];
    if (rawBody is String && rawBody.trim().isNotEmpty) {
      return rawBody;
    }

    return fallback;
  }
}

class ProfileApiException implements Exception {
  const ProfileApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
