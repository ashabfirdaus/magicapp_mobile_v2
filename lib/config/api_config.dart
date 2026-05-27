/// Environment-specific API Configuration
/// Gunakan file ini untuk mengelola API domain berdasarkan environment (dev, staging, production)

enum Environment { development, staging, production }

class ApiConfig {
  static Environment _currentEnvironment = Environment.development;

  // Set environment saat aplikasi start
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  static Environment get environment => _currentEnvironment;

  // API Domain berdasarkan environment
  static String get apiDomain {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://192.168.1.7:8081/api'; // Local Development API
      case Environment.staging:
        return 'https://staging-api.magiclaundry.biz.id/api';
      case Environment.production:
        return 'http://192.168.1.7:8081/api'; // Production Magic Laundry
    }
  }

  // API Endpoints (Magic Laundry - Authentication)
  static const String checkAccountEndpoint = '/auth/check-account';
  static const String loginEndpoint = '/auth/login';
  static const String sendOtpEndpoint = '/auth/login-number';
  static const String verifyOtpEndpoint = '/auth/verification-otp';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // User Endpoints
  static const String getUserEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile/update';
  static const String changePasswordEndpoint = '/users/change-password';

  // Timeout Configuration
  static const int connectTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
  static const int sendTimeout = 30000; // milliseconds

  // Helper Methods untuk Full URL
  static String getFullUrl(String endpoint) => '$apiDomain$endpoint';

  // Auth Endpoints Full URLs
  static String get checkAccountUrl => getFullUrl(checkAccountEndpoint);
  static String get loginUrl => getFullUrl(loginEndpoint);
  static String get sendOtpUrl => getFullUrl(sendOtpEndpoint);
  static String get verifyOtpUrl => getFullUrl(verifyOtpEndpoint);
  static String get registerUrl => getFullUrl(registerEndpoint);
  static String get logoutUrl => getFullUrl(logoutEndpoint);
  static String get refreshTokenUrl => getFullUrl(refreshTokenEndpoint);
  static String get forgotPasswordUrl => getFullUrl(forgotPasswordEndpoint);
  static String get resetPasswordUrl => getFullUrl(resetPasswordEndpoint);

  // User Endpoints Full URLs
  static String get userProfileUrl => getFullUrl(getUserEndpoint);
  static String get updateProfileUrl => getFullUrl(updateProfileEndpoint);
  static String get changePasswordUrl => getFullUrl(changePasswordEndpoint);

  // Debug Info
  static void printConfig() {
    print('=== API Configuration ===');
    print('Environment: $_currentEnvironment');
    print('API Domain: $apiDomain');
    print('Connect Timeout: $connectTimeout ms');
    print('Receive Timeout: $receiveTimeout ms');
    print('======================');
  }
}
