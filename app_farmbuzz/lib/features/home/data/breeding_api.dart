import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:farmbuzz/core/network/api_config.dart';

class BreedingApi {
  BreedingApi();

  static String get _baseUrl {
    return ApiConfig.baseUrl;
  }

  Future<List<Map<String, dynamic>>> getCollections({
    required String mobileNumber,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/breeding/collections',
    ).replace(queryParameters: {'mobile_number': mobileNumber});

    final response = await http.get(uri);
    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw BreedingApiException(
        _extractMessage(data, fallback: 'Failed to load collections.'),
      );
    }

    final payload = data['data'];
    if (payload is! List) {
      return const <Map<String, dynamic>>[];
    }

    return payload
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> createCollection({
    required String mobileNumber,
    required String batchName,
    required int eggCount,
    required String collectedOn,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/breeding/collections'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'batch_name': batchName,
        'egg_count': eggCount,
        'collected_on': collectedOn,
        'note': note,
      }),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw BreedingApiException(
        _extractMessage(data, fallback: 'Failed to create collection.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const BreedingApiException('Invalid collection response.');
    }

    return payload;
  }

  Future<Map<String, dynamic>> updateCollection({
    required String mobileNumber,
    required int id,
    required String batchName,
    required int eggCount,
    required String collectedOn,
    String? note,
    String? status,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/breeding/collections/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'batch_name': batchName,
        'egg_count': eggCount,
        'collected_on': collectedOn,
        'note': note,
        'status': status,
      }),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw BreedingApiException(
        _extractMessage(data, fallback: 'Failed to update collection.'),
      );
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const BreedingApiException('Invalid collection response.');
    }

    return payload;
  }

  Future<void> deleteCollection({
    required String mobileNumber,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/breeding/collections/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile_number': mobileNumber}),
    );

    final data = _decode(response.body);
    if (response.statusCode >= 400) {
      throw BreedingApiException(
        _extractMessage(data, fallback: 'Failed to delete collection.'),
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

class BreedingApiException implements Exception {
  const BreedingApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
