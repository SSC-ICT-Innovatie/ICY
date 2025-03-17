import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
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

    // Print token for debugging
    print('Loaded auth token: ${_authToken?.substring(0, 10) ?? 'null'}');
  }

  // Headers with authorization
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Authentication-specific methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save tokens
        _authToken = data['token'];
        _refreshToken = data['refreshToken'];

        // Store tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConstants.authTokenKey, _authToken!);
        await prefs.setString(ApiConstants.refreshTokenKey, _refreshToken!);

        print('Login successful, token: ${_authToken?.substring(0, 10)}');
      } else {
        print('Login failed: ${data['message']}');
      }

      return data;
    } catch (e) {
      print('Login exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String department,
    String? avatarId,
    File? profileImage,
  ) async {
    try {
      print('Registering user: $email, name: $name, department: $department');

      if (profileImage == null) {
        // Standard JSON registration without image
        final response = await http.post(
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': name,
            'email': email,
            'password': password,
            'department': department,
            'username': email.split('@')[0], // Generate username from email
            if (avatarId != null) 'avatarId': avatarId,
          }),
        );

        final data = jsonDecode(response.body);
        _handleRegistrationResponse(response, data);
        return data;
      } else {
        // Multipart form for image upload
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint),
        );

        // Add text fields
        request.fields['fullName'] = name;
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.fields['department'] = department;
        request.fields['username'] = email.split('@')[0];
        if (avatarId != null) request.fields['avatarId'] = avatarId;

        // Add the image file
        var imageFile = await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
          filename: basename(profileImage.path),
        );
        request.files.add(imageFile);

        // Send the request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        final data = jsonDecode(response.body);
        _handleRegistrationResponse(response, data);
        return data;
      }
    } catch (e) {
      print('Registration exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Helper method to handle registration response
  void _handleRegistrationResponse(
    http.Response response,
    Map<String, dynamic> data,
  ) {
    if (response.statusCode == 201 && data['success'] == true) {
      // Save tokens
      _authToken = data['token'];
      _refreshToken = data['refreshToken'];

      // Store tokens
      _saveTokens();

      print('Registration successful, token: ${_authToken?.substring(0, 10)}');
    }
  }

  // Save tokens to shared preferences
  Future<void> _saveTokens() async {
    if (_authToken != null && _refreshToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.authTokenKey, _authToken!);
      await prefs.setString(ApiConstants.refreshTokenKey, _refreshToken!);
    }
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
      print('Logout error (ignoring): $e');
    } finally {
      // Clear tokens
      _authToken = null;
      _refreshToken = null;

      // Remove from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.authTokenKey);
      await prefs.remove(ApiConstants.refreshTokenKey);

      print('Logged out, tokens cleared');
    }
  }

  // API methods with automatic token refresh
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      if (_authToken == null) {
        print('GET $endpoint - No auth token available');
        // Instead of immediately throwing, we'll return an empty data response
        // This prevents crashes during initial app load or when auth state is in transition
        return {'success': false, 'message': 'Not authenticated', 'data': []};
      }

      final response = await http.get(
        Uri.parse(ApiConstants.baseUrl + endpoint),
        headers: _headers,
      );

      if (response.statusCode == 401 && _refreshToken != null) {
        print('Token expired, attempting refresh');
        final refreshed = await _refreshAuthToken();
        if (refreshed) {
          // Try again with new token
          return get(endpoint);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      // Log the error but return a structured error response instead of throwing
      print('API GET error for $endpoint: $e');
      return {
        'success': false,
        'message': 'Failed to fetch data: $e',
        'data': [],
      };
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

  // Handle API response with improved error handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      // Handle successful responses
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // For empty responses, create a consistent structure
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response with status code ${response.statusCode}',
          'data': [],
        };
      }

      // Handle error responses
      final message = data['message'] ?? 'Unknown error';
      print('API Error (${response.statusCode}): $message');

      return {'success': false, 'message': message, 'data': []};
    } catch (e) {
      // Handle parsing errors
      print('Response parsing error: $e');
      return {
        'success': false,
        'message': 'Error processing response: $e',
        'data': [],
      };
    }
  }
}
