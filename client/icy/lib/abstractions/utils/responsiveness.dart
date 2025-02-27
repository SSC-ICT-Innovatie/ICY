import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  /// The current screen width
  double get width => MediaQuery.of(context).size.width;

  bool get isMobile => width < 650;

  bool get isTablet => width < 1100 && width >= 650;

  bool get isDesktop => width >= 1100;

  bool get isLargeDesktop => width >= 1500;
}
