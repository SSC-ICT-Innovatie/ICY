import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:icy/features/home/pages/tabs/new.dart';
import 'package:icy/features/home/pages/tabs/ongoing_survey.dart';
import 'package:icy/features/home/pages/tabs/results.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: Column(
        children: [
          FHeader(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Lottie.asset('assets/animations/tabs/1.lottie'),
                ),
                Icon(
                  Icons.local_fire_department,
                  size: 35,
                  color: context.theme.colorScheme.primary,
                ),
                Icon(
                  Icons.diamond,
                  size: 35,
                  color: context.theme.colorScheme.primary,
                ),
                Icon(
                  Icons.bolt,
                  size: 35,
                  color: context.theme.colorScheme.primary,
                ),
              ],
            ),
          ).blurry(),
          FDivider(
            style: context.theme.dividerStyles.horizontalStyle.copyWith(
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      content: Scrollbar(
        child: FTabs(
          tabs: [
            FTabEntry(label: Text("New"), content: NewSurvey()),
            FTabEntry(label: Text("Ongoing"), content: OngoingSurvey()),
            FTabEntry(label: Text("Results"), content: SurveyResults()),
          ],
          initialIndex: 0,
        ),
      ),
    );
  }
}
