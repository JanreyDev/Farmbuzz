import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NotificationApi {
  NotificationApi();

  static String get _baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    if (Platform.isAndroid) return 'http://167.172.89.188:8083/api';
    return 'http://167.172.89.188:8083/api';
  }

  Future<Map<String, int>> getCounts({required String mobileNumber}) async {
    final uri = Uri.parse('$_baseUrl/counts').replace(queryParameters: {
      'mobile_number': mobileNumber,
    });
    final response = await http.get(uri);

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw NotificationApiException(data['message'] ?? 'Failed to load counts.');
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
