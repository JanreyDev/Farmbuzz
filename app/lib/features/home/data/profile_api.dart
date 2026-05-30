import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/network/api_config.dart';

class ProfileModel {
  const ProfileModel({
    required this.name,
    this.mobileNumber,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.yearsBreeding,
    this.bio,
    this.address,
    this.bloodlines,
    this.socialFb,
    this.socialIg,
    this.socialTiktok,
    this.socialYt,
    this.socialWeb,
    this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.clubsCount = 0,
  });

  final String name;
  final String? mobileNumber;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? yearsBreeding;
  final String? bio;
  final String? address;
  final String? bloodlines;
  final String? socialFb;
  final String? socialIg;
  final String? socialTiktok;
  final String? socialYt;
  final String? socialWeb;
  final String? createdAt;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int clubsCount;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      yearsBreeding: json['years_breeding'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      bloodlines: json['bloodlines'] as String?,
      socialFb: json['social_fb'] as String?,
      socialIg: json['social_ig'] as String?,
      socialTiktok: json['social_tiktok'] as String?,
      socialYt: json['social_yt'] as String?,
      socialWeb: json['social_web'] as String?,
      createdAt: json['created_at'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      clubsCount: json['clubs_count'] as int? ?? 0,
    );
  }
}

class ProfileApi {
  ProfileApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Map<String, String> _jsonHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    var uri = Uri.parse('$base$normalizedPath');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<ProfileModel?> fetchProfile({required String mobileNumber}) async {
    try {
      final response = await _client.get(
        _buildUri('/profile', {'mobile_number': mobileNumber}),
        headers: _jsonHeaders,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return ProfileModel.fromJson(body['data']);
        }
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<void> updateProfile({
    required String mobileNumber,
    required String name,
    String? yearsBreeding,
    String? bio,
    String? address,
    String? bloodlines,
    String? socialFb,
    String? socialIg,
    String? socialTiktok,
    String? socialYt,
    String? socialWeb,
  }) async {
    final response = await _client.post(
      _buildUri('/profile/update'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'mobile_number': mobileNumber,
        'name': name,
        if (yearsBreeding != null) 'years_breeding': yearsBreeding,
        if (bio != null) 'bio': bio,
        if (address != null) 'address': address,
        if (bloodlines != null) 'bloodlines': bloodlines,
        if (socialFb != null) 'social_fb': socialFb,
        if (socialIg != null) 'social_ig': socialIg,
        if (socialTiktok != null) 'social_tiktok': socialTiktok,
        if (socialYt != null) 'social_yt': socialYt,
        if (socialWeb != null) 'social_web': socialWeb,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  Future<void> uploadProfileMedia({
    required String mobileNumber,
    File? avatar,
    File? coverPhoto,
  }) async {
    if (avatar == null && coverPhoto == null) return;

    final uri = _buildUri('/profile/media');
    final request = http.MultipartRequest('POST', uri);
    request.fields['mobile_number'] = mobileNumber;

    if (avatar != null) {
      final ext = avatar.path.split('.').last.toLowerCase();
      var mediaType = MediaType('image', 'jpeg');
      if (ext == 'png') mediaType = MediaType('image', 'png');
      if (ext == 'webp') mediaType = MediaType('image', 'webp');

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          contentType: mediaType,
        ),
      );
    }

    if (coverPhoto != null) {
      final ext = coverPhoto.path.split('.').last.toLowerCase();
      var mediaType = MediaType('image', 'jpeg');
      if (ext == 'png') mediaType = MediaType('image', 'png');
      if (ext == 'webp') mediaType = MediaType('image', 'webp');

      request.files.add(
        await http.MultipartFile.fromPath(
          'cover_photo',
          coverPhoto.path,
          contentType: mediaType,
        ),
      );
    }

    final streamResponse = await _client.send(request);
    if (streamResponse.statusCode < 200 || streamResponse.statusCode >= 300) {
      throw Exception('Failed to upload media: ${streamResponse.statusCode}');
    }
  }
}
