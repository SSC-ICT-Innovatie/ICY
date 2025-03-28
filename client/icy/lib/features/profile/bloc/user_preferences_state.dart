part of 'user_preferences_bloc.dart';

class UserPreferencesState extends Equatable {
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final String language;
  final String theme;
  final bool isLoading;

  const UserPreferencesState({
    required this.notificationsEnabled,
    required this.dailyReminderTime,
    required this.language,
    required this.theme,
    required this.isLoading,
  });

  factory UserPreferencesState.initial() {
    return const UserPreferencesState(
      notificationsEnabled: true,
      dailyReminderTime: '09:00',
      language: 'English',
      theme: 'System',
      isLoading: true,
    );
  }

  UserPreferencesState copyWith({
    bool? notificationsEnabled,
    String? dailyReminderTime,
    String? language,
    String? theme,
    bool? isLoading,
  }) {
    return UserPreferencesState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    dailyReminderTime,
    language,
    theme,
    isLoading,
  ];
}
