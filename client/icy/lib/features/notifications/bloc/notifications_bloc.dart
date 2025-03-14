import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;

  NotificationsBloc({required NotificationsRepository notificationsRepository})
    : _notificationsRepository = notificationsRepository,
      super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      final notifications =
          await _notificationsRepository.getNotificationsForUser();
      final unreadCount = notifications.where((n) => !n.read).length;

      emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      try {
        final success = await _notificationsRepository.markNotificationAsRead(
          event.notificationId,
        );

        if (success) {
          final updatedNotifications =
              currentState.notifications.map((notification) {
                if (notification.id == event.notificationId) {
                  return notification.copyWith(read: true);
                }
                return notification;
              }).toList();

          final unreadCount = updatedNotifications.where((n) => !n.read).length;

          emit(
            NotificationsLoaded(
              notifications: updatedNotifications,
              unreadCount: unreadCount,
            ),
          );
        }
      } catch (e) {
        emit(NotificationsError(message: e.toString()));
        // Revert to previous state after error
        emit(currentState);
      }
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(NotificationsLoading());

      try {
        final success = await _notificationsRepository.clearAllNotifications();

        if (success) {
          emit(const NotificationsLoaded(notifications: [], unreadCount: 0));
        } else {
          emit(currentState);
        }
      } catch (e) {
        emit(NotificationsError(message: e.toString()));
        emit(currentState);
      }
    }
  }
}
