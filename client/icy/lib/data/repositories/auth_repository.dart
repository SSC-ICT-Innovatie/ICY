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
      return null;
    }
  }

  // Register a new user
  Future<UserModel?> signup(
    String name,
    String email,
    String password,
    String avatarId,
  ) async {
    try {
      final response = await _apiService.register(
        name,
        email,
        password,
        'Nieuwe Gebruiker', // Default department for new users
        avatarId,
      );

      if (response['success'] == true && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);

        // Save to local storage for persistence
        await _localStorageService.saveAuthUser(user);

        return user;
      }

      return null;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _apiService.logout();
    await _localStorageService.clearAuthUser();
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
