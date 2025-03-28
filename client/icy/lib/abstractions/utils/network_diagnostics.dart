import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:icy/abstractions/utils/api_constants.dart';

class NetworkDiagnostics {
  static Future<Map<String, dynamic>> checkServerConnection() async {
    final results = <String, dynamic>{};


    try {
      final internetResult = await InternetAddress.lookup('google.com');
      results['internet_connected'] =
          internetResult.isNotEmpty && internetResult[0].rawAddress.isNotEmpty;
    } catch (e) {
      results['internet_connected'] = false;
      results['internet_error'] = e.toString();
    }

    // Test API server connectivity
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.apiBaseUrl}/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      results['api_status_code'] = response.statusCode;
      results['api_connected'] =
          response.statusCode >= 200 && response.statusCode < 300;
      results['api_response'] = response.body;
    } catch (e) {
      results['api_connected'] = false;
      results['api_error'] = e.toString();
    }


    print('Network diagnostics: $results');

    return results;
  }
}
