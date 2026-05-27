/// Konstanta Aplikasi
/// File ini berisi semua konstanta yang digunakan di seluruh aplikasi

class AppConstants {
  // App Info
  static const String appName = 'MagicApp';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Duration
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration loadingDuration = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Error Messages
  static const String errorNetworkMessage =
      'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';
  static const String errorServerMessage =
      'Terjadi kesalahan server. Coba lagi nanti.';
  static const String errorUnknownMessage =
      'Terjadi kesalahan yang tidak diketahui.';

  // Success Messages
  static const String loginSuccessMessage = 'Login berhasil!';
  static const String logoutSuccessMessage = 'Logout berhasil!';
  static const String registerSuccessMessage = 'Pendaftaran berhasil!';
  static const String updateProfileSuccessMessage =
      'Profil berhasil diperbarui!';
}
