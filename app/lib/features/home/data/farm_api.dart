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
    this.achievements = const [],
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
  final List<dynamic> achievements;

  factory FarmProfile.fromJson(Map<String, dynamic> json) {
    return FarmProfile(
      id: json['id'] as int?,
      name: (json['name'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      farmType: (json['farm_type'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      province: (json['province'] as String?) ?? '',
      startedYear: json['started_year'] as int?,
      story: (json['story'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      birdsCount: (json['birds_count'] as int?) ?? 0,
      activeCycles: (json['active_cycles'] as int?) ?? 0,
      eggsIncubating: (json['eggs_incubating'] as int?) ?? 0,
      ownerName: (json['owner_name'] as String?) ?? '',
      achievements: json['achievements'] as List<dynamic>? ?? [],
    );
  }
}

class HeritageLine {
  const HeritageLine({
    required this.id,
    required this.name,
    required this.description,
    required this.originFocus,
    required this.traits,
    this.generationsBred,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final String originFocus;
  final String traits;
  final int? generationsBred;
  final String createdAt;

  factory HeritageLine.fromJson(Map<String, dynamic> json) {
    return HeritageLine(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      originFocus: (json['origin_focus'] as String?) ?? '',
      traits: (json['traits'] as String?) ?? '',
      generationsBred: json['generations_bred'] as int?,
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }
}

class FeaturedBird {
  const FeaturedBird({
    required this.id,
    required this.name,
    required this.heritageLine,
    required this.ageLabel,
    required this.sex,
    required this.badge,
    this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String heritageLine;
  final String ageLabel;
  final String sex;
  final String badge;
  final String? imageUrl;
  final String createdAt;

  factory FeaturedBird.fromJson(Map<String, dynamic> json) {
    return FeaturedBird(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      heritageLine: (json['heritage_line'] as String?) ?? '',
      ageLabel: (json['age_label'] as String?) ?? '',
      sex: (json['sex'] as String?) ?? '',
      badge: (json['badge'] as String?) ?? '',
      imageUrl: json['image_url'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }
}

class FarmGalleryPhoto {
  const FarmGalleryPhoto({
    required this.id,
    this.imageUrl,
    required this.createdAt,
  });

  final int id;
  final String? imageUrl;
  final String createdAt;

  factory FarmGalleryPhoto.fromJson(Map<String, dynamic> json) {
    return FarmGalleryPhoto(
      id: (json['id'] as int?) ?? 0,
      imageUrl: json['image_url'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
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
    final uri = _buildUri(
      '/farm',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
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
    List<Map<String, dynamic>>? achievements,
  }) async {
    final bodyData = <String, dynamic>{
      'mobile_number': mobileNumber,
      'name': name,
    };
    if (tagline != null) {
      bodyData['tagline'] = tagline;
    }
    if (farmType != null && farmType.isNotEmpty) {
      bodyData['farm_type'] = farmType;
    }
    if (city != null && city.isNotEmpty) {
      bodyData['city'] = city;
    }
    if (province != null && province.isNotEmpty) {
      bodyData['province'] = province;
    }
    if (startedYear != null && startedYear > 0) {
      bodyData['started_year'] = startedYear;
    }
    if (story != null) {
      bodyData['story'] = story;
    }
    if (achievements != null) {
      bodyData['achievements'] = achievements;
    }

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
    final request = http.MultipartRequest('POST', _buildUri('/farm/media'));
    request.fields['mobile_number'] = mobileNumber;

    if (avatar != null) {
      final ext = avatar.path.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          contentType: MediaType('image', ext),
        ),
      );
    }

    if (coverPhoto != null) {
      final ext = coverPhoto.path.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'cover_photo',
          coverPhoto.path,
          contentType: MediaType('image', ext),
        ),
      );
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
      'avatar_url': body['avatar_url'] as String?,
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
    if (farmType != null && farmType.isNotEmpty) {
      bodyData['farm_type'] = farmType;
    }
    if (city != null && city.isNotEmpty) {
      bodyData['city'] = city;
    }
    if (startedYear != null && startedYear > 0) {
      bodyData['started_year'] = startedYear;
    }

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

  Future<List<HeritageLine>> fetchHeritageLines({
    required String mobileNumber,
  }) async {
    final uri = _buildUri(
      '/farm/heritage-lines',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await _client.get(uri, headers: _jsonHeaders);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to load heritage lines.'),
      );
    }
    final raw = body['data'];
    if (raw is! List) return const <HeritageLine>[];
    return raw
        .whereType<Map>()
        .map((e) => HeritageLine.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<HeritageLine> addHeritageLine({
    required String mobileNumber,
    required String name,
    String? description,
    String? originFocus,
    String? traits,
    int? generationsBred,
  }) async {
    final response = await _client.post(
      _buildUri('/farm/heritage-lines'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'name': name,
        'description': description ?? '',
        'origin_focus': originFocus ?? '',
        'traits': traits ?? '',
        'generations_bred': generationsBred,
      }),
    );
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to add heritage line.'),
      );
    }
    return HeritageLine.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<HeritageLine> updateHeritageLine({
    required int id,
    required String mobileNumber,
    required String name,
    String? description,
    String? originFocus,
    String? traits,
    int? generationsBred,
  }) async {
    final response = await _client.put(
      _buildUri('/farm/heritage-lines/$id'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'name': name,
        'description': description ?? '',
        'origin_focus': originFocus ?? '',
        'traits': traits ?? '',
        'generations_bred': generationsBred,
      }),
    );
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to update heritage line.'),
      );
    }
    return HeritageLine.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteHeritageLine({
    required int id,
    required String mobileNumber,
  }) async {
    final response = await _client.delete(
      _buildUri('/farm/heritage-lines/$id'),
      headers: _jsonHeaders,
      body: jsonEncode({'mobile_number': mobileNumber}),
    );
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to delete heritage line.'),
      );
    }
  }

  Future<List<FeaturedBird>> fetchFeaturedBirds({
    required String mobileNumber,
  }) async {
    final uri = _buildUri(
      '/farm/featured-birds',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await _client.get(uri, headers: _jsonHeaders);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to load featured birds.'),
      );
    }
    final raw = body['data'];
    if (raw is! List) return const <FeaturedBird>[];
    return raw
        .whereType<Map>()
        .map((e) => FeaturedBird.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FeaturedBird> addFeaturedBird({
    required String mobileNumber,
    required String name,
    String? heritageLine,
    String? ageLabel,
    String? sex,
    String? badge,
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _buildUri('/farm/featured-birds'),
    );
    request.fields['mobile_number'] = mobileNumber;
    request.fields['name'] = name;
    if (heritageLine != null) request.fields['heritage_line'] = heritageLine;
    if (ageLabel != null) request.fields['age_label'] = ageLabel;
    if (sex != null) request.fields['sex'] = sex;
    if (badge != null) request.fields['badge'] = badge;
    if (image != null) {
      final ext = image.path.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', ext),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to add featured bird.'),
      );
    }
    return FeaturedBird.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<FeaturedBird> updateFeaturedBird({
    required int id,
    required String mobileNumber,
    required String name,
    String? heritageLine,
    String? ageLabel,
    String? sex,
    String? badge,
    File? image,
    bool removeImage = false,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _buildUri('/farm/featured-birds/$id'),
    );
    request.fields['mobile_number'] = mobileNumber;
    request.fields['name'] = name;
    request.fields['remove_image'] = removeImage ? '1' : '0';
    if (heritageLine != null) request.fields['heritage_line'] = heritageLine;
    if (ageLabel != null) request.fields['age_label'] = ageLabel;
    if (sex != null) request.fields['sex'] = sex;
    if (badge != null) request.fields['badge'] = badge;
    if (image != null) {
      final ext = image.path.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', ext),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to update featured bird.'),
      );
    }
    return FeaturedBird.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteFeaturedBird({
    required int id,
    required String mobileNumber,
  }) async {
    final response = await _client.delete(
      _buildUri('/farm/featured-birds/$id'),
      headers: _jsonHeaders,
      body: jsonEncode({'mobile_number': mobileNumber}),
    );
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to delete featured bird.'),
      );
    }
  }

  Future<List<FarmGalleryPhoto>> fetchFarmGalleryPhotos({
    required String mobileNumber,
  }) async {
    final uri = _buildUri(
      '/farm/gallery/photos',
    ).replace(queryParameters: {'mobile_number': mobileNumber});
    final response = await _client.get(uri, headers: _jsonHeaders);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to load farm gallery.'),
      );
    }
    final raw = body['data'];
    if (raw is! List) return const <FarmGalleryPhoto>[];
    return raw
        .whereType<Map>()
        .map((e) => FarmGalleryPhoto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<FarmGalleryPhoto>> uploadFarmGalleryPhotos({
    required String mobileNumber,
    required List<File> photos,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _buildUri('/farm/gallery/photos'),
    );
    request.fields['mobile_number'] = mobileNumber;

    for (final file in photos) {
      final ext = file.path.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos[]',
          file.path,
          contentType: MediaType('image', ext),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to upload gallery photos.'),
      );
    }

    final raw = body['data'];
    if (raw is! List) return const <FarmGalleryPhoto>[];
    return raw
        .whereType<Map>()
        .map((e) => FarmGalleryPhoto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> deleteFarmGalleryPhoto({
    required int id,
    required String mobileNumber,
  }) async {
    final response = await _client.delete(
      _buildUri('/farm/gallery/photos/$id'),
      headers: _jsonHeaders,
      body: jsonEncode({'mobile_number': mobileNumber}),
    );
    final body = _decodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FarmApiException(
        _extractMessage(body, fallback: 'Failed to delete gallery photo.'),
      );
    }
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

  String _extractMessage(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
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
