import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';

// Generate mock files
@GenerateMocks([NotificationsRepository])
import 'notifications_bloc_test.mocks.dart';

void main() {
  late MockNotificationsRepository mockRepository;
  late NotificationsBloc notificationsBloc;

  setUp(() {
    mockRepository = MockNotificationsRepository();
    notificationsBloc = NotificationsBloc(
      notificationsRepository: mockRepository,
    );
  });

  tearDown(() {
    notificationsBloc.close();
  });

  group('NotificationsBloc', () {
    final notificationsList = [
      NotificationModel(
        id: '1',
        title: 'Test Notification 1',
        message: 'Test message 1',
        timestamp: DateTime.now(),
        read: false,
        type: NotificationType.survey,
        actionUrl: '/test/url',
      ),
      NotificationModel(
        id: '2',
        title: 'Test Notification 2',
        message: 'Test message 2',
        timestamp: DateTime.now(),
        read: true,
        type: NotificationType.achievement,
        actionUrl: '/test/url2',
      ),
    ];

    test('initial state is NotificationsInitial', () {
      expect(notificationsBloc.state, isA<NotificationsInitial>());
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [NotificationsLoading, NotificationsLoaded] when LoadNotifications is added',
      build: () {
        when(
          mockRepository.getNotificationsForUser(),
        ).thenAnswer((_) async => notificationsList);
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(const LoadNotifications()),
      expect:
          () => [
            isA<NotificationsLoading>(),
            isA<NotificationsLoaded>()
                .having(
                  (state) => state.notifications,
                  'notifications',
                  notificationsList,
                )
                .having(
                  (state) => state.unreadCount,
                  'unreadCount',
                  1, // Only the first notification is unread
                ),
          ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [NotificationsError] when repository throws an exception',
      build: () {
        when(
          mockRepository.getNotificationsForUser(),
        ).thenThrow(Exception('Failed to load notifications'));
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(const LoadNotifications()),
      expect:
          () => [
            isA<NotificationsLoading>(),
            isA<NotificationsError>().having(
              (state) => state.message,
              'message',
              contains('Failed to load notifications'),
            ),
          ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'marks notification as read when MarkNotificationAsRead is added',
      build: () {
        when(
          mockRepository.getNotificationsForUser(),
        ).thenAnswer((_) async => notificationsList);
        when(
          mockRepository.markNotificationAsRead('1'),
        ).thenAnswer((_) async => true);
        return notificationsBloc;
      },
      seed:
          () => NotificationsLoaded(
            notifications: notificationsList,
            unreadCount: 1,
          ),
      act:
          (bloc) => bloc.add(const MarkNotificationAsRead(notificationId: '1')),
      expect:
          () => [
            isA<NotificationsLoaded>()
                .having(
                  (state) =>
                      state.notifications.firstWhere((n) => n.id == '1').read,
                  'notification is read',
                  true,
                )
                .having((state) => state.unreadCount, 'unreadCount', 0),
          ],
    );
  });
}
