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

    // Handle 401 responses from Dio (e.g., form-data uploads)
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException err, handler) async {
        try {
          if (err.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final newToken = await _localStorageService.getAuthToken();
              if (newToken != null) {
                // Update header and retry the request
                final opts = err.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';

                final cloneReq = await _dio.fetch(opts);
                return handler.resolve(cloneReq);
              }
            }
          }
        } catch (e) {
          print('Dio onError refresh failed: $e');
        }

        return handler.next(err);
      },
    ));
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

  // Attempt to refresh auth token using the stored refresh token.
  // Returns true if a new token was obtained and saved.
  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _localStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final resp = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}${ApiConstants.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['token'] != null) {
          await _localStorageService.saveAuthToken(data['token']);
          if (data['refreshToken'] != null) {
            await _localStorageService.saveRefreshToken(data['refreshToken']);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Refresh token failed: $e');
      return false;
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

      if (response.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final newToken = await _localStorageService.getAuthToken();
          final retryResp = await http.get(
            Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (newToken != null) 'Authorization': 'Bearer $newToken',
            },
          );
          return _handleResponse(retryResp);
        }
      }

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

        if (response.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final newToken = await _localStorageService.getAuthToken();
            final retryResp = await http.post(
              Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                if (newToken != null) 'Authorization': 'Bearer $newToken',
              },
              body: json.encode(data),
            );
            return _handleResponse(retryResp);
          }
        }

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

      if (response.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final newToken = await _localStorageService.getAuthToken();
          final retryResp = await http.put(
            Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (newToken != null) 'Authorization': 'Bearer $newToken',
            },
            body: json.encode(data),
          );
          return _handleResponse(retryResp);
        }
      }

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

      if (response.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final newToken = await _localStorageService.getAuthToken();
          final retryResp = await http.delete(
            Uri.parse('${ApiConstants.apiBaseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (newToken != null) 'Authorization': 'Bearer $newToken',
            },
          );
          return _handleResponse(retryResp);
        }
      }

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

