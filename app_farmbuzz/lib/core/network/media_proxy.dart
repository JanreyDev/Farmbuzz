import 'dart:io';

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
    return trimmed;
  }

  final base = _mediaBaseUri;
  final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return base.resolve(normalizedPath).toString();
}

Uri get _mediaBaseUri {
  const override = String.fromEnvironment('API_BASE_URL');
  final rawBase = override.isNotEmpty
      ? override
      : (Platform.isAndroid
            ? 'http://167.172.89.188:8083/api'
            : 'http://167.172.89.188:8083/api');

  final apiUri = Uri.parse(rawBase);
  return apiUri.replace(path: '', query: null, fragment: null);
}
