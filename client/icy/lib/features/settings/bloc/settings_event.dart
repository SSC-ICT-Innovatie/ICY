part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class InitSettingsEvent extends SettingsEvent {}

class ToggleThemeEvent extends SettingsEvent {
  final bool isDarkMode;

  const ToggleThemeEvent({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

class ToggleUseSystemThemeEvent extends SettingsEvent {
  final bool useSystemTheme;

  const ToggleUseSystemThemeEvent({required this.useSystemTheme});

  @override
  List<Object> get props => [useSystemTheme];
}

class ToggleNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleNotificationsEvent({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class ToggleSurveyRemindersEvent extends SettingsEvent {
  final bool enabled;

  const ToggleSurveyRemindersEvent({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class SetReminderTimeEvent extends SettingsEvent {
  final String time;

  const SetReminderTimeEvent({required this.time});

  @override
  List<Object> get props => [time];
}
