import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/home/pages/tabs/new.dart';
import 'package:icy/features/home/pages/tabs/ongoing_survey.dart';
import 'package:icy/features/home/pages/tabs/results.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: Column(
        children: [
          FHeader(
            title: Text("Icy"),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  // in het echt checkt t altijd of de gebruiker een melding heeft ontvangen voordat we een badge laten zien
                  Badge(label: Text("1"), child: FIcon(FAssets.icons.bell)),
                ],
              ),
            ],
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
