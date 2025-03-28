import 'package:icy/features/notifications/models/notification_model.dart';

class NotificationsRepository {
  // In a real app, this would call an API
  Future<List<NotificationModel>> getNotifications() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock notifications
    return [
      NotificationModel(
        id: '1',
        title: 'New Survey Available',
        body:
            'A new weekly survey is now available. Complete it to earn points!',
        type: NotificationType.survey,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        actionId: 'survey-123',
        actionUrl: '/surveys/123',
      ),
      NotificationModel(
        id: '2',
        title: 'Achievement Unlocked',
        body: 'Congratulations! You\'ve earned the "Early Adopter" badge.',
        type: NotificationType.achievement,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        actionId: 'achievement-456',
        actionUrl: '/achievements/456',
      ),
      NotificationModel(
        id: '3',
        title: 'Team Update',
        body: 'Your team has completed 80% of this month\'s goals!',
        type: NotificationType.team,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        actionId: 'team-789',
        actionUrl: '/teams/789',
      ),
    ];
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    print('Marked notification $notificationId as read');
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    print('Cleared all notifications');
  }
}
