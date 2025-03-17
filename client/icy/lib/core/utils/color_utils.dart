import 'package:flutter/material.dart';

/// A utility class for color-related operations
class ColorUtils {
  /// Convert opacity to alpha value (0.0-1.0 to 0-255)
  static int opacityToAlpha(double opacity) {
    return (opacity * 255).round();
  }

  /// Apply opacity to a color using the withAlpha method
  /// This helps replace the deprecated withOpacity method
  static Color withOpacityValue(Color color, double opacity) {
    return color.withAlpha(opacityToAlpha(opacity));
  }

  /// Parse a hex color string into a Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
