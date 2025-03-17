part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess({required this.user});

  factory AuthSuccess.fromJson(Map<String, dynamic> json) {
    return AuthSuccess(user: UserModel.fromJson(json['user']));
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

class LogoutFailure extends AuthState {
  final String message;

  LogoutFailure(this.message);
}
