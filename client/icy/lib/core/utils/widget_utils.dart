import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: child,
      ),
    );
  }

  /// Ensures a safe context is used for BLoC operations
  static T safeReadBloc<T extends BlocBase<Object?>>(BuildContext context) {
    try {
      return BlocProvider.of<T>(context);
    } catch (e) {
      throw Exception(
        'Could not find BLoC $T. Make sure the context contains the provider.',
      );
    }
  }

  /// Handle network images with error fallback
  static Widget networkImageWithFallback(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image)),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
