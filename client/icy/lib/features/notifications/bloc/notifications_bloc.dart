import 'dart:async';
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
      final notifications = await _notificationsRepository
          .getNotificationsForUser(event.userId);
      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationsError(message: 'Failed to load notifications: $e'));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        // Mark notification as read
        await _notificationsRepository.markNotificationAsRead(
          event.userId,
          event.notificationId,
        );

        // Update the state with the read notification
        final updatedNotifications =
            currentState.notifications.map((notification) {
              return notification.id == event.notificationId
                  ? notification.copyWith(read: true)
                  : notification;
            }).toList();

        emit(NotificationsLoaded(notifications: updatedNotifications));
      }
    } catch (e) {
      emit(
        NotificationsError(message: 'Failed to mark notification as read: $e'),
      );
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _notificationsRepository.clearAllNotifications(event.userId);
      emit(const NotificationsLoaded(notifications: []));
    } catch (e) {
      emit(NotificationsError(message: 'Failed to clear notifications: $e'));
    }
  }
}
