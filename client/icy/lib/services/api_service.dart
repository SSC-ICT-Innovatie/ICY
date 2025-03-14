import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icy/abstractions/utils/api_constants.dart';

class ApiService {
  // Singleton for app-wide access
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Authentication token management
  String? _authToken;
  String? _refreshToken;

  // Initialize - load tokens from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(ApiConstants.authTokenKey);
    _refreshToken = prefs.getString(ApiConstants.refreshTokenKey);
  }

  // Headers with authorization
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Authentication-specific methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Save tokens
      _authToken = data['token'];
      _refreshToken = data['refreshToken'];

      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.authTokenKey, _authToken!);
      await prefs.setString(ApiConstants.refreshTokenKey, _refreshToken!);
    }

    return data;
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String department,
    String? avatarId,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
        'department': department,
        if (avatarId != null) 'avatarId': avatarId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Save tokens
      _authToken = data['token'];
      _refreshToken = data['refreshToken'];

      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.authTokenKey, _authToken!);
      await prefs.setString(ApiConstants.refreshTokenKey, _refreshToken!);
    }

    return data;
  }

  // Logout
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.logoutEndpoint),
        headers: _headers,
      );
    } catch (e) {
      // Ignore errors on logout
    } finally {
      // Clear tokens
      _authToken = null;
      _refreshToken = null;

      // Remove from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.authTokenKey);
      await prefs.remove(ApiConstants.refreshTokenKey);
    }
  }

  // API methods with automatic token refresh
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.baseUrl + endpoint),
        headers: _headers,
      );

      if (response.statusCode == 401 && _refreshToken != null) {
        final refreshed = await _refreshAuthToken();
        if (refreshed) {
          // Try again with new token
          return get(endpoint);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + endpoint),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 401 && _refreshToken != null) {
        final refreshed = await _refreshAuthToken();
        if (refreshed) {
          // Try again with new token
          return post(endpoint, data);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // PUT request with automatic token refresh
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.baseUrl + endpoint),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 401 && _refreshToken != null) {
        final refreshed = await _refreshAuthToken();
        if (refreshed) {
          // Try again with new token
          return put(endpoint, data);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  // Refresh token
  Future<bool> _refreshAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.refreshTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];

        // Update stored token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConstants.authTokenKey, _authToken!);

        return true;
      }

      // Refresh failed, clear tokens
      _authToken = null;
      _refreshToken = null;

      // Remove from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.authTokenKey);
      await prefs.remove(ApiConstants.refreshTokenKey);

      return false;
    } catch (e) {
      return false;
    }
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      // Handle error responses
      final message = data['message'] ?? 'Unknown error';
      throw Exception(message);
    }
  }
}
