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

    return LoginResponseModel(
      success: isSuccess,
      message: json['message'] as String? ?? '',
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
      user: userData,
    );
  }

  @override
  String toString() {
    return 'LoginResponseModel(success: $success, message: $message, accessToken: $accessToken, user: $user)';
  }
}
