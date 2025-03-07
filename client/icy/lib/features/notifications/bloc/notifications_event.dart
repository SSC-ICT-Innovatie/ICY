part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final String userId;

  const LoadNotifications({required this.userId});

  @override
  List<Object> get props => [userId];
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String userId;
  final String notificationId;

  const MarkNotificationAsRead({
    required this.userId,
    required this.notificationId,
  });

  @override
  List<Object> get props => [userId, notificationId];
}

class ClearAllNotifications extends NotificationsEvent {
  final String userId;

  const ClearAllNotifications({required this.userId});

  @override
  List<Object> get props => [userId];
}
