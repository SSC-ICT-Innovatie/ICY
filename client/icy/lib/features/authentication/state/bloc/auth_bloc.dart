import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/repositories/auth_repository.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogin>(_onAuthLogin);
    on<SignUp>(_onSignUp);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<Logout>(_onLogout);

    // Immediately check authentication state when created
    add(AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user: user));
        // Update auth cache
        AuthCacheService().updateAuthState(true);
      } else {
        emit(AuthInitial());
        // Update auth cache
        AuthCacheService().updateAuthState(false);
      }
    } catch (e) {
      print("Auth check failed: ${e.toString()}");
      emit(AuthInitial());
      // Update auth cache
      AuthCacheService().updateAuthState(false);
    }
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
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
  }

  Future<void> _onSignUp(SignUp event, Emitter<AuthState> emit) async {
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
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('Department being sent: ${event.department}'); // Debug print
      final UserModel? user = await _authRepository.signup(
        event.name,
        event.email,
        event.password,
        event.avatarId ?? '0', // Default to '0' if null
        department: event.department, // Explicitly pass department
        profileImage: event.profileImage,
        verificationCode: event.verificationCode,
      );

      if (user != null) {
        emit(AuthSuccess(user: user));
        print('AuthBloc: Emitted AuthSuccess after signup');

        // Update the cached auth state
        AuthCacheService().updateAuthState(true);
      } else {
        emit(AuthFailure('Signup failed. Please try again.'));
        print('AuthBloc: Emitted AuthFailure - user was null');

        // Update the cached auth state
        AuthCacheService().updateAuthState(false);
      }
    } catch (e) {
      print('AuthBloc: Exception during signup: $e');
      emit(AuthFailure('Signup error: ${e.toString()}'));

      // Update the cached auth state
      AuthCacheService().updateAuthState(false);
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(LogoutFailure("Logout failed: ${e.toString()}"));
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final stateType = json['stateType'] as String?;
      if (stateType == 'auth_success') {
        final authSuccess = AuthSuccess.fromJson(json);
        // Update auth cache when state is hydrated
        AuthCacheService().updateAuthState(true);
        return authSuccess;
      }
    } catch (e) {
      print("Error deserializing AuthBloc state: $e");
    }
    return AuthInitial();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthSuccess) {
      return {'stateType': 'auth_success', 'user': state.user.toJson()};
    }
    return null;
  }
}
