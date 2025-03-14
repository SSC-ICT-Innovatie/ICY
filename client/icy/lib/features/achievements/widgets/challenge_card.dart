import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final String color;
  final String reward;
  final double? progress;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.reward,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final challengeColor = _hexToColor(color);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: challengeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getIconData(icon), color: challengeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Progress indicator
              if (progress != null) ...[
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(challengeColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress! * 100).toInt()}% Complete',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],

              // Reward
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reward: $reward',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'flame':
        return Icons.local_fire_department;
      case 'target':
        return Icons.gps_fixed;
      case 'calendar':
        return Icons.calendar_today;
      case 'award':
        return Icons.military_tech;
      case 'star':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }
}
