import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/services/notification_service.dart';

class NotificationsButton extends StatelessWidget {
  final bool showBadge;

  const NotificationsButton({super.key, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.notifications_outlined),
          if (showBadge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            ),
        ],
      ),
      onPressed: () {
        // Load notifications when button is tapped
        context.read<NotificationsBloc>().add(const LoadNotifications());

        // Show notifications dialog
        NotificationService().showNotificationsDialog(context);
      },
    );
  }
}
