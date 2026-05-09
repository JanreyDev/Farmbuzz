String resolveMediaUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return trimmed;
  }

  final path = uri.path;
  if (!path.startsWith('/uploads/')) {
    return trimmed;
  }

  final origin = uri.hasScheme && uri.host.isNotEmpty
      ? '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}'
      : '';
  if (origin.isEmpty) {
    return trimmed;
  }

  final uploadPath = path.startsWith('/') ? path.substring(1) : path;
  return '$origin/api/media?path=${Uri.encodeComponent(uploadPath)}';
}
