// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui/theme.dart';
import 'package:icy/core/utils/widget_utils.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/models/team_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;
  final Color primaryColor;

  const HomeHeader({super.key, required this.user, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Get latest user data from AuthBloc to ensure XP is current
        final authState = context.watch<AuthBloc>().state;
        final currentUser = authState is AuthSuccess ? authState.user : user;
        
        // Extract team data if available
        TeamModel? userTeam;
        int? teamRank;

        if (state is HomeLoaded) {
          userTeam = state.userTeam;
          teamRank = state.teamRank;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.theme.colorScheme.primary,
                context.theme.colorScheme.barrier.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Use the avatar helper to avoid placeholder issues
                      ClipOval(
                        child: WidgetUtils.avatar(
                          currentUser.avatar,
                          currentUser.fullName,
                          size: 48,
                          backgroundColor: Colors.blue.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${currentUser.fullName.split(' ').first}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              currentUser.department,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildLevelBadge(context, currentUser.level?.current ?? 1),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // XP progress and team info
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildXpProgress(
                          context,
                          current: currentUser.level?.xp.current ?? 0,
                          total: currentUser.level?.xp.nextLevel ?? 100,
                          streak: currentUser.stats?.streak.current,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildTeamInfo(context, userTeam, teamRank),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelBadge(BuildContext context, int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Level $level',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade900,
        ),
      ),
    );
  }

  Widget _buildXpProgress(
    BuildContext context, {
    required int current,
    required int total,
    int? streak,
  }) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$current / $total XP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            // Show streak if available
            if (streak != null && streak > 0)
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak day streak',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white30,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade300),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamInfo(BuildContext context, TeamModel? team, int? rank) {
    // Just remove the team info display completely if there's no team
    if (team == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            rank != null ? 'Rank #$rank' : 'Team member',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
