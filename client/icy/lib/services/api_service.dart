import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/datasources/local_storage_service.dart';

class ApiService {
  final http.Client _client;
  final String baseUrl;
  final LocalStorageService _localStorageService;
  bool _isRefreshing = false;

  ApiService({
    http.Client? client,
    String? url,
    LocalStorageService? localStorageService,
  }) : _client = client ?? http.Client(),
       baseUrl = url ?? ApiConstants.apiBaseUrl,
       _localStorageService = localStorageService ?? LocalStorageService();

  Future<void> init() async {
    final token = await _getAuthToken();
    print(
      'API Service initialized ${token != null ? 'with' : 'without'} auth token',
    );
  }

  Future<String?> _getAuthToken() async {
    return _localStorageService.getAuthToken();
  }

  Future<String?> _getRefreshToken() async {
    return _localStorageService.getRefreshToken();
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;

    try {
      _isRefreshing = true;
      final refreshToken = await _getRefreshToken();

      if (refreshToken == null) {
        _isRefreshing = false;
        return false;
      }

      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConstants.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['token'] != null) {
          await _localStorageService.saveAuthToken(responseData['token']);

          if (responseData['refreshToken'] != null) {
            await _localStorageService.saveRefreshToken(
              responseData['refreshToken'],
            );
          }

          _isRefreshing = false;
          return true;
        }
      }

      // If refreshing failed, clear auth data
      await _localStorageService.clearAuthData();
      _isRefreshing = false;
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      _isRefreshing = false;
      return false;
    }
  }

  // Add this method to handle token expired errors
  Future<bool> _handleTokenExpiredError(http.Response response) async {
    // Check if response indicates token expired
    bool isTokenExpired = false;

    try {
      final responseData = json.decode(response.body);
      isTokenExpired =
          response.statusCode == 401 &&
          (responseData['message']?.toString().toLowerCase().contains(
                'expired',
              ) ??
              false);
    } catch (e) {
      isTokenExpired = response.statusCode == 401;
    }

    if (isTokenExpired) {
      // Try to refresh the token
      final refreshed = await _refreshToken();
      return refreshed;
    }

    return false;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final String url = '$baseUrl${ApiConstants.loginEndpoint}';
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String avatarId,
    String? department,
    String verificationCode,
    File? profileImage,
  ) async {
    try {
      if (profileImage != null) {
        // If we have a profile image, use multipart request

        // Create a multipart request
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${baseUrl}${ApiConstants.registerEndpoint}'),
        );

        // Add regular fields
        request.fields.addAll({
          'name': name,
          'email': email,
          'password': password,
          'avatarId': avatarId,
          'department': department??'ICT',
          'verificationCode': verificationCode,
        });

        // Add file
        request.files.add(
          await http.MultipartFile.fromPath('profileImage', profileImage.path),
        );

        // Add authorization header if needed
        final token = await _getAuthToken();
        if (token != null) {
          request.headers.addAll({'Authorization': 'Bearer $token'});
        }

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        // Handle response
        if (response.statusCode == 200 || response.statusCode == 201) {
          return json.decode(response.body);
        } else {
          print('Error status code: ${response.statusCode}');
          print('Error body: ${response.body}');
          throw Exception('Failed to register user: ${response.body}');
        }
      } else {
        // If no profile image, use regular post
        return await post(ApiConstants.registerEndpoint, {
          'name': name,
          'email': email,
          'password': password,
          'avatarId': avatarId,
          'department': department,
          'verificationCode': verificationCode,
        });
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _getAuthToken();
      final String url = '$baseUrl${ApiConstants.logoutEndpoint}';
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _localStorageService.clearAuthData();
      return _processResponse(response);
    } catch (e) {
      await _localStorageService
          .clearAuthData(); // Clear even if API call fails
      throw Exception('Logout failed: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _getAuthToken();
      final String url = '$baseUrl$endpoint';
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      var response = await _client.get(Uri.parse(url), headers: headers);

      // If token expired, try refreshing and retry request
      if (await _handleTokenExpiredError(response)) {
        // Get new token after refresh
        final newToken = await _getAuthToken();
        headers['Authorization'] = 'Bearer $newToken';

        // Retry the request
        response = await _client.get(Uri.parse(url), headers: headers);
      }

      return _processResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _getAuthToken();
      final String url = '$baseUrl$endpoint';
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      var response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      // If token expired, try refreshing and retry request
      if (await _handleTokenExpiredError(response)) {
        // Get new token after refresh
        final newToken = await _getAuthToken();
        headers['Authorization'] = 'Bearer $newToken';

        // Retry the request
        response = await _client.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );
      }

      return _processResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _getAuthToken();
      final String url = '$baseUrl$endpoint';
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      var response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      // If token expired, try refreshing and retry request
      if (await _handleTokenExpiredError(response)) {
        // Get new token after refresh
        final newToken = await _getAuthToken();
        headers['Authorization'] = 'Bearer $newToken';

        // Retry the request
        response = await _client.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );
      }

      return _processResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getAuthToken();
      final String url = '$baseUrl$endpoint';
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      var response = await _client.delete(Uri.parse(url), headers: headers);

      // If token expired, try refreshing and retry request
      if (await _handleTokenExpiredError(response)) {
        // Get new token after refresh
        final newToken = await _getAuthToken();
        headers['Authorization'] = 'Bearer $newToken';

        // Retry the request
        response = await _client.delete(Uri.parse(url), headers: headers);
      }

      return _processResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return {'success': true};
      }

      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: ${response.body}');
      }
    } else {
      // Error
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error occurred';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    }
  }
}
