import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/services/notification_service.dart';

final DateFormat dateFormatter = DateFormat('dd MMM, HH:mm');

class NotificationsDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(String, String)? onNotificationTap;

  const NotificationsDialog({
    super.key, 
    this.onClose, 
    this.onNotificationTap,
  });

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  @override
  void initState() {
    super.initState();
    // Load notifications when dialog opens
    context.read<NotificationsBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    if (widget.onClose != null) {
                      widget.onClose!();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildNotificationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationsError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is NotificationsLoaded) {
          if (state.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        }

        return const Center(child: Text('No notifications'));
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final notificationService = NotificationService();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: notificationService.getNotificationColor(
          notification.type,
        ),
        child: Icon(
          notificationService.getNotificationIcon(notification.type),
          color: Colors.white,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            dateFormatter.format(notification.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing:
          notification.read
              ? null
              : IconButton(
                icon: const Icon(Icons.circle, size: 12, color: Colors.blue),
                onPressed: () {
                  context.read<NotificationsBloc>().add(
                    MarkNotificationAsRead(notificationId: notification.id),
                  );
                },
              ),
      onTap: () {
        // Mark as read when tapped
        if (!notification.read) {
          context.read<NotificationsBloc>().add(
            MarkNotificationAsRead(notificationId: notification.id),
          );
        }

        // Handle notification tap
        if (widget.onNotificationTap != null && notification.actionId != null) {
          widget.onNotificationTap!(
            notification.actionId!,
            notification.actionUrl,
          );
          Navigator.of(context).pop();
        }
      },
    );
  }
}
