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

class Logout extends AuthEvent {}
