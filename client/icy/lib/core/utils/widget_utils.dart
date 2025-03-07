import 'package:flutter/material.dart';

class WidgetUtils {
  /// Ensures a widget has a Material ancestor
  /// Use this for widgets that require Material context but are used in places without it
  static Widget ensureMaterial(Widget child) {
    return Material(type: MaterialType.transparency, child: child);
  }

  /// Safely constrains heights to prevent infinite height constraints
  static Widget safeHeight(Widget child, {double height = 200}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: child,
    );
  }
}
