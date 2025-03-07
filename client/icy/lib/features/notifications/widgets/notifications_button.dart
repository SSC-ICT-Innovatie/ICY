import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/services/notification_service.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const SizedBox.shrink();
        }

        final userId = authState.user.id;

        // Load the notifications to get the unread count
        context.read<NotificationsBloc>().add(
          LoadNotifications(userId: userId),
        );

        return BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, notifState) {
            // Determine if there are unread notifications
            final hasUnread =
                notifState is NotificationsLoaded && notifState.unreadCount > 0;

            return IconButton(
              icon: Stack(
                children: [
                  FIcon(FAssets.icons.bell),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                // Use the notification service to show the dialog
                NotificationService().showNotificationsDialog(context);
              },
            );
          },
        );
      },
    );
  }
}
