import 'package:flutter/material.dart';
import 'package:farmbuzz/core/network/api_config.dart';

/// Resolves a raw media URL for use in the app.
/// Handles absolute URLs, root-relative paths like `/uploads/...`,
/// and `uploads/...` paths by attaching the API host.
String resolveMediaUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return trimmed;
  }

  if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
    final normalizedAbsolute = _normalizeUploadsPath(uri);
    if (_isLoopbackHost(uri.host)) {
      final base = _mediaBaseUri;
      return normalizedAbsolute
          .replace(
            scheme: base.scheme,
            host: base.host,
            port: base.hasPort ? base.port : null,
          )
          .toString();
    }
    return normalizedAbsolute.toString();
  }

  final base = _mediaBaseUri;
  final rawPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  final normalizedPath = _normalizeUploadsPath(Uri(path: rawPath)).path;
  return base.resolve(normalizedPath).toString();
}

/// Returns true if [url] is a valid http/https URL with a non-empty host.
/// Use this before passing any URL to NetworkImage.
bool isValidHttpUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      uri.host.isNotEmpty &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}

/// Returns a [NetworkImage] for [url] if it is valid, otherwise null.
/// Always use this instead of NetworkImage(url) directly when url may be empty.
NetworkImage? safeNetworkImage(String? url) {
  if (!isValidHttpUrl(url)) return null;
  return NetworkImage(url!.trim());
}

Uri get _mediaBaseUri {
  final apiUri = Uri.parse(ApiConfig.baseUrl);
  return apiUri.replace(path: '', query: null, fragment: null);
}

bool _isLoopbackHost(String host) {
  final normalized = host.trim().toLowerCase();
  return normalized == 'localhost' ||
      normalized == '127.0.0.1' ||
      normalized == '10.0.2.2';
}

Uri _normalizeUploadsPath(Uri uri) {
  final path = uri.path;
  if (path.startsWith('/api/uploads/')) {
    return uri.replace(path: path.replaceFirst('/api/uploads/', '/uploads/'));
  }
  return uri;
}
