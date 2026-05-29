import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/network/api_config.dart';

// ── Data model ──────────────────────────────────────────────────────────────

class FarmProfile {
  const FarmProfile({
    this.id,
    this.name = '',
    this.tagline = '',
    this.farmType = '',
    this.city = '',
    this.province = '',
    this.startedYear,
    this.story = '',
    this.avatarUrl,
    this.coverPhotoUrl,
    this.birdsCount = 0,
    this.activeCycles = 0,
    this.eggsIncubating = 0,
    this.ownerName = '',
  });

  final int? id;
  final String name;
  final String tagline;
  final String farmType;
  final String city;
  final String province;
  final int? startedYear;
  final String story;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final int birdsCount;
  final int activeCycles;
  final int eggsIncubating;
  final String ownerName;

  factory FarmProfile.fromJson(Map<String, dynamic> json) {
    return FarmProfile(
      id:             json['id'] as int?,
      name:           (json['name'] as String?) ?? '',
      tagline:        (json['tagline'] as String?) ?? '',
      farmType:       (json['farm_type'] as String?) ?? '',
      city:           (json['city'] as String?) ?? '',
      province:       (json['province'] as String?) ?? '',
      startedYear:    json['started_year'] as int?,
      story:          (json['story'] as String?) ?? '',
      avatarUrl:      json['avatar_url'] as String?,
      coverPhotoUrl:  json['cover_photo_url'] as String?,
      birdsCount:     (json['birds_count'] as int?) ?? 0,
      activeCycles:   (json['active_cycles'] as int?) ?? 0,
      eggsIncubating: (json['eggs_incubating'] as int?) ?? 0,
      ownerName:      (json['owner_name'] as String?) ?? '',
    );
  }
}

// ── API class ────────────────────────────────────────────────────────────────

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

  // GET /farm
  Future<FarmProfile?> fetchFarm({required String mobileNumber}) async {
    final uri = _buildUri('/farm').replace(
      queryParameters: {'mobile_number': mobileNumber},
    );
    final response = await _client.get(uri, headers: _jsonHeaders);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to load farm.'),
      );
    }
    final data = body['data'];
    if (data == null) return null;
    return FarmProfile.fromJson(data as Map<String, dynamic>);
  }

  // POST /farm — create / update text fields
  Future<FarmProfile> saveFarm({
    required String mobileNumber,
    required String name,
    String? tagline,
    String? farmType,
    String? city,
    String? province,
    int? startedYear,
    String? story,
  }) async {
    final bodyData = <String, dynamic>{
      'mobile_number': mobileNumber,
      'name': name,
    };
    if (tagline != null) bodyData['tagline'] = tagline;
    if (farmType != null && farmType.isNotEmpty) bodyData['farm_type'] = farmType;
    if (city != null && city.isNotEmpty) bodyData['city'] = city;
    if (province != null && province.isNotEmpty) bodyData['province'] = province;
    if (startedYear != null && startedYear > 0) bodyData['started_year'] = startedYear;
    if (story != null) bodyData['story'] = story;

    final response = await _client.post(
      _buildUri('/farm'),
      headers: _jsonHeaders,
      body: jsonEncode(bodyData),
    );
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to save farm.'),
      );
    }
    return FarmProfile.fromJson(body['data'] as Map<String, dynamic>);
  }

  // POST /farm/media — upload avatar and/or cover photo
  Future<Map<String, String?>> uploadFarmMedia({
    required String mobileNumber,
    File? avatar,
    File? coverPhoto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _buildUri('/farm/media'),
    );
    request.fields['mobile_number'] = mobileNumber;

    if (avatar != null) {
      final ext = avatar.path.split('.').last.toLowerCase();
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatar.path,
        contentType: MediaType('image', ext),
      ));
    }

    if (coverPhoto != null) {
      final ext = coverPhoto.path.split('.').last.toLowerCase();
      request.files.add(await http.MultipartFile.fromPath(
        'cover_photo',
        coverPhoto.path,
        contentType: MediaType('image', ext),
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = _decodeJson(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to upload media.'),
      );
    }

    return {
      'avatar_url':      body['avatar_url'] as String?,
      'cover_photo_url': body['cover_photo_url'] as String?,
    };
  }

  // POST /farm — legacy create (kept for backward compat)
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
    if (raw.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  String _extractMessage(Map<String, dynamic> body, {required String fallback}) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message;
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
