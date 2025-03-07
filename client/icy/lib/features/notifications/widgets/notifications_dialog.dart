import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/features/notifications/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsDialog extends StatelessWidget {
  final String userId;

  const NotificationsDialog({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load notifications when dialog is opened
    context.read<NotificationsBloc>().add(LoadNotifications(userId: userId));

    final notificationService = NotificationService();

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notificaties',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NotificationsLoaded) {
                  if (state.notifications.isEmpty) {
                    return const Center(child: Text('Geen meldingen'));
                  }
                  return _buildNotificationsList(context, state.notifications);
                } else if (state is NotificationsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return FButton(
                  style: FButtonStyle.outline,
                  onPress:
                      () => notificationService.clearAllNotifications(context),
                  label: const Text('Alles wissen'),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    final dateFormatter = DateFormat('dd MMM, HH:mm');
    final notificationService = NotificationService();

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final dateTime = DateTime.parse(notification.timestamp);
        final formattedDate = dateFormatter.format(dateTime);

        return FTile(
          title: Text(notification.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          prefixIcon: _getNotificationIcon(notification.type),
          suffixIcon:
              notification.read
                  ? null
                  : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
          onPress: () {
            // Use notification service to handle the notification action
            notificationService.handleNotificationAction(context, notification);
          },
        );
      },
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'survey':
        return const Icon(Icons.assignment, color: Colors.blue);
      case 'achievement':
        return const Icon(Icons.emoji_events, color: Colors.amber);
      case 'team':
        return const Icon(Icons.people, color: Colors.green);
      case 'challenge':
        return const Icon(Icons.stars, color: Colors.purple);
      case 'weekly':
        return const Icon(Icons.calendar_today, color: Colors.orange);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }
}
