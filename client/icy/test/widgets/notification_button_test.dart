import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/widgets/notifications_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notification_button_test.mocks.dart';

@GenerateMocks([NotificationsBloc])
void main() {
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockNotificationsBloc = MockNotificationsBloc();

    // Default state with no notifications
    when(mockNotificationsBloc.state).thenReturn(const NotificationsState());
  });

  testWidgets(
    'NotificationsButton shows badge when there are unread notifications',
    (WidgetTester tester) async {
      // Set up state with unread notifications
      final testNotifications = [
        NotificationModel(
          id: '1',
          title: 'Test Notification',
          body: 'This is a test notification',
          type: NotificationType.general,
          isRead: false,
          createdAt: DateTime.now(),
          actionUrl: '/test',
        ),
      ];

      when(mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          status: NotificationStatus.success,
          notifications: testNotifications,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<NotificationsBloc>.value(
              value: mockNotificationsBloc,
              child: const NotificationsButton(),
            ),
          ),
        ),
      );

      // Find badge with text '1'
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'NotificationsButton shows no badge count when all notifications are read',
    (WidgetTester tester) async {
      // Set up state with read notifications
      final testNotifications = [
        NotificationModel(
          id: '1',
          title: 'Test Notification',
          body: 'This is a test notification',
          type: NotificationType.general,
          isRead: true,
          createdAt: DateTime.now(),
          actionUrl: '/test',
        ),
      ];

      when(mockNotificationsBloc.state).thenReturn(
        NotificationsState(
          status: NotificationStatus.success,
          notifications: testNotifications,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<NotificationsBloc>.value(
              value: mockNotificationsBloc,
              child: const NotificationsButton(),
            ),
          ),
        ),
      );

      // Find badge with text '0'
      expect(find.text('0'), findsOneWidget);
    },
  );

  testWidgets('NotificationsButton triggers LoadNotifications when tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NotificationsBloc>.value(
            value: mockNotificationsBloc,
            child: const NotificationsButton(),
          ),
        ),
      ),
    );

    // Find button and tap it
    await tester.tap(find.byType(NotificationsButton));
    await tester.pumpAndSettle();

    // Verify LoadNotifications was dispatched
    verify(mockNotificationsBloc.add(const LoadNotifications())).called(1);
  });
}
