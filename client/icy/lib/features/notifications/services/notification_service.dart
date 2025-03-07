import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/utils/extensions/navigation_extensions.dart';
import 'package:icy/abstractions/widgets/modal_wrapper.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
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
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;

    final userId = authState.user.id;

    // Create a local NotificationsBloc specifically for the dialog
    final notificationsRepository = NotificationsRepository();
    final notificationsBloc = NotificationsBloc(
      notificationsRepository: notificationsRepository,
    );

    // Load notifications
    notificationsBloc.add(LoadNotifications(userId: userId));

    // Show the dialog using the modal wrapper with the BlocProvider
    ModalWrapper.showModal(
      context: context,
      child: BlocProvider<NotificationsBloc>.value(
        value: notificationsBloc,
        child: NotificationsDialog(userId: userId),
      ),
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

    // Using the context extension already defined in your project
    // This leverages your existing navigation architecture
    try {
      // Map notification types to tab names in your application
      String tabName;
      switch (notification.type) {
        case 'survey':
          tabName = "Home";
          break;
        case 'achievement':
          tabName = "Achievements";
          break;
        case 'team':
          tabName = "Home";
          break;
        case 'challenge':
          tabName = "Home";
          break;
        case 'weekly':
          tabName = "Home";
          break;
        default:
          tabName = "Home";
      }

      // Use your existing navigation extension
      context.navigateToTab(tabName);

      // Show feedback to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opening ${notification.title}')));
    } catch (e) {
      print('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot navigate to this content: $e')),
      );
    }
  }
}
