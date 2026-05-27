import 'dart:convert';

class UserModel {
  final String key; // user id
  final String name;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String? path; // avatar/image path
  final String referralCode;

  UserModel({
    required this.key,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.path,
    required this.referralCode,
  });

  // Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'path': path,
      'referralCode': referralCode,
    };
  }

  // Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      role: json['role'] as String? ?? '',
      path: json['path'] as String?,
      referralCode:
          json['referral_code'] as String? ??
          json['referralCode'] as String? ??
          '',
    );
  }

  // Convert to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create model from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() => 'UserModel(key: $key, name: $name, email: $email)';
}
