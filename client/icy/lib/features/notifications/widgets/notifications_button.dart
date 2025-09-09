import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final hasUnread = state.notifications.any((n) => !n.isRead);

        return Stack(
          alignment: Alignment.topRight,
          children: [
            FButton.icon(
              child: FIcon(
                FAssets.icons.bell,
                color: Theme.of(context).iconTheme.color,
              ),
              onPress: () {
                _showNotificationsDialog(context);
              },
            ),
            FBadge(label: hasUnread ? Text(1.toString()) : Text(0.toString())),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    // Create a local NotificationsBloc specifically for the dialog
    final notificationsBloc = context.read<NotificationsBloc>();

    // Load notifications
    notificationsBloc.add(const LoadNotifications());

    // Show the dialog
    showDialog(
      context: context,
      builder:
          (context) => BlocProvider.value(
            value: notificationsBloc,
            child: NotificationsDialog(
              onNotificationTap: (actionId, actionUrl) {
                _handleNotificationTap(context, actionId, actionUrl);
              },
            ),
          ),
    );
  }

  void _handleNotificationTap(
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
}

class NotificationsDialog extends StatefulWidget {
  final Function(String?, String) onNotificationTap;

  const NotificationsDialog({required this.onNotificationTap, super.key});

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  @override
  Widget build(BuildContext context) {
    // Implementation will go here
    return Container();
  }
}

