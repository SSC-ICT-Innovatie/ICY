import 'dart:io';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/services/api_service.dart';

class AuthRepository {
  final LocalStorageService _localStorageService;
  final ApiService _apiService;

  AuthRepository({
    LocalStorageService? localStorageService,
    ApiService? apiService,
  }) : _localStorageService = localStorageService ?? LocalStorageService(),
       _apiService = apiService ?? ApiService();

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      if (response['success'] == true && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);

        // Save auth info to local storage for persistence
        await _localStorageService.saveAuthUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow; // Rethrow to let the UI layer handle it
    }
  }

  // Request verification code
  Future<bool> requestVerificationCode(String email) async {
    try {
      final response = await _apiService.requestVerificationCode(email);
      return response['success'] == true;
    } catch (e) {
      print('Error requesting verification code: $e');
      rethrow;
    }
  }

  // Verify email code
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      final response = await _apiService.verifyEmailCode(email, code);
      return response['success'] == true;
    } catch (e) {
      print('Error verifying email code: $e');
      rethrow;
    }
  }

  // Register a new user with profile image and verification code
  Future<UserModel?> signup(
    String name,
    String email,
    String password,
    String avatarId, {
    File? profileImage,
    String? verificationCode,
  }) async {
    try {
      Map<String, dynamic> response;

      if (verificationCode != null) {
        // Use verification flow
        response = await _apiService.register(
          name,
          email,
          password,
          'ICT', // Default department
          avatarId,
          verificationCode,
          profileImage,
        );
      } else {
        // Use normal signup flow without verification
        response = await _apiService.simpleRegister(
          name,
          email,
          password,
          'ICT', // Default department
          avatarId,
          profileImage,
        );
      }

      if (response['success'] == true && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);

        // Save to local storage for persistence
        await _localStorageService.saveAuthUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('Signup error: $e');
      rethrow; // Rethrow to let the UI layer handle it
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      // Always clear local storage, even if API logout fails
      await _localStorageService.clearAuthUser();
    }
  }

  // Check if user is logged in
  Future<UserModel?> getCurrentUser() async {
    // First check local storage
    UserModel? cachedUser = await _localStorageService.getAuthUser();

    // If we have a cached user and API service has a token, verify with server
    if (cachedUser != null) {
      try {
        final response = await _apiService.get(
          ApiConstants.currentUserEndpoint,
        );
        if (response['success'] == true && response['data'] != null) {
          // Update cached user with fresh data
          final freshUserData = UserModel.fromJson(response['data']);
          await _localStorageService.saveAuthUser(freshUserData);
          return freshUserData;
        }
      } catch (e) {
        // If server verification fails, still return cached user
        // but print error for debugging
        print('Error fetching current user from server: $e');
      }
    }

    return cachedUser;
  }
}
