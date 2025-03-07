import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/widgets/modal_wrapper.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
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
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final userId = authState.user.id;

    // Load notifications before showing dialog
    context.read<NotificationsBloc>().add(LoadNotifications(userId: userId));

    // Show the dialog using the modal wrapper
    ModalWrapper.showModal(
      context: context,
      child: NotificationsDialog(userId: userId),
    );
  }

  // Mark notification as read
  void markAsRead(BuildContext context, String notificationId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final userId = authState.user.id;

    context.read<NotificationsBloc>().add(
      MarkNotificationAsRead(userId: userId, notificationId: notificationId),
    );
  }

  // Clear all notifications
  void clearAllNotifications(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final userId = authState.user.id;

    context.read<NotificationsBloc>().add(
      ClearAllNotifications(userId: userId),
    );
  }

  // Handle notification action (navigation)
  void handleNotificationAction(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Mark as read
    markAsRead(context, notification.id);

    // Close the dialog
    Navigator.of(context).pop();

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'survey':
        // Navigate to surveys
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening survey: ${notification.title}')),
        );
        break;
      case 'achievement':
        // Navigate to achievements
        _navigateToTab(context, 'Achievements');
        break;
      case 'team':
        // Navigate to team screen or show team dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Team feature coming soon')));
        break;
      case 'challenge':
        // Navigate to challenges
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening challenge: ${notification.title}')),
        );
        break;
      default:
        // Default action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Action for ${notification.type} not implemented yet',
            ),
          ),
        );
    }
  }

  // Helper method to navigate to a specific tab
  void _navigateToTab(BuildContext context, String tabName) {
    // Get the current tab index
    // This is a simplified version - in a real app, you would use a navigation service
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navigating to $tabName tab')));
  }
}
