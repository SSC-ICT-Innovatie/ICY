import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';

class NotificationsDialog extends StatefulWidget {
  final Function(String?, String) onNotificationTap;

  const NotificationsDialog({required this.onNotificationTap, super.key});

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  @override
  Widget build(BuildContext context) {
    return FDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications),
          SizedBox(width: 8),
          Text('Notifications'),
        ],
      ),
      direction: Axis.vertical,
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: () {
                      context.read<NotificationsBloc>().add(
                        const LoadNotifications(),
                      );
                    },
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No notifications'),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return _buildNotificationItem(context, notification);
            },
          );
        },
      ),
      actions: [
        BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state.notifications.isNotEmpty) {
              return FButton(
                style: FButtonStyle.outline,
                onPress: () {
                  context.read<NotificationsBloc>().add(
                    const ClearAllNotifications(),
                  );
                },
                label: const Text('Clear All'),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        FButton(
          onPress: () => Navigator.of(context).pop(),
          label: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
  ) {
    return ListTile(
      leading: _getNotificationIcon(notification.type),
      title: Text(notification.title),
      subtitle: Text(notification.body),
      trailing:
          notification.isRead
              ? null
              : const CircleAvatar(radius: 5, backgroundColor: Colors.red),
      onTap: () {
        // Mark as read
        context.read<NotificationsBloc>().add(
          MarkNotificationAsRead(notificationId: notification.id),
        );

        // Navigate based on notification type
        widget.onNotificationTap(notification.actionId, notification.actionUrl);

        // Close the dialog
        Navigator.of(context).pop();
      },
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.survey:
        iconData = Icons.assignment;
        iconColor = Colors.blue;
        break;
      case NotificationType.achievement:
        iconData = Icons.military_tech;
        iconColor = Colors.amber;
        break;
      case NotificationType.team:
        iconData = Icons.people;
        iconColor = Colors.green;
        break;
      case NotificationType.general:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(iconData, color: iconColor),
    );
  }
}

