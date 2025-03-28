import 'dart:convert';
import 'package:icy/features/notifications/models/notification_model.dart';
import 'package:icy/services/api_service.dart';

class NotificationsRepository {
  final ApiService _apiService = ApiService();

  // Get notifications from server API
  Future<List<NotificationModel>> getNotifications() async {
    try {
      // ApiService.get() returns Map<String, dynamic>, not http.Response
      final responseData = await _apiService.get('/notifications');

      // Check if the API call was successful and contains data
      if (responseData['success'] == true && responseData['data'] != null) {
        return (responseData['data'] as List)
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      // Return empty list if data is missing
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');

      // For development, return mock data if API fails
      return _getMockNotifications();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put('/notifications/$notificationId/read', {});
    } catch (e) {
      print('Error marking notification as read: $e');
      // Silently fail - UI will still show as read
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _apiService.delete('/notifications');
    } catch (e) {
      print('Error clearing notifications: $e');
      // Silently fail - UI will still clear
    }
  }

  // Mock data for development or when API fails
  List<NotificationModel> _getMockNotifications() {
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
}
