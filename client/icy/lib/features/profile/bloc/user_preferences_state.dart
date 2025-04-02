part of 'user_preferences_bloc.dart';

class UserPreferencesState extends Equatable {
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final String language;
  final String theme;
  final bool isLoading;
  final bool reminderEnabled; // Add this field
  final String? message; // Add message field
  final String? error; // Add error field

  const UserPreferencesState({
    required this.notificationsEnabled,
    required this.dailyReminderTime,
    required this.language,
    required this.theme,
    required this.isLoading,
    required this.reminderEnabled, // Make this required
    this.message,
    this.error,
  });

  factory UserPreferencesState.initial() {
    return const UserPreferencesState(
      notificationsEnabled: true,
      dailyReminderTime: '09:00',
      language: 'English',
      theme: 'System',
      isLoading: true,
      reminderEnabled: true, // Initialize with default value
    );
  }

  UserPreferencesState copyWith({
    bool? notificationsEnabled,
    String? dailyReminderTime,
    String? language,
    String? theme,
    bool? isLoading,
    bool? reminderEnabled, // Add this parameter
    String? message, // Add message parameter
    String? error, // Add error parameter
  }) {
    return UserPreferencesState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isLoading: isLoading ?? this.isLoading,
      reminderEnabled:
          reminderEnabled ?? this.reminderEnabled, // Include in copyWith
      message: message, // Override with new message or null
      error: error, // Override with new error or null
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    dailyReminderTime,
    language,
    theme,
    isLoading,
    reminderEnabled,
    message,
    error,
  ];
}
