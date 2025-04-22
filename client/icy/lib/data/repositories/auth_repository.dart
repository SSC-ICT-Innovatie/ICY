import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'; // Add this import for FormData and MultipartFile
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/abstractions/utils/network_diagnostics.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/services/api_service.dart';

class AuthRepository {
  final ApiService apiService;
  final LocalStorageService localStorageService;

  AuthRepository({
    ApiService? apiService,
    LocalStorageService? localStorageService,
  }) : apiService = apiService ?? ApiService(),
       localStorageService = localStorageService ?? LocalStorageService();

  Future<UserModel?> login(String email, String password) async {
    try {
      // Run connection diagnostics before making the request
      await NetworkDiagnostics.checkServerConnection();

      final data = await apiService.login(email, password);

      if (data['success'] == true &&
          data['user'] != null &&
          data['token'] != null) {
        final UserModel user = UserModel.fromJson(data['user']);

        // Save tokens
        await localStorageService.saveAuthToken(data['token']);
        if (data['refreshToken'] != null) {
          await localStorageService.saveRefreshToken(data['refreshToken']);
        }

        // Save user data
        await localStorageService.saveAuthUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
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
    bool isAdmin = false, // Add isAdmin parameter
  }) async {
    try {
      // Prepare form data
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'avatarId': avatarId,
        // If admin, use 'admin' as department and set role to admin
        'department': department ?? 'general',
        'role': isAdmin ? 'admin' : 'user', // Set role based on isAdmin flag
      };

      if (verificationCode != null) {
        data['verificationCode'] = verificationCode;
      }

      // Handle file upload
      dynamic requestData = data;
      bool hasFormData = false;

      if (profileImage != null) {
        final formData = FormData.fromMap({
          ...data,
          'profileImage': await MultipartFile.fromFile(
            profileImage.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });
        requestData = formData;
        hasFormData = true;
      }

      // Register user
      final response = await apiService.post(
        ApiConstants.registerEndpoint,
        requestData,
        useFormData: hasFormData,
      );

      print('Signup response: ${json.encode(response)}');

      if (response['success'] && response['token'] != null) {
        // Save auth tokens
        await localStorageService.saveAuthToken(response['token']);
        await localStorageService.saveRefreshToken(response['refreshToken']);

        // Save user object if available
        if (response['user'] != null) {
          final user = UserModel.fromJson(response['user']);
          await localStorageService.saveAuthUser(user);
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Error during signup: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await localStorageService.getAuthUser();
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await apiService.logout();
    } catch (e) {
      print('Logout error from API: $e');
      // Continue with local logout even if API call fails
    } finally {
      // Always clear local auth data
      await localStorageService.clearAuthData();
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await localStorageService.getAuthToken();
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await localStorageService.getRefreshToken();
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  // Request email verification code
  // Updated to return a proper result object instead of a String?
  Future<VerificationResult> requestVerificationCode(String email) async {
    try {
      // Run connection diagnostics before making the request
      await NetworkDiagnostics.checkServerConnection();

      final url =
          '${ApiConstants.apiBaseUrl}${ApiConstants.requestVerificationEndpoint}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // In development mode, the server returns the code in the response
          final code = data['devCode'] as String?;
          return VerificationResult(
            success: true,
            code: code,
            message:
                code != null
                    ? 'Code retrieved for development'
                    : 'Code sent to email',
          );
        }
        return VerificationResult(
          success: true,
          message: 'Verification code sent to email',
        );
      }

      return VerificationResult(
        success: false,
        message: 'Request failed with status: ${response.statusCode}',
      );
    } catch (e) {
      print('Error requesting verification code: $e');
      return VerificationResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Verify email code
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      // Run connection diagnostics before making the request
      await NetworkDiagnostics.checkServerConnection();

      final url =
          '${ApiConstants.apiBaseUrl}${ApiConstants.verifyEmailCodeEndpoint}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error verifying email code: $e');
      return false;
    }
  }
}

// Add this class to properly handle verification code results
class VerificationResult {
  final bool success;
  final String? code;
  final String message;

  VerificationResult({required this.success, this.code, required this.message});
}
