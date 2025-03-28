part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  final List<NotificationModel> notifications;
  final NotificationStatus status;
  final String errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.status = NotificationStatus.initial,
    this.errorMessage = '',
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    NotificationStatus? status,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [notifications, status, errorMessage];
}
