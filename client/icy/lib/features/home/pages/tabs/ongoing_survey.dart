import 'dart:io';

import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/features/home/pages/survey.dart';

class OngoingSurvey extends StatelessWidget {
  const OngoingSurvey({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FTileGroup.builder(
        count: 50,
        tileBuilder: (context, index) {
          final surveyThumnail = "https://picsum.photos/200/300?random=$index";
          return FTile(
            title: Text("Survey $index"),
            subtitle: Text("Description of survey $index"),
            prefixIcon: Hero(
              tag: surveyThumnail,
              child: AnimatedBorderProgressIndicator(
                borderRadius: 8,
                value: index / 100 * 0.9,
                color: context.theme.colorScheme.primary,
                curve: Curves.easeInBack,

                strokeWidth: 4,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.secondary,
                    image: DecorationImage(
                      // laat een icon zien in plaats van een afbeelding als er geen afbeelding is
                      image: NetworkImage(surveyThumnail),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            suffixIcon: FButton.icon(
              onPress: () {},
              child: FIcon(FAssets.icons.chevronRight),
            ),
            onPress: () {
              if (Platform.isIOS) {
                if (AppConstants().hasNotch(context)) {
                  showCupertinoSheet(
                    context: context,
                    pageBuilder: (context) => Survey(img: surveyThumnail),
                  );
                } else {
                  // For older iPhones without notch and android, use a different modal approach
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              SafeArea(child: Survey(img: surveyThumnail)),
                    ),
                  );
                }
              } else {
                // Android and other platforms
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Survey(img: surveyThumnail),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
