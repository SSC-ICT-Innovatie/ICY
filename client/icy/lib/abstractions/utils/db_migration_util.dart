import 'package:icy/abstractions/utils/network_util.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class to help with data migration from local JSON files to API
class DbMigrationUtil {
  static const String _migrationCompletedKey = 'db_migration_completed';

  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  DbMigrationUtil({
    ApiService? apiService,
    LocalStorageService? localStorageService,
  }) : _apiService = apiService ?? ApiService(),
       _localStorageService = localStorageService ?? LocalStorageService();

  /// Check if migration has been completed
  Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationCompletedKey) ?? false;
  }

  /// Mark migration as completed
  Future<void> markMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationCompletedKey, true);
  }

  /// Check if we should use API or local JSON data
  Future<bool> shouldUseApi() async {
    // If migration is completed, we should use API
    if (await isMigrationCompleted()) {
      return true;
    }

    // Check if API is available
    final apiAvailable = await NetworkUtil.isApiAvailable();
    if (!apiAvailable) {
      return false;
    }

    // Try to hit API endpoint to verify it's working
    try {
      final response = await _apiService.get('/health');
      if (response['status'] == 'ok') {
        // API is working, mark migration as completed
        await markMigrationCompleted();
        return true;
      }
    } catch (e) {
      // API endpoint failed
      print('API health check failed: $e');
      return false;
    }

    return false;
  }

  /// Get data source type to use (API or Local JSON)
  Future<DataSourceType> getDataSourceType() async {
    return (await shouldUseApi())
        ? DataSourceType.api
        : DataSourceType.localJson;
  }

  /// Perform data migration if needed
  Future<void> migrateIfNeeded() async {
    // If migration is already completed, skip
    if (await isMigrationCompleted()) {
      return;
    }

    // Check if API is available
    if (!(await NetworkUtil.isApiAvailable())) {
      return;
    }

    // Try to migrate user data
    try {
      final user = await _localStorageService.getAuthUser();
      if (user != null) {
        // We have a user, try to login with API
        print(
          'User data found, migration might be needed for user: ${user.email}',
        );
      }

      // Mark migration as completed
      await markMigrationCompleted();
    } catch (e) {
      print('Migration error: $e');
    }
  }
}

/// Enum to define which data source to use
enum DataSourceType { api, localJson }
