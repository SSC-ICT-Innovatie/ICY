import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/achievement_model.dart';
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
      prefixIcon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_getIconData(achievement.icon), color: color),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'people':
      case 'groups':
        return Icons.people;
      case 'rate_review':
        return Icons.rate_review;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'bolt':
        return Icons.bolt;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.star;
    }
  }
}
