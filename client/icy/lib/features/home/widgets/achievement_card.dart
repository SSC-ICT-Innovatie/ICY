import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/core/utils/color_utils.dart';
import 'package:intl/intl.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(achievement.color);
    final dateFormatter = DateFormat('dd MMM, HH:mm');
    final date = DateTime.parse(achievement.timestamp);

    return FTile(
      title: Text(achievement.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(achievement.description),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormatter.format(date),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                achievement.reward,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
      prefixIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorUtils.applyOpacity(color, 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_getIconData(achievement.icon), color: color),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    return ColorUtils.hexToColor(hexString);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'star':
        return Icons.star;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'military_tech':
        return Icons.military_tech;
      case 'local_fire_department':
        return Icons.local_fire_department;
      default:
        return Icons.star;
    }
  }
}
