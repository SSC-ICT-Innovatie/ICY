import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/widgets/modal_wrapper.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/features/home/pages/survey_info.dart';

class Survey extends StatelessWidget {
  final String img;
  const Survey({super.key, required this.img});

  @override
  Widget build(BuildContext context) {
    return ModalWrapper(
      prefix: Hero(
        tag: Platform.isIOS && AppConstants().hasNotch(context) ? '' : img,
        child: SizedBox(
          width: 40,
          height: 40,
          child: FButton.icon(
            style: context.theme.buttonStyles.outline.copyWith(
              contentStyle: context.theme.buttonStyles.outline.contentStyle
                  .copyWith(padding: EdgeInsets.zero),

              iconContentStyle: context
                  .theme
                  .buttonStyles
                  .outline
                  .iconContentStyle
                  .copyWith(padding: EdgeInsets.all(5)),
            ),

            onPress: () {
              showModalBottomSheet(
                context: context,
                constraints: BoxConstraints(maxHeight: 350),
                backgroundColor: Colors.transparent,
                builder: (context) => SurveyInfo(),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                img,
                height: 40,
                width: 40,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
      description: FProgress(value: 2 / 3),
      body: Container(
        height: AppConstants().screenSize(context).height,
        width: double.infinity,
        color: Colors.amber,
        child: Center(child: Text("test")),
      ),
    );
  }
}
