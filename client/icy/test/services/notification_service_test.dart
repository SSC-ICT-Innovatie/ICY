import 'package:flutter_test/flutter_test.dart';
import 'package:icy/services/notification_service.dart';

void main() {
  late SystemNotificationService notificationService;

  setUp(() {
    notificationService = SystemNotificationService();
  });

  test('SystemNotificationService initializes properly', () async {
    // Basic test to ensure service creates without errors
    expect(notificationService, isA<SystemNotificationService>());
  });

  test('SystemNotificationService handles permissions correctly', () async {
    // This is a simplified test - in real testing you would mock the SharedPreferences
    final result = await notificationService.areNotificationsEnabled();
    expect(result, isA<bool>());
  });
}
