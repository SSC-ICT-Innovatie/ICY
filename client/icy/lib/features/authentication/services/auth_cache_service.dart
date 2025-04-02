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
  String _userRole = 'user'; // Default role

  /// Update the cached auth state
  void updateAuthState(bool isLoggedIn) {
    _isLoggedIn = isLoggedIn;
    print("Auth cache updated: isLoggedIn=$isLoggedIn");
  }

  /// Update the cached user role
  void updateUserRole(String role) {
    _userRole = role;
    print("Auth cache updated: userRole=$role");
  }

  /// Get cached auth state
  bool get isLoggedIn => _isLoggedIn;

  /// Get cached user role
  String get userRole => _userRole;

  /// Check if user is logged in from context - with safety check for deactivated widgets
  /// Updates the cache and returns the result
  bool checkLoggedIn(BuildContext context) {
    try {
      if (!context.mounted) {
        print("Context is not mounted - using cached value: $_isLoggedIn");
        return _isLoggedIn;
      }

      final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
      final isLoggedIn = authState is AuthSuccess;
      updateAuthState(isLoggedIn);

      // Also update role if logged in
      if (isLoggedIn) {
        updateUserRole(authState.user.role);
      }

      print("Authentication status: $isLoggedIn");
      return isLoggedIn;
    } catch (e) {
      print("Auth check failed: $e - using cached value: $_isLoggedIn");
      return _isLoggedIn;
    }
  }

  /// Get user role from context or return cached role - with safety check for deactivated widgets
  String getUserRole(BuildContext context) {
    try {
      if (!context.mounted) {
        print("Context is not mounted - using cached value: $_userRole");
        return _userRole;
      }

      final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
      if (authState is AuthSuccess) {
        final role = authState.user.role;
        updateUserRole(role);
        return role;
      }
      return _userRole;
    } catch (e) {
      print("Role check failed: $e - using cached value: $_userRole");
      return _userRole;
    }
  }
}
