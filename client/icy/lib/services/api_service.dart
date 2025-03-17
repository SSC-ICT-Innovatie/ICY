import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? ApiConstants.baseUrl;

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.authTokenKey);
  }

  // Helper method to get refresh token
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.refreshTokenKey);
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

  // Save tokens to shared preferences
  Future<void> _saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.authTokenKey, token);
    await prefs.setString(ApiConstants.refreshTokenKey, refreshToken);
  }

  // Add an initialization method
  Future<void> init() async {
    // Check if we have auth tokens already
    final authToken = await _getAuthToken();
    if (authToken != null) {
      print('API Service initialized with existing auth token');
    } else {
      print('API Service initialized without auth token');
    }

    // Any other initialization can go here
    return;
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
    final data = {'email': email, 'password': password};
    final url = Uri.parse('$baseUrl${ApiConstants.loginEndpoint}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    final responseData = _handleResponse(response);
    if (responseData['success'] == true &&
        responseData['token'] != null &&
        responseData['refreshToken'] != null) {
      await _saveTokens(responseData['token'], responseData['refreshToken']);
    }
    return responseData;
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String avatarId,
    String? department,
    String verificationCode,
    File? profileImage,
  ) async {
    Map<String, dynamic> data = {
      'fullName': name,
      'email': email,
      'password': password,
      'avatarId': avatarId,
      'verificationCode': verificationCode,
    };

    if (department != null) {
      data['department'] = department;
    }

    final url = Uri.parse('$baseUrl${ApiConstants.registerEndpoint}');

    // If there's no profile image, do a regular POST
    if (profileImage == null) {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = _handleResponse(response);
      if (responseData['success'] == true &&
          responseData['token'] != null &&
          responseData['refreshToken'] != null) {
        await _saveTokens(responseData['token'], responseData['refreshToken']);
      }
      return responseData;
    } else {
      // If there is a profile image, use multipart request
      return await uploadFile(
        '$baseUrl${ApiConstants.registerEndpoint}',
        profileImage.path,
        'profileImage',
        data,
      );
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await post(ApiConstants.logoutEndpoint, {});

      // Clear tokens regardless of response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.authTokenKey);
      await prefs.remove(ApiConstants.refreshTokenKey);

      return response;
    } catch (e) {
      // Clear tokens even if API call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.authTokenKey);
      await prefs.remove(ApiConstants.refreshTokenKey);

      throw e;
    }
  }

  // Upload file using multipart request
  Future<Map<String, dynamic>> uploadFile(
    String url,
    String filePath,
    String fieldName, [
    Map<String, dynamic>? additionalFields,
  ]) async {
    final token = await _getAuthToken();

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add auth header if token exists
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add file
    final file = File(filePath);
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();

    // Determine file mime type
    final fileExtension = path.extension(filePath).toLowerCase();
    String mimeType = 'application/octet-stream';
    if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
      mimeType = 'image/jpeg';
    } else if (fileExtension == '.png') {
      mimeType = 'image/png';
    } else if (fileExtension == '.pdf') {
      mimeType = 'application/pdf';
    }

    final multipartFile = http.MultipartFile(
      fieldName,
      fileStream,
      fileLength,
      filename: path.basename(filePath),
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(multipartFile);

    // Add any additional fields
    if (additionalFields != null) {
      additionalFields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
    }

    // Send the request
    final httpResponse = await http.Response.fromStream(await request.send());

    // Handle response
    final responseData = _handleResponse(httpResponse);

    // Save auth tokens if they are in the response
    if (responseData['success'] == true &&
        responseData['token'] != null &&
        responseData['refreshToken'] != null) {
      await _saveTokens(responseData['token'], responseData['refreshToken']);
    }

    return responseData;
  }
}
