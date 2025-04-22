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
    String? placeholder,
    Color? backgroundColor,
  }) {
    // Don't use placeholder.co URLs as they cause issues on some Android devices
    if (url.contains('placehold.co') || url.contains('via.placeholder.com')) {
      return buildAvatarPlaceholder(
        placeholder: placeholder,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
      );
    }
    
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return buildAvatarPlaceholder(
          placeholder: placeholder,
          width: width,
          height: height,
          backgroundColor: backgroundColor,
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
  
  /// Build a placeholder widget for avatars with initials
  static Widget buildAvatarPlaceholder({
    String? placeholder,
    double? width,
    double? height,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? Colors.blue.shade300;
    final displayText = placeholder?.isNotEmpty == true
        ? placeholder!.substring(0, placeholder.length > 2 ? 2 : placeholder.length).toUpperCase()
        : 'U';
        
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        shape: width == height ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: width != height ? BorderRadius.circular(8) : null,
      ),
      child: Center(
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
  
  /// Create an avatar widget with proper fallback
  static Widget avatar(
    String? imageUrl,
    String userName, {
    double size = 40,
    Color? backgroundColor,
  }) {
    return ClipOval(
      child: imageUrl != null && imageUrl.isNotEmpty && !imageUrl.contains('placeholder')
          ? networkImageWithFallback(
              imageUrl,
              width: size,
              height: size,
              placeholder: userName,
              backgroundColor: backgroundColor,
            )
          : buildAvatarPlaceholder(
              placeholder: userName,
              width: size,
              height: size,
              backgroundColor: backgroundColor,
            ),
    );
  }
}
