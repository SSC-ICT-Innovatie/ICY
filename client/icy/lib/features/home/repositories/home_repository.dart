import 'package:icy/data/datasources/json_asset_service.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/data/models/challenge_model.dart';
import 'package:icy/data/models/survey_model.dart';

class HomeRepository {
  final JsonAssetService _jsonAssetService;

  HomeRepository({JsonAssetService? jsonAssetService})
    : _jsonAssetService = jsonAssetService ?? JsonAssetService();

  Future<List<SurveyModel>> getDailySurveys() async {
    try {
      final surveysData = await _jsonAssetService.loadJson(
        'lib/data/surveys.json',
      );
      final surveys = List<Map<String, dynamic>>.from(surveysData['surveys']);

      // Filter to get only today's surveys
      final todaySurveys =
          surveys.where((survey) {
            // In a real implementation, check for expired
            return !survey.containsKey('archived') ||
                survey['archived'] == false;
          }).toList();

      return todaySurveys
          .map((survey) => SurveyModel.fromJson(survey))
          .toList();
    } catch (e) {
      print('Error loading daily surveys: $e');
      return [];
    }
  }

  Future<List<ChallengeModel>> getActiveChallenges(String userId) async {
    try {
      // Load challenges data
      final challengesData = await _jsonAssetService.loadJson(
        'lib/data/badges_challenges.json',
      );
      final availableChallenges = List<Map<String, dynamic>>.from(
        challengesData['challenges']['available'],
      );

      // Load user data to get active challenges
      final userData = await _jsonAssetService.loadJson(
        'lib/data/user_data.json',
      );
      final userDataList = userData['user_data'] as List;

      // Find the user's data with proper null safety
      Map<String, dynamic>? userInfo;
      try {
        userInfo =
            userDataList.firstWhere((user) => user['userId'] == userId)
                as Map<String, dynamic>;
      } catch (_) {
        // User not found
        return [];
      }

      // Get IDs of user's active challenges
      final activeIds = List<String>.from(
        userInfo['challenges']['active'] ?? [],
      );
      final userChallengeProgress = Map<String, dynamic>.from(
        userInfo['challenges']['progress'] ?? {},
      );

      // Filter and add user progress data
      final activeChallenges = <ChallengeModel>[];

      for (final id in activeIds) {
        // Find matching challenge with safer approach
        Map<String, dynamic>? challenge;
        try {
          challenge =
              availableChallenges.firstWhere((c) => c['id'] == id);
        } catch (_) {
          // Challenge not found, skip
          continue;
        }

        if (userChallengeProgress.containsKey(id)) {
          final progress = userChallengeProgress[id];

          // Create challenge model with user's progress
          final challengeWithProgress = {
            ...challenge,
            'progress': progress['progress'],
            'progressText': progress['progressText'],
          };

          activeChallenges.add(ChallengeModel.fromJson(challengeWithProgress));
        }
      }

      return activeChallenges;
    } catch (e) {
      print('Error loading active challenges: $e');
      return [];
    }
  }

  Future<List<AchievementModel>> getRecentAchievements(String userId) async {
    try {
      // Load achievements definitions
      final badgesChallenges = await _jsonAssetService.loadJson(
        'lib/data/badges_challenges.json',
      );
      final achievementTemplates = List<Map<String, dynamic>>.from(
        badgesChallenges['achievements'],
      );

      // Load user's achievements
      final userData = await _jsonAssetService.loadJson(
        'lib/data/user_data.json',
      );
      final userDataList = userData['user_data'] as List;

      // Find the user with safer approach
      Map<String, dynamic>? userInfo;
      try {
        userInfo =
            userDataList.firstWhere((user) => user['userId'] == userId)
                as Map<String, dynamic>;
      } catch (_) {
        // User not found
        return [];
      }

      // Get user's achievements - safely using empty list if not found
      final userAchievements = List<Map<String, dynamic>>.from(
        userInfo['achievements'] ?? [],
      );

      // Sort by timestamp (newest first)
      userAchievements.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp'] as String);
        final dateB = DateTime.parse(b['timestamp'] as String);
        return dateB.compareTo(dateA);
      });

      // Get the 5 most recent achievements
      final recentAchievements = <AchievementModel>[];

      for (final userAchievement in userAchievements.take(5)) {
        // Find the achievement template with safer approach
        Map<String, dynamic>? template;
        try {
          template =
              achievementTemplates.firstWhere(
                    (t) => t['id'] == userAchievement['id'],
                  );
        } catch (_) {
          // Achievement template not found, skip
          continue;
        }

        // Combine the achievement data
        final achievement = AchievementModel(
          id: userAchievement['id'],
          title: template['title'],
          description: template['description'],
          reward: template['reward'],
          timestamp: userAchievement['timestamp'],
          icon: template['icon'],
          color: template['color'],
        );

        recentAchievements.add(achievement);
      }

      return recentAchievements;
    } catch (e) {
      print('Error loading recent achievements: $e');
      return [];
    }
  }
}
