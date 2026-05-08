import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class RegistrationApi {
  RegistrationApi({http.Client? client}) : _client = client ?? http.Client();

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

  Future<int> startRegistration({
    required String name,
    String? referralCode,
  }) async {
    final response = await _postJson('/auth/register/start', {
      'name': name,
      'referral_code': referralCode,
      'is_at_least_18': true,
      'accepted_terms': true,
    });

    final data = _decode(response.body);
    if (response.statusCode != 201) {
      throw RegistrationApiException(
        _extractMessage(data, fallback: 'Failed to start registration.'),
      );
    }

    final registrationId = data['registration_id'];
    if (registrationId is! int) {
      throw const RegistrationApiException(
        'Invalid registration ID from server.',
      );
    }

    return registrationId;
  }

  Future<void> sendOtp({
    required int registrationId,
    required String mobileNumber,
  }) async {
    final response = await _postJson('/auth/register/send-otp', {
      'registration_id': registrationId,
      'mobile_number': mobileNumber,
    });

    if (response.statusCode >= 400) {
      final data = _decode(response.body);
      throw RegistrationApiException(
        _extractMessage(data, fallback: 'Failed to send OTP.'),
      );
    }
  }

  Future<void> verifyOtp({
    required int registrationId,
    required String otp,
  }) async {
    final response = await _postJson('/auth/register/verify-otp', {
      'registration_id': registrationId,
      'otp': otp,
    });

    if (response.statusCode >= 400) {
      final data = _decode(response.body);
      throw RegistrationApiException(
        _extractMessage(data, fallback: 'OTP verification failed.'),
      );
    }
  }

  Future<void> setPin({
    required int registrationId,
    required String pin,
  }) async {
    final response = await _postJson('/auth/register/set-pin', {
      'registration_id': registrationId,
      'pin': pin,
      'pin_confirmation': pin,
    });

    if (response.statusCode >= 400) {
      final data = _decode(response.body);
      throw RegistrationApiException(
        _extractMessage(data, fallback: 'Failed to set PIN.'),
      );
    }
  }

  Future<LoginUser> login({
    required String mobileNumber,
    required String pin,
  }) async {
    final response = await _postJson('/auth/login', {
      'mobile_number': mobileNumber,
      'pin': pin,
    });

    if (response.statusCode >= 400) {
      final data = _decode(response.body);
      throw RegistrationApiException(
        _extractMessage(data, fallback: 'Login failed.'),
      );
    }

    final data = _decode(response.body);
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const RegistrationApiException('Invalid login response.');
    }

    final name = (user['name'] ?? '').toString().trim();
    final mobile = (user['mobile_number'] ?? '').toString().trim();
    if (name.isEmpty || mobile.isEmpty) {
      throw const RegistrationApiException('Incomplete user data from server.');
    }

    return LoginUser(name: name, mobileNumber: mobile);
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
      throw RegistrationApiException(
        'Network error: $error. API URL: $_baseUrl',
      );
    } on http.ClientException catch (error) {
      throw RegistrationApiException(
        'HTTP client error: ${error.message}. API URL: $_baseUrl',
      );
    } catch (error) {
      throw RegistrationApiException('Unexpected request error: $error');
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
      return rawBody.length > 200 ? '${rawBody.substring(0, 200)}...' : rawBody;
    }

    return fallback;
  }
}

class RegistrationApiException implements Exception {
  const RegistrationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LoginUser {
  const LoginUser({required this.name, required this.mobileNumber});

  final String name;
  final String mobileNumber;
}
