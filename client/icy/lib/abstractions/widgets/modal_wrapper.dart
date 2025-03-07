import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWrapper {
  /// Shows a modal dialog with the given child widget.
  /// Uses CupertinoModalPopupRoute for iOS-style bottom sheet.
  static Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
    Color backgroundColor = Colors.white,
    BorderRadius? borderRadius,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) {
        return Material(color: Colors.transparent, child: child);
      },
    );
  }

  /// Shows a sliding bottom sheet with the given child widget.
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
      builder: (context) => child,
    );
  }
}
