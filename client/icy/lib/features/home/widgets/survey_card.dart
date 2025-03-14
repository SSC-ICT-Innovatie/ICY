import 'package:flutter/material.dart';
import 'package:icy/data/models/survey_model.dart';

class SurveyCard extends StatelessWidget {
  final SurveyModel survey;
  final VoidCallback onTap;

  const SurveyCard({super.key, required this.survey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Implementation of the survey card
    return Card(
      // Existing implementation...
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                survey.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                survey.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    survey.estimatedTime,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const Spacer(),
                  // Show rewards
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '+${survey.reward.xp} XP',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
