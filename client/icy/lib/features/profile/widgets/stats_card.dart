import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/user_model.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return FTileGroup(
      description: Text("Stats"),
      children: [
        FTile(
          title: Text("Surveys Completed"),
          // Replace Chip with a custom widget that doesn't need Material
          prefixIcon: _buildCustomChip(context, "${stats.surveysCompleted}"),
        ),
        FTile(
          title: Text("Current Streak"),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 4),
              Text(
                "${stats.streak.current} days",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        FTile(
          title: Text("Best Streak"),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "${stats.streak.best} days",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        FTile(
          title: Text("Total XP"),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.purple),
              const SizedBox(width: 4),
              Text(
                "${stats.totalXp}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        FTile(
          title: Text("Total Coins"),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "${stats.totalCoins}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        FTile(
          title: Text("Participation Rate"),
          suffixIcon: Text("${(stats.participationRate * 100).toInt()}%"),
        ),
      ],
    );
  }

  // Custom widget to replace Chip that doesn't require Material
  Widget _buildCustomChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
