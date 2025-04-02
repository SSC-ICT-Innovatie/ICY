part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial auth state, e.g. when app first loads
class AuthInitial extends AuthState {}

/// Loading state during authentication operations
class AuthLoading extends AuthState {}

/// Authentication successful state with user info
class AuthSuccess extends AuthState {
  final UserModel user;
  final String token;
  final String refreshToken;

  const AuthSuccess({
    required this.user,
    required this.token,
    this.refreshToken = '',
  });

  @override
  List<Object> get props => [user, token];
}

/// Authentication failure state with error message
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Logout state
class AuthLogout extends AuthState {}

/// Email verification state
class AuthVerificationSent extends AuthState {
  final String email;
  final String? verificationCode;

  const AuthVerificationSent(this.email, {this.verificationCode});

  @override
  List<Object> get props => [email];
}

class AuthVerificationSuccess extends AuthState {}

class AuthVerificationFailure extends AuthState {
  final String message;

  const AuthVerificationFailure(this.message);

  @override
  List<Object> get props => [message];
}
