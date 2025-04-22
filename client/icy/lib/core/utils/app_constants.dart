import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';

class AppConstants {
  // Singleton pattern
  static final AppConstants _instance = AppConstants._internal();

  factory AppConstants() => _instance;

  AppConstants._internal();

  // Theme helpers
  bool isLight(BuildContext context) {
    // First check settings if user has explicitly set theme preference
    final settings = context.read<SettingsBloc>().state;

    if (!settings.useSystemTheme) {
      // User has explicitly set a theme preference
      return !settings.isDarkMode;
    }

    // Otherwise use system theme
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.light;
  }

  bool isDark(BuildContext context) => !isLight(context);




}
