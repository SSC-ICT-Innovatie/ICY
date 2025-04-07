import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/achievements/widgets/achievement_card.dart';
import 'package:icy/features/achievements/widgets/challenge_card.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';

class Achievements extends StatelessWidget {
  const Achievements({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeLoaded) {
          // Get data from state
          final recentAchievements = state.recentAchievements;
          final challenges = state.activeChallenges;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent achievements section
                  if (recentAchievements.isNotEmpty) ...[
                    Text(
                      'Recent Achievements',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = recentAchievements[index];
                          return AchievementCard(
                            title: achievement.achievementId.title,
                            description: achievement.achievementId.description,
                            icon: achievement.achievementId.icon,
                            color: achievement.achievementId.color,
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Active challenges section
                  if (challenges.isNotEmpty) ...[
                    Text(
                      'Active Challenges',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: challenges.length.clamp(
                        0,
                        3,
                      ), // Show at most 3
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        return ChallengeCard(
                          title: challenge.title,
                          description: challenge.description,
                          icon: challenge.icon,
                          color: challenge.color,
                          reward:
                              '${challenge.reward.xp} XP, ${challenge.reward.coins} Coins',
                          progress: 0.3, // This would come from user progress
                          onTap: () {},
                        );
                      },
                    ),
                  ],

                  // Empty state
                  if (recentAchievements.isEmpty && challenges.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No achievements or challenges yet'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        if (state is HomeError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}
