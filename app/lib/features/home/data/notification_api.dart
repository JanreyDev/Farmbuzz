import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';

class NotificationApi {
  NotificationApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Future<Map<String, int>> fetchCounts({required String mobileNumber}) async {
    final uri = _buildUri('/counts').replace(queryParameters: {
      'mobile_number': mobileNumber,
    });
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final counts = data['data'] as Map<String, dynamic>?;
      return {
        'messages': (counts?['messages'] as num?)?.toInt() ?? 0,
        'notifications': (counts?['notifications'] as num?)?.toInt() ?? 0,
      };
    }
    return {'messages': 0, 'notifications': 0};
  }
}