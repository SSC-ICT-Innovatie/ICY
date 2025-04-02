import 'dart:convert';
import 'package:icy/data/models/user_model.dart';

/// This model extends the base User model with authentication-specific properties
class AuthUser {
  final UserModel baseUser;
  final bool isVerified;
  final DateTime? lastLogin;
  final List<String>? permissions;

  AuthUser({
    required this.baseUser,
    this.isVerified = false,
    this.lastLogin,
    this.permissions,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      baseUser: UserModel.fromJson(json),
      isVerified: json['isVerified'] ?? false,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      permissions:
          json['permissions'] != null
              ? List<String>.from(json['permissions'])
              : null,
    );
  }

  // Forward common properties from base user
  String get id => baseUser.id;
  String get fullName => baseUser.fullName;
  String get email => baseUser.email;
  String get username => baseUser.username;
  String get department => baseUser.department;
  String get role => baseUser.role;
  String get avatar => baseUser.avatar;

  // Helper properties
  bool get isAdmin => role == 'admin';
  bool get isTeamLead => role == 'team_lead';

  // Convert to JSON including all fields
  Map<String, dynamic> toJson() {
    final baseJson = baseUser.toJson();

    return {
      ...baseJson,
      'isVerified': isVerified,
      'lastLogin': lastLogin?.toIso8601String(),
      'permissions': permissions,
    };
  }
}
