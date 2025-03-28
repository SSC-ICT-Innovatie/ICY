import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;

  NotificationsBloc({required NotificationsRepository notificationsRepository})
    : _notificationsRepository = notificationsRepository,
      super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<ClearAllNotifications>(_onClearAllNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      final notifications = await _notificationsRepository.getNotifications();
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final updatedNotifications =
          state.notifications.map((notification) {
            if (notification.id == event.notificationId) {
              return notification.copyWith(isRead: true);
            }
            return notification;
          }).toList();

      emit(state.copyWith(notifications: updatedNotifications));

      // Update in repository
      await _notificationsRepository.markAsRead(event.notificationId);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to mark notification as read: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _notificationsRepository.clearAllNotifications();
      emit(state.copyWith(notifications: []));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to clear notifications: ${e.toString()}',
        ),
      );
    }
  }
}
