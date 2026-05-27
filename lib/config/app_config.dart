/// Konfigurasi aplikasi MagicApp
/// File ini berisi pengaturan global aplikasi seperti domain API dan environment settings

class AppConfig {
  // API Configuration
  static const String apiDomain = 'https://api.example.com';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // User Endpoints
  static const String getUserEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile/update';

  // API Timeout
  static const int connectTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Helper method untuk mendapatkan full URL
  static String getFullUrl(String endpoint) {
    return '$apiDomain$endpoint';
  }

  // Helper method untuk mendapatkan login URL
  static String get loginUrl => getFullUrl(loginEndpoint);

  // Helper method untuk mendapatkan register URL
  static String get registerUrl => getFullUrl(registerEndpoint);

  // Helper method untuk mendapatkan logout URL
  static String get logoutUrl => getFullUrl(logoutEndpoint);

  // Helper method untuk mendapatkan refresh token URL
  static String get refreshTokenUrl => getFullUrl(refreshTokenEndpoint);

  // Helper method untuk mendapatkan user profile URL
  static String get userProfileUrl => getFullUrl(getUserEndpoint);

  // Helper method untuk mendapatkan update profile URL
  static String get updateProfileUrl => getFullUrl(updateProfileEndpoint);
}
