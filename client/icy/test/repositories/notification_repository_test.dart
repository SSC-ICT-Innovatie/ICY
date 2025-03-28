import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';



@GenerateMocks([http.Client])
void main() {
  late NotificationsRepository notificationsRepository;

  setUp(() {
    notificationsRepository = NotificationsRepository();
  });

  test('getNotifications returns a list of notifications', () async {
    final notifications = await notificationsRepository.getNotifications();

    // Verify it returns a list of notifications
    expect(notifications, isA<List<NotificationModel>>());
    // Verify the list is not empty (since our mock data has items)
    expect(notifications.isNotEmpty, true);
    // Verify each item has the expected properties
    for (var notification in notifications) {
      expect(notification.id, isNotEmpty);
      expect(notification.title, isNotEmpty);
      expect(notification.body, isNotEmpty);
      expect(notification.type, isA<NotificationType>());
      expect(notification.isRead, isA<bool>());
      expect(notification.createdAt, isA<DateTime>());
      expect(notification.actionUrl, isNotEmpty);
    }
  });

  test('markAsRead method works', () async {
    // This is testing our mock implementation, in a real test with MockClient
    // you would verify HTTP calls
    await expectLater(notificationsRepository.markAsRead('test-id'), completes);
  });

  test('clearAllNotifications method works', () async {
    await expectLater(
      notificationsRepository.clearAllNotifications(),
      completes,
    );
  });
}
