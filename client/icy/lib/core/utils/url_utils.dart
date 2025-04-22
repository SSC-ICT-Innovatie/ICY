import 'dart:io';

/// Utility class for handling URLs including fixing malformed URLs
class UrlUtils {
  static const String _baseUrl = 'http://localhost:5000'; // Replace with your actual API base URL in production
  
  /// Converts a relative URL or file path to a proper URL for image loading
  static String getImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }
    
    // Already a valid URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // File URI - handle with File objects instead
    if (url.startsWith('file://')) {
      return url; // Let the avatar helper handle this case with File object
    }
    
    // Relative path from API - append base URL
    if (url.startsWith('/')) {
      return '$_baseUrl$url';
    }
    
    // Placeholder URLs should just pass through
    if (url.contains('placeholder')) {
      return url;
    }
    
    // Default case - assume it's a relative path
    return '$_baseUrl/$url';
  }
  
  /// Check if the URL is a local file path
  static bool isLocalFilePath(String? url) {
    return url != null && url.startsWith('file://');
  }
  
  /// Get File object from file URI
  static File? getFileFromUri(String? url) {
    if (url != null && url.startsWith('file://')) {
      try {
        return File(url.replaceFirst('file://', ''));
      } catch (e) {
        print('Error creating File from URI: $e');
        return null;
      }
    }
    return null;
  }
}