import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/data/models/team_model.dart';
import 'package:icy/services/api_service.dart';

class HomeRepository {
  final ApiService _apiService;

  HomeRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<SurveyModel>> getAvailableSurveys() async {
    try {
      final response = await _apiService.get(ApiConstants.surveysEndpoint);
      final List<dynamic> surveysJson = response['data'] ?? [];
      return surveysJson.map((json) => SurveyModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching available surveys: $e');
      throw Exception('Failed to load surveys: $e');
    }
  }

  Future<SurveyModel?> getDailySurvey() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.surveysEndpoint}/daily',
      );
      final List<dynamic> surveysJson = response['data'] ?? [];

      if (surveysJson.isNotEmpty) {
        return SurveyModel.fromJson(surveysJson.first);
      }
      return null;
    } catch (e) {
      print('Error fetching daily survey: $e');
      return null; // Return null instead of throwing for daily surveys
    }
  }

  Future<List<SurveyModel>> getDailySurveys() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.surveysEndpoint}/daily',
      );
      final List<dynamic> surveysJson = response['data'] ?? [];
      return surveysJson.map((json) => SurveyModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching daily surveys: $e');
      return [];
    }
  }

  Future<List<SurveyModel>> getAllSurveys() async {
    return getAvailableSurveys();
  }

  Future<List<AchievementModel>> getRecentAchievements() async {
    try {
      final response = await _apiService.get(
        ApiConstants.recentAchievementsEndpoint,
      );
      final List<dynamic> achievementsJson = response['data'] ?? [];
      return achievementsJson
          .map((json) => AchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching recent achievements: $e');
      return []; // Return empty list on error
    }
  }

  Future<TeamModel?> getUserTeam() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.teamsEndpoint}/my-team',
      );
      final Map<String, dynamic>? teamJson = response['data']?['team'];

      if (teamJson != null) {
        return TeamModel(
          id: teamJson['_id'] ?? '',
          name: teamJson['name'] ?? '',
          description: teamJson['description'] ?? '',
          department: teamJson['department'] ?? '',
          leaderId: teamJson['leader'] ?? '',
          memberIds: List<String>.from(teamJson['members'] ?? []),
          createdAt:
              teamJson['createdAt'] != null
                  ? DateTime.parse(teamJson['createdAt'])
                  : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Error fetching user team: $e');
      return null;
    }
  }

  Future<int?> getTeamRank() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.teamsEndpoint}/leaderboard',
      );
      final Map<String, dynamic>? teamData = response['data']?['team'];

      if (teamData != null && teamData.containsKey('rank')) {
        return teamData['rank'];
      }
      return null;
    } catch (e) {
      print('Error fetching team rank: $e');
      return null;
    }
  }
}
