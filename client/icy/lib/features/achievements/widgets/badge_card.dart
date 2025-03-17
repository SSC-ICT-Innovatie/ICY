import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final String color;
  final double? progress;
  final bool isEarned;
  final VoidCallback onTap;

  const BadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.progress,
    this.isEarned = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = _hexToColor(color);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Badge content
            Padding(
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
                          color: badgeColor.withAlpha(
                            26,
                          ), // 0.1 opacity = ~26 alpha
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIconData(icon), color: badgeColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isEarned && progress != null)
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  badgeColor,
                                ),
                              ),
                          ],
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
                ],
              ),
            ),

            // Earned indicator
            if (isEarned)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Earned',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
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
      case 'star':
        return Icons.star;
      case 'award':
        return Icons.military_tech;
      case 'trophy':
        return Icons.emoji_events;
      case 'medal':
        return Icons.workspace_premium;
      case 'certificate':
        return Icons.card_membership;
      default:
        return Icons.emoji_events;
    }
  }
}
