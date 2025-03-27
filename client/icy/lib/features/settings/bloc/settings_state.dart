part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final bool useSystemTheme;
  final bool notificationsEnabled;
  final bool surveyRemindersEnabled;
  final String reminderTime;

  const SettingsState({
    required this.isDarkMode,
    required this.useSystemTheme,
    required this.notificationsEnabled,
    required this.surveyRemindersEnabled,
    required this.reminderTime,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isDarkMode: false,
      useSystemTheme: true,
      notificationsEnabled: true,
      surveyRemindersEnabled: true,
      reminderTime: '09:00',
    );
  }

  SettingsState copyWith({
    bool? isDarkMode,
    bool? useSystemTheme,
    bool? notificationsEnabled,
    bool? surveyRemindersEnabled,
    String? reminderTime,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      surveyRemindersEnabled:
          surveyRemindersEnabled ?? this.surveyRemindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  @override
  List<Object> get props => [
    isDarkMode,
    useSystemTheme,
    notificationsEnabled,
    surveyRemindersEnabled,
    reminderTime,
  ];
}
