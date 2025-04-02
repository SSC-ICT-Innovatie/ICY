import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icy/abstractions/utils/network_diagnostics.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/services/api_service.dart';
import 'package:icy/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';

/// Service for initializing the application
class AppInitializationService {
  /// Initialize all services and configurations needed for the app
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize services
    await _initLocalStorage();
    await _initCacheDirectory();

    // Create an instance of ApiService (no init method needed)
    ApiService();

    // Initialize notification service
    final notificationService = SystemNotificationService();
    await notificationService.initialize();

    // Perform network diagnostics
    try {
      await NetworkDiagnostics.checkServerConnection();
    } catch (e) {
      // Log error but don't fail app startup
      print('Network diagnostics failed: $e');
    }

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  /// Initialize local storage service
  static Future<void> _initLocalStorage() async {
    final service = LocalStorageService();
    await service.init();
  }

  /// Set up cache directory
  static Future<Directory> _initCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory;
  }
}
