import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'registration_id': registrationId,
        'mobile_number': mobileNumber,
      }),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_extractMessage(body, fallback: 'Failed to send OTP.'));
    }
  }

  Future<void> verifyOtp({
    required int registrationId,
    required String otp,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/register/verify-otp'),
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
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

  Map<String, dynamic> _decodeJson(String raw) {
    if (raw.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
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

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
