// ignore_for_file: unused_element

import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/services/api_service.dart';

class AchievementRepository {
  final ApiService _apiService;

  AchievementRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all badges
  Future<List<Badge>> getAllBadges() async {
    try {
      final response = await _apiService.get(ApiConstants.badgesEndpoint);
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((badge) => Badge.fromJson(badge))
            .toList();
      }
      return _getDefaultBadges();
    } catch (e) {
      return _getDefaultBadges();
    }
  }

  // Get user badges
  Future<UserBadges> getUserBadges() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.achievementsEndpoint}/badges/my',
      );
      return UserBadges.fromJson(response['data'] ?? {});
    } catch (e) {
      print('Error fetching user badges: $e');
      // Return empty badges on error
      return UserBadges(earned: [], inProgress: []);
    }
  }

  // Get active challenges
  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.achievementsEndpoint}/challenges',
      );
      final List<dynamic> challengesJson = response['data'] ?? [];
      return challengesJson.map((json) => Challenge.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching active challenges: $e');
      // Return empty list on error
      return [];
    }
  }

  // Get user challenges
  Future<List<UserChallenge>> getUserChallenges() async {
    try {
      final response = await _apiService.get(
        ApiConstants.userChallengesEndpoint,
      );
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((challenge) => UserChallenge.fromJson(challenge))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get recent achievements
  Future<List<UserAchievement>> getRecentAchievements() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.achievementsEndpoint}/recent',
      );
      final List<dynamic> achievementsJson = response['data'] ?? [];
      return achievementsJson
          .map((json) => UserAchievement.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching recent achievements: $e');
      return [];
    }
  }

  // Default badges for offline mode or initial testing
  List<Badge> _getDefaultBadges() {
    return [
      Badge(
        id: '1',
        title: 'Survey Pioneer',
        description: 'Complete your first survey',
        icon: 'star',
        color: '#4CAF50',
        xpReward: 100,
        conditions: {'type': 'surveys_completed', 'count': 1},
      ),
      Badge(
        id: '2',
        title: 'Streak Master',
        description: 'Maintain a 7-day streak',
        icon: 'local_fire_department',
        color: '#FF9800',
        xpReward: 200,
        conditions: {'type': 'streak', 'count': 7},
      ),
      Badge(
        id: '3',
        title: 'Team Player',
        description: 'Join a team and complete team challenges',
        icon: 'groups',
        color: '#2196F3',
        xpReward: 150,
        conditions: {'type': 'team_challenges', 'count': 1},
      ),
    ];
  }

  // Default challenges for offline mode or initial testing
  List<Challenge> _getDefaultChallenges() {
    return [
      Challenge(
        id: '1',
        title: 'Daily Streak',
        description: 'Complete surveys for 5 consecutive days',
        icon: 'local_fire_department',
        color: '#FF9800',
        reward: ChallengeReward(xp: 100, coins: 50),
        conditions: {'type': 'daily_streak', 'count': 5},
        active: true,
        repeatable: false,
        expiresAt: DateTime.now().add(Duration(days: 7)).toIso8601String(),
      ),
      Challenge(
        id: '2',
        title: 'Feedback Champion',
        description: 'Submit 3 detailed feedback surveys',
        icon: 'rate_review',
        color: '#4CAF50',
        reward: ChallengeReward(xp: 150, coins: 75),
        conditions: {'type': 'feedback_surveys', 'count': 3},
        active: true,
        repeatable: false,
        expiresAt: DateTime.now().add(Duration(days: 14)).toIso8601String(),
      ),
      Challenge(
        id: '3',
        title: 'Quick Responder',
        description: 'Respond to 3 surveys within 1 hour of notification',
        icon: 'bolt',
        color: '#2196F3',
        reward: ChallengeReward(xp: 200, coins: 100),
        conditions: {'type': 'quick_response', 'count': 3},
        active: true,
        repeatable: false,
        expiresAt: DateTime.now().add(Duration(days: 10)).toIso8601String(),
      ),
    ];
  }

  // Default recent achievements for offline mode or initial testing
  List<UserAchievement> _getDefaultRecentAchievements() {
    final achievements = [
      Achievement(
        id: '1',
        title: 'First Survey',
        description: 'Completed your first survey',
        type: 'badge',
        icon: 'check_circle',
        color: '#4CAF50',
        reward: '100 XP',
        timestamp: DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      ),
      Achievement(
        id: '2',
        title: '3-Day Streak',
        description: 'Maintained activity for 3 consecutive days',
        type: 'challenge',
        icon: 'local_fire_department',
        color: '#FF9800',
        reward: '150 XP, 50 Coins',
        timestamp: DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      ),
    ];

    return achievements
        .map(
          (a) => UserAchievement(
            id: '${a.id}_earned',
            userId: 'current_user',
            achievementId: a,
            earnedAt:
                DateTime.now()
                    .subtract(Duration(days: int.parse(a.id)))
                    .toIso8601String(),
            xpAwarded: int.parse(a.id) * 100,
          ),
        )
        .toList();
  }
}

class UserBadges {
  final List<UserBadge> earned;
  final List<BadgeProgress> inProgress;

  UserBadges({required this.earned, required this.inProgress});

  factory UserBadges.fromJson(Map<String, dynamic> json) {
    return UserBadges(
      earned:
          (json['earned'] as List)
              .map((badge) => UserBadge.fromJson(badge))
              .toList(),
      inProgress:
          (json['inProgress'] as List)
              .map((badge) => BadgeProgress.fromJson(badge))
              .toList(),
    );
  }
}
