import 'package:flutter/material.dart';
import 'package:icy/core/utils/color_utils.dart';

class HomeHeader extends StatelessWidget {
  final dynamic user;
  final Color primaryColor;

  const HomeHeader({super.key, required this.user, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final Color secondaryColor = Colors.amber.shade500;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        // Amber gradient for the header
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false, // Don't pad the bottom since we're in a flexible space
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Notification Row - now it's part of the AppBar so we can hide it
            const SizedBox(height: 50), // Space for the AppBar title
            // Enhanced Gamification Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  // Fix deprecated withOpacity
                  color: ColorUtils.applyOpacity(Colors.black, 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gamification metrics row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Streak Counter
                        _buildStreakCounter(user),
                        // XP Points
                        _buildXpCounter(user),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Team competition element
                    _buildTeamCompetition(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCounter(dynamic user) {
    // Access stats safely using dynamic
    int streakValue = 0;
    try {
      streakValue = user?.stats?.streak?.current ?? 0;
    } catch (e) {
      print("Could not access streak: $e");
    }

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            Icons.local_fire_department,
            key: const ValueKey(1),
            color: Colors.redAccent,
            size: 26,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$streakValue-Day Streak",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const Text(
              "Keep it up!",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildXpCounter(dynamic user) {
    // Access stats safely using dynamic
    int xpValue = 0;
    int levelValue = 1;
    try {
      xpValue = user?.stats?.totalXp ?? 0;
      levelValue = user?.stats?.currentLevel ?? 1;
    } catch (e) {
      print("Could not access XP: $e");
    }

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            Icons.diamond,
            key: const ValueKey(2),
            color: Colors.lightBlueAccent,
            size: 26,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$xpValue XP",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              "Level $levelValue",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamCompetition() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Team Innovation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Rank #2 of 8",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          // Badge showing team progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Silver",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
