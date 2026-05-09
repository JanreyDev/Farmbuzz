/// Resolves a raw media URL for use in the app.
/// Images in /uploads/ are publicly accessible directly — no proxy needed.
String resolveMediaUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return trimmed;
  }

  // Already a valid http/https URL — return as-is (direct public access)
  if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return trimmed;
  }

  return trimmed;
}
