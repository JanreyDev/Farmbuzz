import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

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

  Future<int> startRegistration({
    required String name,
    String? referralCode,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/register/start'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'referral_code': referralCode,
        'is_at_least_18': true,
        'accepted_terms': true,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractMessage(body, fallback: 'Unable to start registration.'));
    }

    final registrationId = body['registration_id'];
    if (registrationId is! int) {
      throw const AuthApiException('Invalid registration response from server.');
    }
    return registrationId;
  }

  Future<void> sendOtp({
    required int registrationId,
    required String mobileNumber,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/register/send-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'registration_id': registrationId,
        'mobile_number': mobileNumber,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        _extractMessage(
          body,
          fallback: _fallbackFromRaw(
            raw: response.body,
            fallback: 'Failed to send OTP.',
          ),
        ),
      );
    }
  }

  Future<void> verifyOtp({
    required int registrationId,
    required String otp,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/register/verify-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'registration_id': registrationId,
        'otp': otp,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractMessage(body, fallback: 'OTP verification failed.'));
    }
  }

  Future<void> setPin({
    required int registrationId,
    required String pin,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/register/set-pin'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'registration_id': registrationId,
        'pin': pin,
        'pin_confirmation': pin,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractMessage(body, fallback: 'Failed to set PIN.'));
    }
  }

  Future<Map<String, dynamic>> login({
    required String mobileNumber,
    required String pin,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'pin': pin,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractMessage(body, fallback: 'Login failed.'));
    }

    return body;
  }

  Future<void> logout({String? mobileNumber}) async {
    final response = await _client.post(
      _buildUri('/auth/logout'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'mobile_number': mobileNumber,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractMessage(body, fallback: 'Logout failed.'));
    }
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

  String _fallbackFromRaw({
    required String raw,
    required String fallback,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }

    // When backend/proxy returns HTML (500/503), avoid showing a long page.
    if (trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html')) {
      return fallback;
    }

    final compact = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    if (compact.length <= 200) {
      return compact;
    }

    return '${compact.substring(0, 200)}...';
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

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
