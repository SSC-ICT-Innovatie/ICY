import 'package:flutter/material.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/home/widgets/survey_card.dart';

class NewSurvey extends StatelessWidget {
  final List<SurveyModel> surveys;

  const NewSurvey({Key? key, this.surveys = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No new surveys available today",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              "Check back later for more surveys",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Use ListView.builder directly without Container for better integration
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surveys.length,
      // Important: disable scrolling on this inner ListView
      physics: const NeverScrollableScrollPhysics(),
      // Make sure it takes the minimum required space
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final survey = surveys[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SurveyCard(
            survey: survey,
            onTap: () {
              // Handle survey selection
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening survey: ${survey.title}')),
              );
            },
          ),
        );
      },
    );
  }
}
