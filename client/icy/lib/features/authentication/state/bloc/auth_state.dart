part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  factory AuthSuccess.fromJson(Map<String, dynamic> json) {
    return AuthSuccess(user: User.fromJson(json["user"]));
  }

  AuthSuccess({required this.user});
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

final class LogoutFailure extends AuthState {
  final String message;

  LogoutFailure(this.message);
}

extension AuthSuccessToJson on AuthSuccess {
  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }

  static AuthSuccess fromJson(Map<String, dynamic> json) {
    return AuthSuccess(user: User.fromJson(json['user']));
  }
}
