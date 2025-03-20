import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/datasources/local_storage_service.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final LocalStorageService _localStorageService;

  ApiService({
    http.Client? client,
    String? baseUrl,
    LocalStorageService? localStorageService,
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl ?? ApiConstants.baseUrl,
       _localStorageService = localStorageService ?? LocalStorageService();

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    return _localStorageService.getAuthToken();
  }

  // Helper to handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // Helper to handle error responses
  Exception _handleError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'Unknown error occurred';
      return Exception(message);
    } catch (e) {
      return Exception('Server error [${response.statusCode}]');
    }
  }



  // Add an initialization method
  Future<void> init() async {
    final token = await _getAuthToken();
    print(
      'API Service initialized ${token != null ? 'with' : 'without'} auth token',
    );
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.get(url, headers: headers);
    return _handleResponse(response);
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await _getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await _getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');
    final response = await _client.delete(url, headers: headers);
    return _handleResponse(response);
  }

  // Login
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

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String avatarId,
    String department,
    String verificationCode,
    File? profileImage,
  ) async {
    try {
      final String url = '$baseUrl${ApiConstants.registerEndpoint}';

      // Print debug info
      print(
        'Registering user with: name=$name, email=$email, department=$department',
      );

      // Create request body
      Map<String, dynamic> data = {
        'name': name, // Server will map this to fullName
        'email': email,
        'password': password,
        'avatarId': avatarId,
        'department': department,
        'verificationCode': verificationCode,
      };

      // Handle profile image upload if provided
      if (profileImage != null) {
        // For now, we're not handling image upload in this simple example
        // In a real implementation, you would upload the image first and then
        // include the uploaded image URL or ID in the registration data
      }

      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      return _processResponse(response);
    } catch (e) {
      print('Error in register: $e');
      throw Exception('Register failed: $e');
    }
  }

  // Logout
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

  // Upload file using multipart request
  Future<Map<String, dynamic>> uploadFile(
    String url,
    String filePath,
    String fieldName, [
    Map<String, dynamic>? additionalFields,
  ]) async {
    try {
      final token = await _getAuthToken();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$url'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add any additional fields
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  // Add this method to process API responses consistently
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
