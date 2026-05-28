import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:farmbuzz/core/network/api_config.dart';

class FarmApi {
  FarmApi();

  static String get _baseUrl {
    return ApiConfig.baseUrl;
  }

  Future<Map<String, dynamic>?> getFarm({required String mobileNumber}) async {
    final uri = Uri.parse(
      '$_baseUrl/farm',
    ).replace(queryParameters: {'mobile_number': mobileNumber});

    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw FarmApiException('Failed to load farm.');
    }

    final data = _decode(response.body);
    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      return null;
    }
    return payload;
  }

  Future<Map<String, dynamic>> saveFarm({
    required String mobileNumber,
    required String name,
    String? farmType,
    String? city,
    int? startedYear,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/farm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'name': name,
        'farm_type': farmType,
        'city': city,
        'started_year': startedYear,
      }),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmApiException(
        _extractMessage(data, fallback: 'Failed to save farm.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const FarmApiException('Invalid farm response.');
    }

    return payload;
  }

  Future<void> deleteFarm({required String mobileNumber}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/farm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile_number': mobileNumber}),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmApiException(
        _extractMessage(data, fallback: 'Failed to delete farm.'),
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

class FarmApiException implements Exception {
  const FarmApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
