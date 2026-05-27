import 'user_model.dart';

class LoginResponseModel {
  final bool success;
  final String message;
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;
  final UserModel? user;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'status' field (from backend) and 'success' field
    final isSuccess = json['status'] == 'success' || json['success'] == true;

    UserModel? userData;
    if (json['user'] != null) {
      userData = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    }

    // Helper to safely convert to string
    String toSafeString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    // Helper to safely convert to int
    int? toSafeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return LoginResponseModel(
      success: isSuccess,
      message: toSafeString(json['message'], ''),
      accessToken: json['access_token'] != null
          ? toSafeString(json['access_token'])
          : null,
      tokenType: json['token_type'] != null
          ? toSafeString(json['token_type'])
          : null,
      expiresIn: toSafeInt(json['expires_in']),
      user: userData,
    );
  }

  @override
  String toString() {
    return 'LoginResponseModel(success: $success, message: $message, accessToken: $accessToken, user: $user)';
  }
}
