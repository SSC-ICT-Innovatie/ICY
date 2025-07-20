import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/utils/constants.dart';

class ModalWrapper extends StatelessWidget {
  final Widget body;
  final Widget? prefix;
  final String? title;
  final double? headerHeight;
  final Widget? description;
  const ModalWrapper({
    super.key,
    required this.body,
    this.title,
    this.description,
    this.prefix,
    this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      contentPad: false,
      content: SafeArea(
 
        child: Column(
          children: [
            BlurryContainer(
              blur: 40,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
                topLeft:
                    Platform.isIOS && AppConstants().hasNotch(context)
                        ? const Radius.circular(8)
                        : Radius.zero,
                topRight:
                    Platform.isIOS && AppConstants().hasNotch(context)
                        ? const Radius.circular(8)
                        : Radius.zero,
              ),

              height:  headerHeight,
              child: Column(
                spacing: 14,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      prefix ?? const SizedBox(),
                      Text(
                        title ?? 'Example',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color:
                              context
                                  .theme
                                  .headerStyle
                                  .nestedStyle
                                  .titleTextStyle
                                  .color,
                        ),
                      ),
                      FButton.icon(
                        style: FButtonStyle.ghost,
                        onPress: () => Navigator.of(context).pop(),
                        child: FIcon(FAssets.icons.x),
                      ),
                    ],
                  ),
                  description != null ? (description!) : SizedBox(),
                ],
              ),
            ),
            FDivider(
              style: context.theme.dividerStyles.horizontalStyle.copyWith(
                padding: const EdgeInsets.only(bottom: 2),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
