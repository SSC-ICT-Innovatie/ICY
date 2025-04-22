import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/core/utils/url_utils.dart';

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

  /// Network image with placeholder fallback
  static Widget networkImageWithFallback(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
    Color? backgroundColor,
  }) {
    final bg = backgroundColor ?? Colors.grey.shade300;
    final url = UrlUtils.getImageUrl(imageUrl);
    
    return Container(
      width: width,
      height: height,
      color: bg,
      child: imageUrl == null || imageUrl.isEmpty
          ? buildAvatarPlaceholder(
              placeholder: placeholder,
              width: width,
              height: height,
              backgroundColor: bg,
            )
          : UrlUtils.isLocalFilePath(imageUrl)
              ? _buildFileImage(imageUrl, width, height, fit, placeholder, bg)
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: fit,
                  width: width,
                  height: height,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade500,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('Error loading image from $url: $error');
                    return buildAvatarPlaceholder(
                      placeholder: placeholder,
                      width: width,
                      height: height,
                      backgroundColor: bg,
                    );
                  },
                ),
    );
  }
  
  /// Build image from local file path
  static Widget _buildFileImage(
    String imageUrl,
    double? width,
    double? height,
    BoxFit fit,
    String? placeholder,
    Color backgroundColor,
  ) {
    final file = UrlUtils.getFileFromUri(imageUrl);
    
    if (file != null && file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading file image: $error');
          return buildAvatarPlaceholder(
            placeholder: placeholder,
            width: width,
            height: height,
            backgroundColor: backgroundColor,
          );
        },
      );
    } else {
      return buildAvatarPlaceholder(
        placeholder: placeholder,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
      );
    }
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
