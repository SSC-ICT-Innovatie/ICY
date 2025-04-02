import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icy/abstractions/utils/constants.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  SettingsBloc({required this.prefs}) : super(SettingsState.initial()) {
    on<InitSettingsEvent>(_onInitSettings);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<ToggleUseSystemThemeEvent>(_onToggleUseSystemTheme);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<ToggleSurveyRemindersEvent>(_onToggleSurveyReminders);
    on<SetReminderTimeEvent>(_onSetReminderTime);

    // Load settings from SharedPreferences
    add(InitSettingsEvent());
  }

  void _onInitSettings(InitSettingsEvent event, Emitter<SettingsState> emit) {
    final isDarkMode = prefs.getBool(AppConstants.isDarkModeKey) ?? false;
    final useSystemTheme =
        prefs.getBool(AppConstants.useSystemThemeKey) ?? true;
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final surveyRemindersEnabled =
        prefs.getBool('surveyRemindersEnabled') ?? true;
    final reminderTime = prefs.getString('reminderTime') ?? '09:00';

    // Update AppConstants cache
    AppConstants().updateThemeCache(
      isDarkMode: isDarkMode,
      useSystemTheme: useSystemTheme,
    );

    emit(
      state.copyWith(
        isDarkMode: isDarkMode,
        useSystemTheme: useSystemTheme,
        notificationsEnabled: notificationsEnabled,
        surveyRemindersEnabled: surveyRemindersEnabled,
        reminderTime: reminderTime,
      ),
    );
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<SettingsState> emit) {
    prefs.setBool(AppConstants.isDarkModeKey, event.isDarkMode);

    // Update AppConstants cache
    AppConstants().updateThemeCache(isDarkMode: event.isDarkMode);

    emit(state.copyWith(isDarkMode: event.isDarkMode));
  }

  void _onToggleUseSystemTheme(
    ToggleUseSystemThemeEvent event,
    Emitter<SettingsState> emit,
  ) {
    prefs.setBool(AppConstants.useSystemThemeKey, event.useSystemTheme);

    // Update AppConstants cache
    AppConstants().updateThemeCache(useSystemTheme: event.useSystemTheme);

    emit(state.copyWith(useSystemTheme: event.useSystemTheme));
  }

  void _onToggleNotifications(
    ToggleNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) {
    prefs.setBool('notificationsEnabled', event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  void _onToggleSurveyReminders(
    ToggleSurveyRemindersEvent event,
    Emitter<SettingsState> emit,
  ) {
    prefs.setBool('surveyRemindersEnabled', event.enabled);
    emit(state.copyWith(surveyRemindersEnabled: event.enabled));
  }

  void _onSetReminderTime(
    SetReminderTimeEvent event,
    Emitter<SettingsState> emit,
  ) {
    prefs.setString('reminderTime', event.time);
    emit(state.copyWith(reminderTime: event.time));
  }
}
