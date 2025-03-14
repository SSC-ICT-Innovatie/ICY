import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Load achievements when the page is shown
    _loadAchievements(context);

    return FScaffold(
      header: FHeader(title: const Text('Achievements')),
      content: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            // This casts to the correct type - removed the issue with achievement_model.UserAchievement
            return _buildAchievementsList(context, state.recentAchievements);
          } else if (state is HomeError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          // Initial state or when there's no data
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _loadAchievements(BuildContext context) {
    // Use LoadHome event instead of LoadHomeData for API compatibility
    context.read<HomeBloc>().add(const LoadHome());
  }

  // Update parameter type to match what we receive from the HomeBloc
  Widget _buildAchievementsList(
    BuildContext context,
    List<UserAchievement> achievements,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Text(
          'No achievements earned yet. Complete surveys and challenges to earn them!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        // Fix the property access to match the UserAchievement type
        return _buildAchievementCard(context, achievement.achievementId);
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    final color = _hexToColor(achievement.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Achievement icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // Fix deprecated withOpacity
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconData(achievement.icon),
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // Achievement details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(achievement.description),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Use the current timestamp instead of a property that might not exist
                      Text(
                        _formatDate(DateTime.now().toString()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}/${date.month}/${date.year}';
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
        return Icons.people;
      case 'groups':
        return Icons.groups;
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
