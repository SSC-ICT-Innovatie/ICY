import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/survey_model.dart';

class SurveyCard extends StatelessWidget {
  final SurveyModel survey;
  final VoidCallback? onTap;

  const SurveyCard({Key? key, required this.survey, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FTile(
      prefixIcon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getColorForTag(
            context,
            survey.tags.isNotEmpty ? survey.tags.first : null,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.assignment, color: Colors.white),
      ),
      title: Text(survey.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(survey.description),
          const SizedBox(height: 8),

          // Survey details row
          Row(
            children: [
              _infoChip(Icons.help_outline, '${survey.questions} Qs'),
              const SizedBox(width: 8),
              _infoChip(Icons.access_time, survey.estimatedTime),
              const Spacer(),
              // The reward
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 14,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${survey.reward.coins}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 14, color: Colors.amber[700]),
                  const SizedBox(width: 2),
                  Text(
                    '+${survey.reward.xp} XP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (survey.progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: survey.progress,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Text(
              'Progress: ${(survey.progress! * 100).toInt()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],

          if (survey.expiresAt != null) ...[
            const SizedBox(height: 4),
            _getExpiryInfo(survey.expiresAt!),
          ],
        ],
      ),
      onPress: onTap,
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _getExpiryInfo(String expiryDate) {
    final expiry = DateTime.parse(expiryDate);
    final now = DateTime.now();
    final difference = expiry.difference(now);

    Color color = Colors.green;
    String text = 'Expires in ';

    if (difference.inHours < 24) {
      color = Colors.orange;
      text += '${difference.inHours} hours';
    } else {
      text += '${difference.inDays} days';
    }

    return Text(text, style: TextStyle(fontSize: 12, color: color));
  }

  Color _getColorForTag(BuildContext context, String? tag) {
    if (tag == null) return Colors.blue;

    switch (tag.toLowerCase()) {
      case 'dagelijks':
        return Colors.blue;
      case 'wekelijks':
        return Colors.purple;
      case 'maandelijks':
        return Colors.green;
      case 'hulpmiddelen':
        return Colors.orange;
      case 'werkplek':
        return Colors.teal;
      case 'afdeling':
        return Colors.deepPurple;
      case 'samenwerking':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}
