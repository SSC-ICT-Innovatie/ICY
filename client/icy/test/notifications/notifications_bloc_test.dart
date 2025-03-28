import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notifications_bloc_test.mocks.dart';

@GenerateMocks([NotificationsRepository])
void main() {
  late MockNotificationsRepository mockNotificationsRepository;
  late NotificationsBloc notificationsBloc;

  setUp(() {
    mockNotificationsRepository = MockNotificationsRepository();
    notificationsBloc = NotificationsBloc(
      notificationsRepository: mockNotificationsRepository,
    );
  });

  tearDown(() {
    notificationsBloc.close();
  });

  final testNotifications = [
    NotificationModel(
      id: '1',
      title: 'Test Notification 1',
      body: 'This is test notification 1',
      type: NotificationType.general,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: '/test/1',
    ),
    NotificationModel(
      id: '2',
      title: 'Test Notification 2',
      body: 'This is test notification 2',
      type: NotificationType.survey,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      actionUrl: '/test/2',
    ),
  ];

  group('NotificationsBloc', () {
    test('initial state is correct', () {
      expect(notificationsBloc.state, const NotificationsState());
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [loading, success] states when notifications are loaded successfully',
      build: () {
        when(
          mockNotificationsRepository.getNotifications(),
        ).thenAnswer((_) async => testNotifications);
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(const LoadNotifications()),
      expect:
          () => [
            const NotificationsState(status: NotificationStatus.loading),
            NotificationsState(
              status: NotificationStatus.success,
              notifications: testNotifications,
            ),
          ],
      verify: (_) {
        verify(mockNotificationsRepository.getNotifications()).called(1);
        return true; // Fix: Always return true to satisfy FutureOr<bool>
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [loading, error] states when loading notifications fails',
      build: () {
        when(
          mockNotificationsRepository.getNotifications(),
        ).thenThrow(Exception('Failed to load notifications'));
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(const LoadNotifications()),
      expect:
          () => [
            const NotificationsState(status: NotificationStatus.loading),
            predicate<NotificationsState>(
              (state) =>
                  state.status == NotificationStatus.error &&
                  state.errorMessage.contains('Failed to load notifications'),
            ),
          ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'marks notification as read',
      build: () {
        // First load the notifications
        when(
          mockNotificationsRepository.getNotifications(),
        ).thenAnswer((_) async => testNotifications);
        when(
          mockNotificationsRepository.markAsRead(any),
        ).thenAnswer((_) async => true);

        return notificationsBloc;
      },
      seed:
          () => NotificationsState(
            status: NotificationStatus.success,
            notifications: testNotifications,
          ),
      act:
          (bloc) => bloc.add(const MarkNotificationAsRead(notificationId: '1')),
      expect:
          () => [
            predicate<NotificationsState>(
              (state) =>
                  state.status == NotificationStatus.success &&
                  state.notifications.length == 2 &&
                  state.notifications[0].isRead == true &&
                  state.notifications[1].isRead == true,
            ),
          ],
      verify: (_) {
        verify(mockNotificationsRepository.markAsRead('1')).called(1);
        return true; // Fix: Always return true to satisfy FutureOr<bool>
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'clears all notifications',
      build: () {
        when(
          mockNotificationsRepository.clearAllNotifications(),
        ).thenAnswer((_) async => true);
        return notificationsBloc;
      },
      seed:
          () => NotificationsState(
            status: NotificationStatus.success,
            notifications: testNotifications,
          ),
      act: (bloc) => bloc.add(const ClearAllNotifications()),
      expect:
          () => [
            const NotificationsState(
              status: NotificationStatus.success,
              notifications: [],
            ),
          ],
      verify: (_) {
        verify(mockNotificationsRepository.clearAllNotifications()).called(1);
        return true; // Fix: Always return true to satisfy FutureOr<bool>
      },
    );
  });
}
