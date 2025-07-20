import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay timeOfDay,
    String? payload,
  });
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
}

class SystemNotificationService implements NotificationService {
  static final SystemNotificationService _instance =
      SystemNotificationService._internal();
  factory SystemNotificationService() => _instance;

  SystemNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String _notificationsEnabledKey = 'notifications_enabled';

  @override
  Future<void> initialize() async {
    try {
      print('Initializing notification service for iOS...');
      tz.initializeTimeZones();

      // Initialize notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,   // Request alert permission
            requestBadgePermission: true,   // Request badge permission
            requestSoundPermission: true,   // Request sound permission
            requestCriticalPermission: false,
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (
          NotificationResponse notificationResponse,
        ) async {
          // Handle notification tap
          print('Notification tapped: ${notificationResponse.payload}');
          if (notificationResponse.payload != null) {
            print('Notification payload: ${notificationResponse.payload}');
          }
        },
      );

      print('Notification plugin initialized: $initialized');

      // For iOS, explicitly request permissions on initialization
      if (Platform.isIOS) {
        final bool hasPermissions = await requestNotificationPermissions();
        print('iOS notification permissions granted: $hasPermissions');
      }

      // Check for stored preferences
      final prefs = await SharedPreferences.getInstance();
      final bool? notificationsEnabled = prefs.getBool(_notificationsEnabledKey);

      print('Stored notification preference: $notificationsEnabled');
      print('Notification service initialization complete');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<bool> requestNotificationPermissions() async {
    try {
      print('Requesting notification permissions...');
      
      // Request permissions for notifications
      if (Platform.isIOS) {
        final bool? result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        
        print('iOS notification permission result: $result');
        return result ?? false;
      } else if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        print('Android notification permission status: $status');
        return status.isGranted;
      }
      return false;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      // If enabling notifications, request permissions
      await requestNotificationPermissions();
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      print('Attempting to show notification: $title');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'icy_notifications',
            'ICY Notifications',
            channelDescription: 'Notifications from ICY application',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      
      print('Notification shown successfully: $title');
    } catch (e) {
      print('Error showing notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay timeOfDay,
    String? payload,
  }) async {
    try {
      print('Scheduling daily notification for ${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')}');
      
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      final effectiveDate =
          scheduledDate.isBefore(now)
              ? scheduledDate.add(const Duration(days: 1))
              : scheduledDate;

      print('Effective notification date: $effectiveDate');

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'daily_notifications',
            'Daily Notifications',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(effectiveDate, tz.local),
        platformChannelSpecifics,
        // Use correct parameters for the current Flutter Local Notifications version
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        // Set this parameter for Android 12+ compatibility
        androidScheduleMode:
            AndroidScheduleMode
                .inexactAllowWhileIdle, // Use inexact mode to avoid permission issues
      );
      
      print('Successfully scheduled daily notification with ID $id');
    } catch (e) {
      // Log the error but don't crash
      print('Failed to schedule notification: $e');

      // Try to show a regular notification instead as a test
      try {
        await showNotification(
          id: id,
          title: 'Test: $title',
          body: 'Fallback notification - $body',
          payload: payload,
        );
        print('Showed fallback notification');
      } catch (innerE) {
        print('Failed to show fallback notification: $innerE');
      }
    }
  }

  // Method needed for UserPreferencesBloc
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'scheduled_notifications',
          'Scheduled Notifications',
          channelDescription: 'One-time scheduled notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
