import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        emit(AuthFailure("Failed to check authentication status"));
      }
    });

    on<AuthLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.login(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthFailure("Invalid email or password"));
        }
      } catch (e) {
        emit(AuthFailure("Login failed: ${e.toString()}"));
      }
    });

    on<SignUp>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signup(
          event.name,
          event.email,
          event.password,
          event.avatarId,
        );

        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthFailure("Failed to create account"));
        }
      } catch (e) {
        emit(AuthFailure("Sign up failed: ${e.toString()}"));
      }
    });

    on<Logout>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.logout();
        emit(AuthInitial());
      } catch (e) {
        emit(LogoutFailure("Logout failed: ${e.toString()}"));
      }
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final state = json['state'] as String?;
      if (state == 'auth_success') {
        return AuthSuccess.fromJson(json);
      }
    } catch (e) {
      print("Error deserializing AuthBloc state: $e");
    }
    return AuthInitial();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthSuccess) {
      return {'state': 'auth_success', 'user': state.user.toJson()};
    }
    return null;
  }
}
