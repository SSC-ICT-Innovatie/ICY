import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';

/// Service for caching and retrieving authentication state
/// This avoids BuildContext issues when checking auth state in widget disposal
class AuthCacheService {
  // Singleton instance
  static final AuthCacheService _instance = AuthCacheService._internal();

  factory AuthCacheService() {
    return _instance;
  }

  AuthCacheService._internal();

  // Cached state
  bool _isLoggedIn = false;

  /// Update the cached auth state
  void updateAuthState(bool isLoggedIn) {
    _isLoggedIn = isLoggedIn;
    print("Auth cache updated: isLoggedIn=$isLoggedIn");
  }

  /// Get cached auth state
  bool get isLoggedIn => _isLoggedIn;

  /// Check if user is logged in from context
  /// Updates the cache and returns the result
  bool checkLoggedIn(BuildContext context) {
    try {
      final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
      final isLoggedIn = authState is AuthSuccess;
      updateAuthState(isLoggedIn);
      print("Authentication status: $isLoggedIn");
      return isLoggedIn;
    } catch (e) {
      print("Auth check failed: $e - using cached value: $_isLoggedIn");
      return _isLoggedIn;
    }
  }
}
