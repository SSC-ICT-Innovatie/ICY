import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/widgets/modal_wrapper.dart';

class SurveyInfo extends StatelessWidget {
  const SurveyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ModalWrapper(
          description: Text("You are 70% complete"),
          headerHeight: 70,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FTileGroup(
                description: Text("Survey Controls"),
                children: [
                  FTile(
                    title: FButton(
                      style: FButtonStyle.secondary,
                      onPress: () {},
                      label: Text("Pause Survey"),
                    ),
                  ),
                  FTile(
                    details: Text(
                      "Ensure you have gone through all questions before submission",
                    ),
                    title: FButton(onPress: () {}, label: Text("Submit Survey")),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
