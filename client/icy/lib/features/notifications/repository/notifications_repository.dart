import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:icy/data/datasources/json_asset_service.dart';
import 'package:icy/features/notifications/models/notification_model.dart';

class NotificationsRepository {
  final JsonAssetService _jsonAssetService;

  NotificationsRepository({JsonAssetService? jsonAssetService})
    : _jsonAssetService = jsonAssetService ?? JsonAssetService();

  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    try {
      // Load user data from JSON
      final userData = await _jsonAssetService.loadJson(
        'lib/data/user_data.json',
      );
      final userDataList = userData['user_data'] as List;

      // Find the user's data with safer null handling
      Map<String, dynamic>? userRecord;
      try {
        userRecord =
            userDataList.firstWhere((user) => user['userId'] == userId)
                as Map<String, dynamic>;
      } catch (_) {
        // User not found
        return [];
      }

      if (userRecord == null) {
        return [];
      }

      // Extract and convert notifications - safely accessing with null check
      final notificationsList = userRecord['notifications'] as List? ?? [];
      return notificationsList
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<bool> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    try {
      // In a real backend implementation, this would update the database
      // For now, we'll just simulate success
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> clearAllNotifications(String userId) async {
    try {
      // In a real backend implementation, this would update the database
      // For now, we'll just simulate success
      return true;
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }
}
