import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/datasources/local_storage_service.dart';

class AuthRepository {
  final LocalStorageService _localStorageService;

  AuthRepository({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService();

  // Load users from JSON file
  Future<List<UserModel>> _loadUsers() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/data/users.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> usersJson = jsonData['users'];

      return usersJson.map((userJson) => UserModel.fromJson(userJson)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      final List<UserModel> users = await _loadUsers();

      // In a real app, password would be hashed and properly compared
      final UserModel? user = users.firstWhere(
        (user) => user.email == email,
        orElse: () => null as UserModel,
      );

      if (user != null) {
        // Save auth info to local storage for persistence
        await _localStorageService.saveAuthUser(user);

        // Load user profile data
        final userProfile = await _loadUserProfile(user.id);
        if (userProfile != null) {
          // Combine user auth data with profile data
          return user.copyWith(
            level: userProfile.level,
            stats: userProfile.stats,
            preferences: userProfile.preferences,
          );
        }

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
      final List<UserModel> existingUsers = await _loadUsers();

      // Check if email already exists
      final bool emailExists = existingUsers.any((user) => user.email == email);
      if (emailExists) {
        throw Exception('Email already exists');
      }

      // Create new user (in a real app, this would be saved to backend)
      final UserModel newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: email.split('@')[0],
        email: email,
        fullName: name,
        avatar: 'https://placehold.co/400x400?text=$name',
        department: 'Nieuwe Gebruiker',
        role: 'user',
      );

      // Save to local storage for persistence
      await _localStorageService.saveAuthUser(newUser);

      // Create default profile for new user
      // In a real app, this would be done on the backend

      return newUser;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _localStorageService.clearAuthUser();
  }

  // Check if user is logged in
  Future<UserModel?> getCurrentUser() async {
    return await _localStorageService.getAuthUser();
  }

  // Load user profile data from user_data.json
  Future<UserProfileModel?> _loadUserProfile(String userId) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/data/user_data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> userDataList = jsonData['user_data'];
      final dynamic userData = userDataList.firstWhere(
        (data) => data['userId'] == userId,
        orElse: () => null,
      );

      if (userData != null) {
        return UserProfileModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }
}
