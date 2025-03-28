import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/services/api_service.dart';
import 'package:icy/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';

class AppInitializationService {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize HydratedBloc storage
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await getTemporaryDirectory()).path,
      ),
    );

    // Initialize API service
    final apiService = ApiService();
    await apiService.init();

    // Initialize system notification service
    // TODO: Consider consolidating UI notifications and system notifications into one service
    final notificationService = SystemNotificationService();
    await notificationService.initialize();
  }
}
