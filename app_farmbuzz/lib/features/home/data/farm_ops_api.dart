import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class FarmOpsApi {
  FarmOpsApi();

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

  Future<List<Map<String, dynamic>>> getFlock({required String mobileNumber}) async {
    final uri = Uri.parse('$_baseUrl/flock').replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to load flock.'));
    }
    return _asList(data['data']);
  }

  Future<void> addFlock({
    required String mobileNumber,
    required String name,
    required String category,
    required String stage,
    required int count,
    required String startedOn,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/flock'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'name': name,
        'category': category,
        'stage': stage,
        'count': count,
        'started_on': startedOn,
        'note': note,
      }),
    );
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to add flock batch.'));
    }
  }

  Future<void> deleteFlock({required String mobileNumber, required int id}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/flock/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile_number': mobileNumber}),
    );
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to delete flock batch.'));
    }
  }

  Future<List<Map<String, dynamic>>> getTeam({required String mobileNumber}) async {
    final uri = Uri.parse('$_baseUrl/team').replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to load team.'));
    }
    return _asList(data['data']);
  }

  Future<List<Map<String, dynamic>>> getTeamInviteCandidates({required String mobileNumber}) async {
    final uri = Uri.parse('$_baseUrl/team/invite-candidates')
        .replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to load invite candidates.'));
    }
    return _asList(data['data']);
  }

  Future<void> saveTeamMember({
    required String ownerMobileNumber,
    required String name,
    required String memberMobile,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/team'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'owner_mobile_number': ownerMobileNumber,
        'name': name,
        'mobile_number': memberMobile,
        'role': role,
        'status': 'active',
      }),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to save team member.'));
    }
  }

  Future<void> deleteTeamMember({required String ownerMobileNumber, required int id}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/team/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'owner_mobile_number': ownerMobileNumber}),
    );
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to delete team member.'));
    }
  }

  Future<Map<String, dynamic>> getReportSummary({required String mobileNumber}) async {
    final uri = Uri.parse('$_baseUrl/reports/summary').replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw FarmOpsApiException(_extractMessage(data, fallback: 'Failed to load report summary.'));
    }
    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asList(dynamic payload) {
    if (payload is! List) {
      return const <Map<String, dynamic>>[];
    }
    return payload
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList();
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

  static String _extractMessage(Map<String, dynamic> data, {required String fallback}) {
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

class FarmOpsApiException implements Exception {
  const FarmOpsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
