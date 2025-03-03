part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLogin extends AuthEvent {
  final User user;

  AuthLogin({required this.user});
}

class SignUp extends AuthEvent {
  final User user;

  SignUp({required this.user});
}

class Logout extends AuthEvent {}
