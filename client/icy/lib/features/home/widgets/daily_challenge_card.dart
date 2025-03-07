import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/challenge_model.dart';

class DailyChallengeCard extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback? onTap;

  const DailyChallengeCard({Key? key, required this.primaryColor, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                children: const [
                  Text(
                    "Daily Challenge Available",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "3 quick questions • Complete for 50 XP",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
