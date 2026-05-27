import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/index.dart';
import '../models/login_response_model.dart';
import 'token_manager.dart';

/// Model untuk response Check Account
class CheckAccountResponse {
  final bool success;
  final String? input;
  final bool isEmail;
  final bool isLogin;
  final String? message;

  CheckAccountResponse({
    required this.success,
    this.input,
    required this.isEmail,
    required this.isLogin,
    this.message,
  });

  factory CheckAccountResponse.fromJson(Map<String, dynamic> json) {
    return CheckAccountResponse(
      success: json['status'] == 'success' ? true : false,
      input: json['input'],
      isEmail: json['isemail'] ?? false,
      isLogin: json['islogin'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// Model untuk response Send OTP
class SendOtpResponse {
  final bool success;
  final String? message;
  final String? reference;

  SendOtpResponse({required this.success, this.message, this.reference});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['status'] == 'success' ? true : false,
      message: json['message'],
      reference: json['reference'],
    );
  }
}

// DEPRECATED: Gunakan LoginResponseModel dari models/login_response_model.dart
@Deprecated('Use LoginResponseModel instead')
class LoginResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? email;
  final String? phone;
  final String? name;
  final String? message;

  LoginResponse({
    required this.success,
    this.token,
    this.refreshToken,
    this.userId,
    this.email,
    this.phone,
    this.name,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['status'] == 'success' ? true : false,
      token: json['token'],
      refreshToken: json['refresh_token'],
      userId: json['user_id'],
      email: json['email'],
      phone: json['phone'],
      name: json['name'],
      message: json['message'],
    );
  }
}

/// Authentication Service untuk handle semua API calls
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final TokenManager _tokenManager = TokenManager();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Check if account exists
  Future<CheckAccountResponse> checkAccount(String username) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.checkAccountUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'username': username}),
          )
          .timeout(
            const Duration(milliseconds: ApiConfig.connectTimeout),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        return CheckAccountResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to check account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking account: $e');
    }
  }

  // Login with username and password
  // Returns LoginResponseModel sesuai format backend
  Future<LoginResponseModel> login({
    required String username,
    required String password,
    required bool isEmail,
  }) async {
    try {
      print('=== LOGIN REQUEST ===');
      print('Username: $username');
      print('Is Email: $isEmail');
      print('URL: ${ApiConfig.loginUrl}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
              'isemail': isEmail,
            }),
          )
          .timeout(
            const Duration(milliseconds: ApiConfig.connectTimeout),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      print('=== LOGIN RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.body.isNotEmpty) {
        final loginResponse =
            LoginResponseModel.fromJson(jsonDecode(response.body));

        // Jika login berhasil, simpan token dan user data
        if (loginResponse.success &&
            loginResponse.accessToken != null &&
            loginResponse.user != null) {
          await _tokenManager.saveToken(
            accessToken: loginResponse.accessToken!,
            tokenType: loginResponse.tokenType ?? 'bearer',
            user: loginResponse.user!,
            expiresIn: loginResponse.expiresIn,
          );
          print('Token saved to localStorage');
        }

        return loginResponse;
      } else {
        throw Exception(
          'Empty response from server (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Error during login: $e');
    }
  }

  // Send OTP via WhatsApp or Email
  Future<SendOtpResponse> sendOtp({
    required String input,
    required String type, // 'email' atau 'phone'
    bool? isEmail,
  }) async {
    try {
      final body = <String, dynamic>{
        'input': input,
        'type': type,
        if (isEmail != null) 'isemail': isEmail,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.sendOtpUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(milliseconds: ApiConfig.connectTimeout),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      if (response.statusCode == 200) {
        return SendOtpResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  // Verify OTP
  Future<LoginResponseModel> verifyOtp({
    required String code,
    required String input,
    required bool isEmail,
  }) async {
    try {
      final type = isEmail ? 'email' : 'phone';
      final body = <String, dynamic>{
        'code': code,
        'type': type,
        'input': input,
      };
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyOtpUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(milliseconds: ApiConfig.connectTimeout),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        final loginResponse =
            LoginResponseModel.fromJson(jsonDecode(response.body));

        // Jika OTP verification berhasil, simpan token dan user data
        if (loginResponse.success &&
            loginResponse.accessToken != null &&
            loginResponse.user != null) {
          await _tokenManager.saveToken(
            accessToken: loginResponse.accessToken!,
            tokenType: loginResponse.tokenType ?? 'bearer',
            user: loginResponse.user!,
            expiresIn: loginResponse.expiresIn,
          );
          print('Token saved to localStorage after OTP verification');
        }

        return loginResponse;
      } else {
        throw Exception('Failed to verify OTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }
}
