import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/user_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  // Initialize SharedPreferences
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Auth token operations
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(ApiConstants.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return _prefs.getString(ApiConstants.authTokenKey);
  }

  // Refresh token operations
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(ApiConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(ApiConstants.refreshTokenKey);
  }

  // User operations
  Future<void> saveAuthUser(UserModel user) async {
    await _prefs.setString(ApiConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getAuthUser() async {
    final userJson = _prefs.getString(ApiConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await _prefs.remove(ApiConstants.authTokenKey);
    await _prefs.remove(ApiConstants.refreshTokenKey);
    await _prefs.remove(ApiConstants.userKey);
  }

  // Theme operations
  Future<void> saveTheme(String themeName) async {
    await _prefs.setString(ApiConstants.themeKey, themeName);
  }

  Future<String?> getTheme() async {
    return _prefs.getString(ApiConstants.themeKey);
  }

  // Language operations
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(ApiConstants.languageKey, languageCode);
  }

  Future<String?> getLanguage() async {
    return _prefs.getString(ApiConstants.languageKey);
  }
}
