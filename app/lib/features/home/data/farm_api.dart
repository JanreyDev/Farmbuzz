import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';

class FarmApi {
  FarmApi({http.Client? client}) : _client = client ?? http.Client();

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

  Future<Map<String, dynamic>> createFarm({
    required String mobileNumber,
    required String name,
    String? farmType,
    String? city,
    int? startedYear,
  }) async {
    final bodyData = <String, dynamic>{
      'mobile_number': mobileNumber,
      'name': name,
    };
    if (farmType != null && farmType.isNotEmpty) bodyData['farm_type'] = farmType;
    if (city != null && city.isNotEmpty) bodyData['city'] = city;
    if (startedYear != null && startedYear > 0) bodyData['started_year'] = startedYear;

    final response = await _client.post(
      _buildUri('/farm'),
      headers: _jsonHeaders,
      body: jsonEncode(bodyData),
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to create farm.'),
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

class FarmApiException implements Exception {
  const FarmApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
