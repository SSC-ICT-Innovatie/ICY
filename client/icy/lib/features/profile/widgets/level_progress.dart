import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/user_model.dart';

class LevelProgressCard extends StatelessWidget {
  final LevelModel level;

  const LevelProgressCard({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    final double progressPercent = level.xp.current / level.xp.nextLevel;
    final remainingXp = level.xp.nextLevel - level.xp.current;

    return FTileGroup(
      description: Text("Level Progress"),
      children: [
        FTile(
          title: Text("Level ${level.current}: ${level.title}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Text(
                "${level.xp.current} / ${level.xp.nextLevel} XP (${(progressPercent * 100).toInt()}%)",
              ),
              Text(
                "$remainingXp XP needed for next level",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
