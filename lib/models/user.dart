// lib/models/user.dart
class User {
  final String id;
  final String email;
  final bool isEmailVerified;
  final bool isTwoFactorEnabled;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    required this.isTwoFactorEnabled,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isTwoFactorEnabled: json['is_two_factor_enabled'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_email_verified': isEmailVerified,
      'is_two_factor_enabled': isTwoFactorEnabled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}