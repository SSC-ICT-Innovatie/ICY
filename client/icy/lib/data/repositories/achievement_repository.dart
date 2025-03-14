import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/services/api_service.dart';

class AchievementRepository {
  final ApiService _apiService;

  AchievementRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<Badge>> getBadges() async {
    try {
      final response = await _apiService.get(ApiConstants.badgesEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((badge) => Badge.fromJson(badge))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching badges: $e');
      return [];
    }
  }

  Future<UserBadgesData> getUserBadges() async {
    try {
      final response = await _apiService.get(ApiConstants.myBadgesEndpoint);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        return UserBadgesData(
          earned:
              (data['earned'] as List)
                  .map((badge) => UserBadge.fromJson(badge))
                  .toList(),
          inProgress:
              (data['inProgress'] as List)
                  .map((badge) => BadgeProgress.fromJson(badge))
                  .toList(),
        );
      }
      return UserBadgesData(earned: [], inProgress: []);
    } catch (e) {
      print('Error fetching user badges: $e');
      return UserBadgesData(earned: [], inProgress: []);
    }
  }

  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final response = await _apiService.get(ApiConstants.challengesEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((challenge) => Challenge.fromJson(challenge))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching challenges: $e');
      return [];
    }
  }

  Future<List<UserAchievement>> getUserAchievements() async {
    try {
      final response = await _apiService.get(ApiConstants.achievementsEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((achievement) => UserAchievement.fromJson(achievement))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }

  Future<List<UserAchievement>> getRecentAchievements() async {
    try {
      final response = await _apiService.get(
        ApiConstants.recentAchievementsEndpoint,
      );

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((achievement) => UserAchievement.fromJson(achievement))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recent achievements: $e');
      return [];
    }
  }
}

class UserBadgesData {
  final List<UserBadge> earned;
  final List<BadgeProgress> inProgress;

  UserBadgesData({required this.earned, required this.inProgress});
}
