import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';

class SocialApi {
  SocialApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _buildUri(String path, [Map<String, dynamic>? params]) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    var uri = Uri.parse('$base$normalizedPath');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  /// Returns whether [myMobile] is following [targetName].
  Future<bool> isFollowing({
    required String myMobile,
    required String targetName,
  }) async {
    try {
      final uri = _buildUri('/social/status', {
        'mobile_number': myMobile,
        'target_name': targetName,
      });
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['is_following'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> follow({
    required String myMobile,
    required String targetName,
  }) async {
    final uri = _buildUri('/social/follow');
    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': myMobile,
        'target_name': targetName,
      }),
    );
  }

  Future<void> unfollow({
    required String myMobile,
    required String targetName,
  }) async {
    final uri = _buildUri('/social/follow');
    await _client.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': myMobile,
        'target_name': targetName,
      }),
    );
  }
}
