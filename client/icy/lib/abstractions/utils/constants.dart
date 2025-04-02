import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static final AppConstants _instance = AppConstants._internal();
  factory AppConstants() => _instance;
  AppConstants._internal();

  // Keys for SharedPreferences
  static const String isDarkModeKey = 'isDarkMode';
  static const String useSystemThemeKey = 'useSystemTheme';

  // App general settings
  static const String appName = "ICY";
  static const double defaultPadding = 16.0;
  // Get device info to determine if it has rounded corners
  bool hasNotch(BuildContext context) =>
      MediaQuery.of(context).viewPadding.bottom > 0;
  Size screenSize(BuildContext context) => MediaQuery.sizeOf(context);

  // Navigation constants
  static const int defaultNavigationIndex = 0;

  // Theme detection with respect to user settings
  bool isLight(BuildContext context) {
    // First try to get from cached settings
    final useSystemTheme = _cachedUseSystemTheme;
    final isDarkMode = _cachedIsDarkMode;

    if (useSystemTheme == true) {
      // If using system theme, check the system brightness
      final brightness = MediaQuery.platformBrightnessOf(context);
      return brightness == Brightness.light;
    } else {
      // Otherwise use the manual setting
      return isDarkMode !=
          true; // If isDarkMode is null or false, return true (light theme)
    }
  }

  // Cache for theme preferences to avoid excessive SharedPreferences reads
  bool? _cachedUseSystemTheme;
  bool? _cachedIsDarkMode;

  // Initialize cache from SharedPreferences
  Future<void> initThemeCache() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUseSystemTheme = prefs.getBool(useSystemThemeKey);
    _cachedIsDarkMode = prefs.getBool(isDarkModeKey);
  }

  // Update cache when settings change
  void updateThemeCache({bool? isDarkMode, bool? useSystemTheme}) {
    if (isDarkMode != null) _cachedIsDarkMode = isDarkMode;
    if (useSystemTheme != null) _cachedUseSystemTheme = useSystemTheme;
  }
}
