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
    // Helper function to safely convert any value to String
    String toSafeString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    return UserModel(
      key: toSafeString(json['key'], ''),
      name: toSafeString(json['name'], ''),
      username: toSafeString(json['username'], ''),
      email: toSafeString(json['email'], ''),
      phone: toSafeString(json['phone'], ''),
      address: toSafeString(json['address'], ''),
      role: toSafeString(json['role'], ''),
      path: json['path'] != null ? toSafeString(json['path']) : null,
      referralCode: toSafeString(
        json['referral_code'] ?? json['referralCode'],
        '',
      ),
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
