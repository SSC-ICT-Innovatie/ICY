import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';
import 'package:icy/features/notifications/widgets/notifications_dialog.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // Show notifications dialog
  void showNotificationsDialog(BuildContext context) {
    // Create a local NotificationsBloc specifically for the dialog
    final notificationsRepository = NotificationsRepository();
    final notificationsBloc = NotificationsBloc(
      notificationsRepository: notificationsRepository,
    );

    // Load notifications
    notificationsBloc.add(const LoadNotifications());

    // Show the dialog
    showDialog(
      context: context,
      builder:
          (context) => BlocProvider<NotificationsBloc>.value(
            value: notificationsBloc,
            child: NotificationsDialog(
              onNotificationTap: (actionId, actionUrl) {
                handleNotificationTap(context, actionId, actionUrl);
              },
            ),
          ),
    );
  }

  // Mark notification as read
  void markAsRead(BuildContext context, String notificationId) {
    context.read<NotificationsBloc>().add(
      MarkNotificationAsRead(notificationId: notificationId),
    );
  }

  // Clear all notifications
  void clearAllNotifications(BuildContext context) {
    context.read<NotificationsBloc>().add(const ClearAllNotifications());
  }

  // Handle notification actions with proper typing
  void handleNotificationAction(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Mark as read
    context.read<NotificationsBloc>().add(
      MarkNotificationAsRead(notificationId: notification.id),
    );

    // Close the dialog
    Navigator.of(context).pop();

    // Handle navigation based on type
    navigateBasedOnType(context, notification.type, notification.title);
  }

  // Navigate based on notification type
  void navigateBasedOnType(
    BuildContext context,
    NotificationType type,
    String title,
  ) {
    // Show feedback to the user
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening $title')));

    // Handle navigation based on type
    switch (type) {
      case NotificationType.survey:
        // Navigate to survey screen
        break;
      case NotificationType.achievement:
        // Navigate to achievements screen
        break;
      case NotificationType.team:
        // Navigate to team screen
        break;
      case NotificationType.general:
        // Navigate to home screen
        break;
    }
  }

  // Returns the appropriate icon based on notification type
  IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.survey:
        return Icons.assignment;
      case NotificationType.achievement:
        return Icons.military_tech;
      case NotificationType.team:
        return Icons.people;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  // Returns the appropriate color based on notification type
  Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.survey:
        return Colors.blue;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.team:
        return Colors.green;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  // Handles navigation based on notification type and action
  void handleNotificationTap(
    BuildContext context,
    String? actionId,
    String actionUrl,
  ) {
    if (actionId == null || actionId.isEmpty) {
      return;
    }

    // This is a simplified navigation handler
    if (actionUrl.contains('/surveys')) {
      // Navigate to survey
      print('Navigate to survey: $actionId');
    } else if (actionUrl.contains('/achievements')) {
      // Navigate to achievements
      print('Navigate to achievement: $actionId');
    } else if (actionUrl.contains('/teams')) {
      // Navigate to teams
      print('Navigate to team: $actionId');
    }
  }

  // Get the title based on notification type
  String getTitleForType(String typeString) {
    final type = _parseNotificationType(typeString);
    switch (type) {
      case NotificationType.survey:
        return 'Survey';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.team:
        return 'Team Update';
      case NotificationType.general:
        return 'Notification';
    }
  }

  NotificationType _parseNotificationType(String typeString) {
    switch (typeString) {
      case 'survey':
        return NotificationType.survey;
      case 'achievement':
        return NotificationType.achievement;
      case 'team':
        return NotificationType.team;
      default:
        return NotificationType.general;
    }
  }
}
