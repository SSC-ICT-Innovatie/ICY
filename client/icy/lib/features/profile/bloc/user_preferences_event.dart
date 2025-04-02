part of 'user_preferences_bloc.dart';

abstract class UserPreferencesEvent {}

class InitializeUserPreferencesEvent extends UserPreferencesEvent {}

class ToggleNotificationsEvent extends UserPreferencesEvent {
  final bool enabled;

  ToggleNotificationsEvent({required this.enabled});
}

class SetDailyReminderTimeEvent extends UserPreferencesEvent {
  final String time;

  SetDailyReminderTimeEvent({required this.time});
}

class SetLanguageEvent extends UserPreferencesEvent {
  final String language;

  SetLanguageEvent({required this.language});
}

class SetThemeEvent extends UserPreferencesEvent {
  final String theme;

  SetThemeEvent({required this.theme});
}

// Add the missing event
class EnableRemindersEvent extends UserPreferencesEvent {
  final bool enable;

  EnableRemindersEvent({required this.enable});
}
