import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_preferences_event.dart';
part 'user_preferences_state.dart';

class UserPreferencesBloc
    extends Bloc<UserPreferencesEvent, UserPreferencesState> {
  final SharedPreferences _prefs;
  final SystemNotificationService _notificationService;

  static const _notificationEnabledKey = 'user_notifications_enabled';
  static const _dailyReminderTimeKey = 'user_daily_reminder_time';
  static const _languageKey = 'user_language';
  static const _themeKey = 'user_theme';
  static const _reminderEnabledKey =
      'reminderEnabled'; // Add this key for reminder enabled flag

  UserPreferencesBloc({
    required SharedPreferences prefs,
    SystemNotificationService? notificationService,
  }) : _prefs = prefs,
       _notificationService =
           notificationService ?? SystemNotificationService(),
       super(UserPreferencesState.initial()) {
    on<InitializeUserPreferencesEvent>(_onInitializeUserPreferences);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<SetDailyReminderTimeEvent>(_onSetDailyReminderTime);
    on<SetLanguageEvent>(_onSetLanguage);
    on<SetThemeEvent>(_onSetTheme);
    on<EnableRemindersEvent>(
      _onEnableReminders,
    ); // Register enableReminders event handler

    // Load preferences on initialization
    add(InitializeUserPreferencesEvent());
  }

  void _onInitializeUserPreferences(
    InitializeUserPreferencesEvent event,
    Emitter<UserPreferencesState> emit,
  ) async {
    final notificationsEnabled =
        _prefs.getBool(_notificationEnabledKey) ?? true;
    final reminderTime = _prefs.getString(_dailyReminderTimeKey) ?? '09:00';
    final language = _prefs.getString(_languageKey) ?? 'English';
    final theme = _prefs.getString(_themeKey) ?? 'System';
    final reminderEnabled =
        _prefs.getBool(_reminderEnabledKey) ??
        true; // Get reminder enabled state

    // Sync with notification service
    await _notificationService.setNotificationsEnabled(notificationsEnabled);

    // If notifications are enabled, schedule the reminder
    if (notificationsEnabled && reminderEnabled) {
      await _scheduleDailyReminder(reminderTime);
      print('Initialized with daily reminders enabled at $reminderTime');
    } else {
      print('Initialized with daily reminders disabled (notifications: $notificationsEnabled, reminders: $reminderEnabled)');
    }

    emit(
      state.copyWith(
        notificationsEnabled: notificationsEnabled,
        dailyReminderTime: reminderTime,
        language: language,
        theme: theme,
        reminderEnabled: reminderEnabled, // Add reminderEnabled to state
        isLoading: false,
      ),
    );
  }

  void _onToggleNotifications(
    ToggleNotificationsEvent event,
    Emitter<UserPreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _prefs.setBool(_notificationEnabledKey, event.enabled);
      await _notificationService.setNotificationsEnabled(event.enabled);

      // When enabling notifications, also enable reminders by default
      if (event.enabled) {
        await _prefs.setBool(_reminderEnabledKey, true);
        
        // First request permissions explicitly
        final hasPermissions = await _notificationService.requestNotificationPermissions();
        
        if (hasPermissions) {
          // Schedule daily reminder with existing time
          await _scheduleDailyReminder(state.dailyReminderTime);

          // If notifications are being enabled, show a confirmation notification
          await _notificationService.showNotification(
            id: 0,
            title: 'Notifications Enabled',
            body: 'Daily reminders are now active at ${state.dailyReminderTime}',
          );
          
          emit(state.copyWith(
            notificationsEnabled: event.enabled, 
            reminderEnabled: true,
            isLoading: false,
            message: 'Notifications and daily reminders enabled',
          ));
        } else {
          // Permissions denied
          await _prefs.setBool(_notificationEnabledKey, false);
          await _prefs.setBool(_reminderEnabledKey, false);
          
          emit(state.copyWith(
            notificationsEnabled: false, 
            reminderEnabled: false,
            isLoading: false,
            error: 'Notification permissions denied. Please enable in device settings.',
          ));
        }
      } else {
        // When disabling notifications, disable reminders too
        await _prefs.setBool(_reminderEnabledKey, false);
        
        // Cancel scheduled notifications if disabled
        await _notificationService.cancelAllNotifications();
        
        emit(state.copyWith(
          notificationsEnabled: event.enabled, 
          reminderEnabled: false,
          isLoading: false,
          message: 'Notifications and daily reminders disabled',
        ));
      }

      // Clear messages after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!emit.isDone) {
          emit(state.copyWith(message: null, error: null));
        }
      });
    } catch (e) {
      print('Error in notification toggle: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update notification settings: $e',
      ));
      
      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!emit.isDone) {
          emit(state.copyWith(error: null));
        }
      });
    }
  }

  void _onSetDailyReminderTime(
    SetDailyReminderTimeEvent event,
    Emitter<UserPreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _prefs.setString(_dailyReminderTimeKey, event.time);

      // Always schedule the daily reminder if notifications are enabled
      if (state.notificationsEnabled) {
        await _scheduleDailyReminder(event.time);
        print('Scheduled daily reminder for ${event.time}');
        
        emit(state.copyWith(
          dailyReminderTime: event.time, 
          isLoading: false,
          message: 'Daily reminder time updated to ${event.time}',
        ));
      } else {
        emit(state.copyWith(
          dailyReminderTime: event.time, 
          isLoading: false,
          message: 'Reminder time saved. Enable notifications to activate reminders.',
        ));
      }

      // Clear message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!emit.isDone) {
          emit(state.copyWith(message: null));
        }
      });
    } catch (e) {
      print('Error setting reminder time: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update reminder time: $e',
      ));
      
      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!emit.isDone) {
          emit(state.copyWith(error: null));
        }
      });
    }
  }

  // Helper method to schedule daily reminders
  Future<void> _scheduleDailyReminder(String timeString) async {
    try {
      print('Attempting to schedule daily reminder for $timeString');
      
      // First cancel any existing reminders
      await _notificationService.cancelNotification(1);
      print('Cancelled existing notifications');

      // Parse time string (format: "HH:mm")
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);

        if (hour != null && minute != null) {
          // Convert to TimeOfDay for scheduling
          final timeOfDay = TimeOfDay(hour: hour, minute: minute);

          await _notificationService.scheduleDailyNotification(
            id: 1,
            title: 'ICY Daily Check-in',
            body: 'Remember to complete your daily activities!',
            timeOfDay: timeOfDay,
          );

          print('Successfully scheduled daily reminder for $timeString');
        } else {
          print('Error: Could not parse hour ($hour) or minute ($minute) from $timeString');
        }
      } else {
        print('Error: Invalid time format $timeString, expected HH:mm');
      }
    } catch (e) {
      print('Error scheduling daily reminder: $e');
    }
  }

  // Helper method to convert string time to TimeOfDay
  TimeOfDay _getTimeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 9, minute: 0); // Default
  }

  void _onSetLanguage(
    SetLanguageEvent event,
    Emitter<UserPreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _prefs.setString(_languageKey, event.language);

    emit(state.copyWith(language: event.language, isLoading: false));
  }

  void _onSetTheme(
    SetThemeEvent event,
    Emitter<UserPreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _prefs.setString(_themeKey, event.theme);

    emit(state.copyWith(theme: event.theme, isLoading: false));
  }

  Future<void> _onEnableReminders(
    EnableRemindersEvent event,
    Emitter<UserPreferencesState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _prefs.setBool(_reminderEnabledKey, event.enable);

      if (event.enable && state.notificationsEnabled) {
        final timeOfDay = _getTimeOfDayFromString(state.dailyReminderTime);
        await _notificationService.scheduleDailyNotification(
          id: 1,
          title: 'Daily Survey Reminder',
          body: 'Don\'t forget to complete your daily surveys!',
          timeOfDay: timeOfDay,
        );
      } else {
        await _notificationService.cancelNotification(1);
      }

      emit(
        state.copyWith(
          reminderEnabled: event.enable,
          isLoading: false,
          message:
              event.enable
                  ? 'Daily reminders enabled'
                  : 'Daily reminders disabled',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update reminder settings: $e',
        ),
      );
    }
  }
}
