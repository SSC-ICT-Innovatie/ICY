import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/repositories/auth_repository.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AuthCacheService _authCacheService;

  AuthBloc({AuthRepository? authRepository, AuthCacheService? authCacheService})
    : _authRepository = authRepository ?? AuthRepository(),
      _authCacheService = authCacheService ?? AuthCacheService(),
      super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogin>(_onAuthLogin);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<UpdateUserData>(_onUpdateUserData);
    on<Logout>(_onLogout);

    // Check if already logged in on startup
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
        _authCacheService.updateAuthState(true);
        _authCacheService.updateUserRole(user.role);

        // Get tokens from local storage
        final token = await _authRepository.getAuthToken();
        final refreshToken = await _authRepository.getRefreshToken();

        emit(
          AuthSuccess(
            user: user,
            token: token ?? '',
            refreshToken: refreshToken ?? '',
          ),
        );
      } else {
        _authCacheService.updateAuthState(false);
        emit(AuthInitial());
      }
    } catch (e) {
      _authCacheService.updateAuthState(false);
      emit(AuthInitial());
    }
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.email, event.password);
      if (user != null) {
        _authCacheService.updateAuthState(true);
        _authCacheService.updateUserRole(user.role);

        // Get tokens from local storage
        final token = await _authRepository.getAuthToken();
        final refreshToken = await _authRepository.getRefreshToken();

        emit(
          AuthSuccess(
            user: user,
            token: token ?? '',
            refreshToken: refreshToken ?? '',
          ),
        );
      } else {
        _authCacheService.updateAuthState(false);
        emit(const AuthFailure('Login failed. Please try again.'));
      }
    } catch (e) {
      _authCacheService.updateAuthState(false);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signup(
        event.name,
        event.email,
        event.password,
        event.avatarId ?? '1',
        department: event.department,
        profileImage: event.profileImage,
        verificationCode: event.verificationCode,
        isAdmin: event.isAdmin, // Pass the isAdmin flag
      );

      if (user != null) {
        _authCacheService.updateAuthState(true);
        _authCacheService.updateUserRole(user.role);

        // Get tokens from local storage
        final token = await _authRepository.getAuthToken();
        final refreshToken = await _authRepository.getRefreshToken();

        emit(
          AuthSuccess(
            user: user,
            token: token ?? '',
            refreshToken: refreshToken ?? '',
          ),
        );
      } else {
        _authCacheService.updateAuthState(false);
        emit(const AuthFailure('Signup failed. Please try again.'));
      }
    } catch (e) {
      _authCacheService.updateAuthState(false);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUserData(
    UpdateUserData event,
    Emitter<AuthState> emit,
  ) async {
    // Get current state and preserve tokens
    if (state is AuthSuccess) {
      final currentState = state as AuthSuccess;
      
      // Save updated user data to local storage
      await _authRepository.localStorageService.saveAuthUser(event.user);
      
      // Update cache
      _authCacheService.updateUserRole(event.user.role);
      
      // Emit updated state with new user data but preserve tokens
      emit(AuthSuccess(
        user: event.user,
        token: currentState.token,
        refreshToken: currentState.refreshToken,
      ));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      _authCacheService.updateAuthState(false);
      _authCacheService.updateUserRole('user');
      emit(AuthLogout());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
