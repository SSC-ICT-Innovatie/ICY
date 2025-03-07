import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/challenge_model.dart';

class DailyChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;

  const DailyChallengeCard({Key? key, required this.challenge, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the color from hex string
    final color = _hexToColor(challenge.color);

    return FTile(
      title: Text(challenge.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(challenge.description),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: challenge.progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                challenge.progressText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                "+${challenge.reward.xp} XP",
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_getIconData(challenge.icon), color: color),
      ),
      onPress: onTap,
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
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'groups':
        return Icons.groups;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.star;
    }
  }
}
