class AppSession {
  AppSession._();

  static String? _userName;
  static String? _mobileNumber;
  static String? _avatarUrl;

  static String get userName => _userName?.trim().isNotEmpty == true
      ? _userName!.trim()
      : 'Guest';

  static String? get mobileNumber => _mobileNumber;

  static String get avatarUrlOrEmpty => _avatarUrl?.trim() ?? '';

  static String get avatarUrl {
    final configured = _avatarUrl?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    return 'https://i.pravatar.cc/150?u=${Uri.encodeComponent(userName)}';
  }

  static bool get isLoggedIn =>
      _userName?.trim().isNotEmpty == true &&
      _mobileNumber?.trim().isNotEmpty == true;

  static void setUser({
    required String userName,
    required String mobileNumber,
    String? avatarUrl,
  }) {
    _userName = userName;
    _mobileNumber = mobileNumber;
    _avatarUrl = avatarUrl;
  }

  static void clear() {
    _userName = null;
    _mobileNumber = null;
    _avatarUrl = null;
  }
}
