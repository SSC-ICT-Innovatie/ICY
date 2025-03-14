import 'dart:io';

class NetworkUtil {
  static Future<bool> hasNetworkConnection() async {
    try {
      // Try to connect to a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<bool> isApiAvailable() async {
    try {
      // Try to connect to our API server
      // Here we're just checking general internet connectivity
      // In a real app, you would try to hit a health check endpoint on your API
      final hasConnection = await hasNetworkConnection();
      if (!hasConnection) {
        return false;
      }

      // Here you could do a quick ping to your API endpoint
      // For now we'll just return true if network is available
      return true;
    } catch (_) {
      return false;
    }
  }
}
