part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess({required this.user});

  factory AuthSuccess.fromJson(Map<String, dynamic> json) {
    return AuthSuccess(user: UserModel.fromJson(json["user"]));
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

final class LogoutFailure extends AuthState {
  final String message;

  LogoutFailure(this.message);
}
