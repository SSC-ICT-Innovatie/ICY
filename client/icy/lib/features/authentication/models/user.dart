import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;
  final String photoUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
  });

  // Convert User instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  // Create User instance from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  // Convert User instance to JSON string
  String toJson() => json.encode(toMap());

  // Create User instance from JSON string
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
