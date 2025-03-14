import 'package:icy/features/notifications/models/notification_model.dart';

class NotificationsRepository {
  // Use a list of mutable notification data
  final List<Map<String, dynamic>> _mockNotificationsData = [
    {
      'id': '1',
      'title': 'New Survey Available',
      'message': 'A new daily survey is available for completion.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'read': false,
      'type': NotificationType.survey,
      'actionId': 'survey_1',
      'actionUrl': '/surveys/daily',
    },
    {
      'id': '2',
      'title': 'Badge Earned',
      'message': 'Congratulations! You earned the "Survey Pioneer" badge.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
      'type': NotificationType.achievement,
      'actionId': 'badge_1',
      'actionUrl': '/achievements/badges',
    },
    {
      'id': '3',
      'title': 'Team Update',
      'message': 'Your team has moved up in the rankings!',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'read': false,
      'type': NotificationType.team,
      'actionId': 'team_update',
      'actionUrl': '/teams/my-team',
    },
  ];

  // Convert the mutable data to immutable NotificationModel objects
  List<NotificationModel> get _mockNotifications {
    return _mockNotificationsData
        .map(
          (data) => NotificationModel(
            id: data['id'],
            title: data['title'],
            message: data['message'],
            timestamp: data['timestamp'],
            read: data['read'],
            type: data['type'],
            actionId: data['actionId'],
            actionUrl: data['actionUrl'],
          ),
        )
        .toList();
  }

  // Will be replaced with API calls in the future
  Future<List<NotificationModel>> getNotifications() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockNotifications;
  }

  // Added alias for compatibility
  Future<List<NotificationModel>> getNotificationsForUser() async {
    return getNotifications();
  }

  Future<bool> markAsRead(String notificationId) async {
    final index = _mockNotificationsData.indexWhere(
      (data) => data['id'] == notificationId,
    );
    if (index != -1) {
      _mockNotificationsData[index]['read'] = true;
      return true;
    }
    return false;
  }

  // Added alias for compatibility
  Future<bool> markNotificationAsRead(String notificationId) async {
    return markAsRead(notificationId);
  }

  Future<bool> markAllAsRead() async {
    for (var data in _mockNotificationsData) {
      data['read'] = true;
    }
    return true;
  }

  Future<bool> deleteNotification(String notificationId) async {
    final beforeLength = _mockNotificationsData.length;
    _mockNotificationsData.removeWhere((data) => data['id'] == notificationId);
    return _mockNotificationsData.length < beforeLength;
  }

  // Added alias for compatibility
  Future<bool> clearAllNotifications() async {
    _mockNotificationsData.clear();
    return true;
  }

  Future<int> getUnreadCount() async {
    return _mockNotificationsData.where((data) => !data['read']).length;
  }
}
