import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';
import 'package:icy/features/notifications/widgets/notifications_button.dart';

void main() {
  testWidgets('NotificationsButton displays properly', (
    WidgetTester tester,
  ) async {
    // Initial state with no notifications
    final initialState = NotificationsState();

    // Create a proper implementation of the repository for testing
    final testRepository = TestNotificationsRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NotificationsBloc>(
            create:
                (_) =>
                    NotificationsBloc(notificationsRepository: testRepository),
            child: const NotificationsButton(),
          ),
        ),
      ),
    );

    // Test if the button is displayed
    expect(find.byType(NotificationsButton), findsOneWidget);

    // Find badge with text '0'
    expect(find.text('0'), findsOneWidget);
  });
}

// Simple test repository that extends the actual repository class
class TestNotificationsRepository extends NotificationsRepository {
  @override
  Future<List<NotificationModel>> getNotifications() async => [];

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> clearAllNotifications() async {}
}
