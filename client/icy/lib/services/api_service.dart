import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/datasources/local_storage_service.dart';

class ApiService {
  final LocalStorageService _localStorageService;
  final Dio _dio = Dio();

  ApiService({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService() {
    // Configure Dio
    _dio.options.baseUrl = ApiConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _localStorageService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}${ApiConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) return;

      await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}${ApiConstants.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error during logout: $e');
      // We'll handle this in the repository
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _localStorageService.getAuthToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      print('GET error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic data, {
    bool useFormData = false,
  }) async {
    try {
      if (useFormData) {
        // Use Dio for FormData
        final token = await _localStorageService.getAuthToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }

        final response = await _dio.post(endpoint, data: data);

        return response.data;
      } else {
        // Use regular http for JSON data
        final token = await _localStorageService.getAuthToken();
        final response = await http.post(
          Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: json.encode(data),
        );

        return _handleResponse(response);
      }
    } catch (e) {
      print('POST error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    try {
      final token = await _localStorageService.getAuthToken();
      final response = await http.put(
        Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      print('PUT error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _localStorageService.getAuthToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      print('DELETE error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'API request failed');
    }
  }
}
