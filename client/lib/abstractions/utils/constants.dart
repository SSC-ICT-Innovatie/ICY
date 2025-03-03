import 'package:flutter/cupertino.dart';

class AppConstants {
  // App general settings
  static const String appName = "ICY";
  static const double defaultPadding = 16.0;

  // Navigation constants
  static const int defaultNavigationIndex = 0;

  bool isLight(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return brightness == Brightness.light;
  }
}
