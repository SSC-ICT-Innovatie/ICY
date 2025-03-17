import 'dart:convert';
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String USER_KEY = 'auth_user';
  static const String _authUserKey = 'auth_user';

  // Save user to SharedPreferences
  Future<void> saveAuthUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authUserKey, json.encode(user.toJson()));
  }

  // Get user from SharedPreferences
  Future<UserModel?> getAuthUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_authUserKey);

    if (userJson == null) {
      return null;
    }

    try {
      return UserModel.fromJson(json.decode(userJson));
    } catch (e) {
      print('Error parsing auth user: $e');
      return null;
    }
  }

  // Clear user from SharedPreferences
  Future<void> clearAuthUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authUserKey);
  }

  // Save any generic data
  Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, json.encode(value));
    }
  }

  // Get any generic data
  Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  // Clear specific data
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.refreshTokenKey);
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.authTokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
    await prefs.remove(USER_KEY);
  }
}
