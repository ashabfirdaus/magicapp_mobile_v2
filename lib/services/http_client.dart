import 'package:http/http.dart' as http;
import 'token_manager.dart';

/// Custom HTTP client yang secara otomatis menambahkan Authorization header
class AuthenticatedHttpClient extends http.BaseClient {
  final TokenManager _tokenManager;

  AuthenticatedHttpClient({TokenManager? tokenManager})
    : _tokenManager = tokenManager ?? TokenManager();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add authorization header jika token ada
    final authHeader = _tokenManager.getAuthorizationHeader();
    if (authHeader != null) {
      request.headers['Authorization'] = authHeader;
    }

    // Add default headers
    request.headers['Accept'] = 'application/json';
    request.headers['Content-Type'] = 'application/json';

    print('Request: ${request.method} ${request.url}');
    if (authHeader != null) {
      print('Authorization: $authHeader');
    }

    return request.send();
  }
}

/// Factory untuk membuat HTTP clients
class HttpClientFactory {
  static final TokenManager _tokenManager = TokenManager();

  // Get authenticated HTTP client untuk request yang butuh token
  static http.Client getAuthenticatedClient() {
    return AuthenticatedHttpClient(tokenManager: _tokenManager);
  }

  // Get regular HTTP client untuk request tanpa token (login, register, dll)
  static http.Client getPublicClient() {
    return http.Client();
  }
}
