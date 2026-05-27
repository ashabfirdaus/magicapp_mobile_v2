import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userDataKey = 'user_data';
  static const String _expiresInKey = 'expires_in';

  static final TokenManager _instance = TokenManager._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  // Initialize SharedPreferences
  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Save token and user data
  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
    required UserModel user,
    int? expiresIn,
  }) async {
    await _ensureInitialized();
    await Future.wait([
      _prefs.setString(_accessTokenKey, accessToken),
      _prefs.setString(_tokenTypeKey, tokenType),
      _prefs.setString(_userDataKey, user.toJsonString()),
      if (expiresIn != null) _prefs.setInt(_expiresInKey, expiresIn),
    ]);
  }

  // Get access token
  String? getAccessToken() {
    _checkInitialized();
    return _prefs.getString(_accessTokenKey);
  }

  // Get token type
  String? getTokenType() {
    _checkInitialized();
    return _prefs.getString(_tokenTypeKey);
  }

  // Get full authorization header value
  String? getAuthorizationHeader() {
    _checkInitialized();
    final token = getAccessToken();
    final tokenType = getTokenType();

    if (token == null || tokenType == null) {
      return null;
    }

    return '$tokenType $token';
  }

  // Get user data
  UserModel? getUser() {
    _checkInitialized();
    final userJson = _prefs.getString(_userDataKey);
    if (userJson == null) {
      return null;
    }

    try {
      return UserModel.fromJsonString(userJson);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  // Get expires in
  int? getExpiresIn() {
    _checkInitialized();
    return _prefs.getInt(_expiresInKey);
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    _checkInitialized();
    return getAccessToken() != null && getUser() != null;
  }

  // Clear all auth data
  Future<void> clearToken() async {
    await _ensureInitialized();
    await Future.wait([
      _prefs.remove(_accessTokenKey),
      _prefs.remove(_tokenTypeKey),
      _prefs.remove(_userDataKey),
      _prefs.remove(_expiresInKey),
    ]);
  }

  // Ensure TokenManager is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  // Check if TokenManager is initialized (for getters)
  void _checkInitialized() {
    if (!_initialized) {
      throw Exception(
        'TokenManager not initialized. Call TokenManager().initialize() first.',
      );
    }
  }
}
