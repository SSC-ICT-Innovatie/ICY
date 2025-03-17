part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

class SignUp extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String avatarId;

  SignUp({
    required this.name,
    required this.email,
    required this.password,
    required this.avatarId,
  });
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? avatarId;
  final String department;
  final File? profileImage; // Add profile image support

  AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    this.avatarId,
    required this.department,
    this.profileImage,
  });
}

class Logout extends AuthEvent {}
