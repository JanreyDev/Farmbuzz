import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';

class RankApiException implements Exception {
  final String message;
  const RankApiException(this.message);

  @override
  String toString() => message;
}

class RankApi {
  RankApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Map<String, String> _jsonHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath').replace(queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> fetchRank(String mobileNumber) async {
    final response = await _client.get(
      _buildUri('/rank', {'mobile_number': mobileNumber}),
      headers: _jsonHeaders,
    );

    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = body['message'] ?? 'Failed to load rank.';
      throw RankApiException(msg);
    }

    return body['data'] as Map<String, dynamic>;
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
    } catch (_) {}
    return <String, dynamic>{};
  }
}
