import 'dart:io';

import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  AuthRepository({
    ApiService? apiService,
    LocalStorageService? localStorageService,
  }) : _apiService = apiService ?? ApiService(),
       _localStorageService = localStorageService ?? LocalStorageService();

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      if (response['success'] == true && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);

        // Save auth token
        if (response['token'] != null) {
          await _localStorageService.saveAuthToken(response['token']);
        }

        // Save user data
        await _localStorageService.saveAuthUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<UserModel?> signup(
    String name,
    String email,
    String password,
    String avatarId, {
    String? department,
    File? profileImage,
    String? verificationCode,
  }) async {
    try {
      final response = await _apiService.register(
        name,
        email,
        password,
        avatarId,
        department,
        verificationCode ?? '',
        profileImage,
      );

      if (response['success'] == true && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);

        // Save auth token
        if (response['token'] != null) {
          await _localStorageService.saveAuthToken(response['token']);
        }

        // Save user data
        await _localStorageService.saveAuthUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // Try to get cached user first
      final cachedUser = await _localStorageService.getAuthUser();

      // If token exists, try to get fresh user data
      if (await _localStorageService.getAuthToken() != null) {
        try {
          final response = await _apiService.get(
            ApiConstants.currentUserEndpoint,
          );

          if (response['success'] == true && response['data'] != null) {
            final updatedUser = UserModel.fromJson(response['data']);
            await _localStorageService.saveAuthUser(updatedUser);
            return updatedUser;
          }
        } catch (e) {
          print('Error fetching current user: $e');
          // If API fails, return cached user if available
          if (cachedUser != null) return cachedUser;
        }
      }

      return cachedUser;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      // Call logout API
      await _apiService.post(ApiConstants.logoutEndpoint, {});

      // Clear local storage regardless of API response
      await _localStorageService.clearAuthData();

      return true;
    } catch (e) {
      print('Logout error: $e');

      // Still clear local storage even if API call fails
      await _localStorageService.clearAuthData();

      return true;
    }
  }

  // Request email verification code
  Future<bool> requestVerificationCode(String email) async {
    try {
      final response = await _apiService.post(
        ApiConstants.requestVerificationCodeEndpoint,
        {'email': email},
      );

      if (response['success'] == true) {
        // In development mode, the server might return the code directly
        if (response.containsKey('devCode')) {
          print(
            'Development mode: Received verification code: ${response['devCode']}',
          );
          // Save the dev code for later use
          await _localStorageService.saveData(
            'dev_verification_code',
            response['devCode'],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error requesting verification code: $e');
      return false;
    }
  }

  // Verify email code
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      // In development mode, check if we have a stored dev code
      final storedDevCode = await _localStorageService.getData(
        'dev_verification_code',
      );
      if (storedDevCode != null && code == storedDevCode.toString()) {
        print('Development mode: Verification code matched');
        return true;
      }

      final response = await _apiService.post(
        ApiConstants.verifyEmailCodeEndpoint,
        {'email': email, 'code': code},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error verifying email code: $e');
      return false;
    }
  }
}
