class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl = 'http://167.172.89.188:8083/api';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    return override.isNotEmpty ? override : defaultBaseUrl;
  }
}
