import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:farmbuzz/core/network/api_config.dart';

class NotificationApi {
  NotificationApi();

  static String get _baseUrl {
    return ApiConfig.baseUrl;
  }

  Future<Map<String, int>> getCounts({required String mobileNumber}) async {
    final uri = Uri.parse(
      '$_baseUrl/counts',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await http.get(uri);

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw NotificationApiException(
        data['message'] ?? 'Failed to load counts.',
      );
    }

    final payload = data['data'];
    return {
      'messages': (payload['messages'] ?? 0) as int,
      'notifications': (payload['notifications'] ?? 0) as int,
    };
  }
}

class NotificationApiException implements Exception {
  const NotificationApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
