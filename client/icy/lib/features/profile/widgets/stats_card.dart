import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/user_model.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      description: Text("Your Stats"),
      children: [
        FTile(
          title: Text("Surveys Completed"),
          prefixIcon: Text(
            stats.surveysCompleted.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        FTile(
          title: Text("Streak"),
          suffixIcon: Text(
            "${stats.streak.current} days (Best: ${stats.streak.best})",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        FTile(
          title: Text("Total XP"),
          prefixIcon: Text(
            stats.totalXp.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        FTile(
          title: Text("Participation Rate"),
          suffixIcon: Text(
            "${(stats.participationRate * 100).toInt()}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        FTile(
          title: Text("Coins"),
          prefixIcon: Text(
            stats.totalCoins.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
