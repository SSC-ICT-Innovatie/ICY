import 'package:flutter/cupertino.dart';

class AppConstants {
  // App general settings
  static const String appName = "ICY";
  static const double defaultPadding = 16.0;
  // Get device info to determine if it has rounded corners
  bool hasNotch(BuildContext context) =>
      MediaQuery.of(context).viewPadding.bottom > 0;
  Size screenSize(BuildContext context) => MediaQuery.sizeOf(context);

  // Navigation constants
  static const int defaultNavigationIndex = 0;

  bool isLight(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return brightness == Brightness.light;
  }
}
