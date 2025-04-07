import 'package:flutter/material.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/survey/screens/survey_screen.dart';

class DailyChallengeCard extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback? onTap;
  final SurveyModel? dailySurvey;
  final bool isLoading;

  const DailyChallengeCard({
    super.key,
    required this.primaryColor,
    this.onTap,
    this.dailySurvey,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (dailySurvey == null) {
      return _buildNoSurveyCard(context);
    }

    return GestureDetector(
      onTap: () {
        // Navigate to the survey screen if a survey is available
        if (dailySurvey != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SurveyScreen(survey: dailySurvey!),
            ),
          );
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily Challenge Available",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    dailySurvey!.questions.length > 1
                        ? "${dailySurvey!.questions.length} questions • Complete for ${dailySurvey!.reward.xp} XP"
                        : "1 question • Complete for ${dailySurvey!.reward.xp} XP",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(width: 24, height: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 200, height: 18, color: Colors.grey.shade300),
                const SizedBox(height: 6),
                Container(width: 150, height: 14, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSurveyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Caught Up!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "You've completed all daily challenges",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
