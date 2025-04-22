import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/data/models/team_model.dart';
import 'package:icy/services/api_service.dart';

class HomeRepository {
  final ApiService _apiService;
  
  // Add caching variables
  List<SurveyModel>? _cachedSurveys;
  SurveyModel? _cachedDailySurvey;
  List<UserAchievement>? _cachedAchievements;
  TeamModel? _cachedTeam;
  int? _cachedTeamRank;
  DateTime _lastRefreshTime = DateTime.now().subtract(const Duration(days: 1));

  HomeRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<SurveyModel>> getAvailableSurveys({bool forceRefresh = false}) async {
    // Return cached data if it exists and we're not forcing a refresh
    // and the data is less than 2 minutes old
    if (!forceRefresh && 
        _cachedSurveys != null && 
        DateTime.now().difference(_lastRefreshTime) < const Duration(minutes: 2)) {
      return _cachedSurveys!;
    }

    try {
      final response = await _apiService.get(ApiConstants.surveysEndpoint);
      final List<dynamic> surveysJson = response['data'] ?? [];
      _cachedSurveys = surveysJson.map((json) => SurveyModel.fromJson(json)).toList();
      _lastRefreshTime = DateTime.now();
      return _cachedSurveys!;
    } catch (e) {
      print('Error fetching available surveys: $e');
      // Return cached data if available even on error
      if (_cachedSurveys != null) {
        return _cachedSurveys!;
      }
      throw Exception('Failed to load surveys: $e');
    }
  }

  Future<SurveyModel?> getDailySurvey({bool forceRefresh = false}) async {
    // Return cached daily survey if it exists and we're not forcing a refresh
    if (!forceRefresh && 
        _cachedDailySurvey != null && 
        DateTime.now().difference(_lastRefreshTime) < const Duration(minutes: 2)) {
      return _cachedDailySurvey;
    }
    
    try {
      final response = await _apiService.get(
        '${ApiConstants.surveysEndpoint}/daily',
      );
      final List<dynamic> surveysJson = response['data'] ?? [];

      if (surveysJson.isNotEmpty) {
        _cachedDailySurvey = SurveyModel.fromJson(surveysJson.first);
        return _cachedDailySurvey;
      }
      _cachedDailySurvey = null;
      return null;
    } catch (e) {
      print('Error fetching daily survey: $e');
      // Return cached data if available
      return _cachedDailySurvey;
    }
  }

  Future<List<UserAchievement>> getRecentAchievements({bool forceRefresh = false}) async {
    // Return cached achievements if they exist and we're not forcing a refresh
    if (!forceRefresh && 
        _cachedAchievements != null && 
        DateTime.now().difference(_lastRefreshTime) < const Duration(minutes: 2)) {
      return _cachedAchievements!;
    }
    
    try {
      final response = await _apiService.get(
        ApiConstants.recentAchievementsEndpoint,
      );
      final List<dynamic> achievementsJson = response['data'] ?? [];
      _cachedAchievements = achievementsJson
          .map((json) => UserAchievement.fromJson(json))
          .toList();
      return _cachedAchievements!;
    } catch (e) {
      print('Error fetching recent achievements: $e');
      // Return cached data if available
      if (_cachedAchievements != null) {
        return _cachedAchievements!;
      }
      return []; // Return empty list on error
    }
  }

  Future<TeamModel?> getUserTeam({bool forceRefresh = false}) async {
    // Return cached team if it exists and we're not forcing a refresh
    if (!forceRefresh && 
        _cachedTeam != null && 
        DateTime.now().difference(_lastRefreshTime) < const Duration(minutes: 2)) {
      return _cachedTeam;
    }
    
    try {
      final response = await _apiService.get(
        '${ApiConstants.teamsEndpoint}/my-team',
      );
      final Map<String, dynamic>? teamJson = response['data']?['team'];

      if (teamJson != null) {
        _cachedTeam = TeamModel(
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
        return _cachedTeam;
      }
      _cachedTeam = null;
      return null;
    } catch (e) {
      print('Error fetching user team: $e');
      // Return cached data if available
      return _cachedTeam;
    }
  }

  Future<int?> getTeamRank({bool forceRefresh = false}) async {
    // Return cached team rank if it exists and we're not forcing a refresh
    if (!forceRefresh && 
        _cachedTeamRank != null && 
        DateTime.now().difference(_lastRefreshTime) < const Duration(minutes: 2)) {
      return _cachedTeamRank;
    }
    
    try {
      final response = await _apiService.get(
        '${ApiConstants.teamsEndpoint}/leaderboard',
      );
      final Map<String, dynamic>? teamData = response['data']?['team'];

      if (teamData != null && teamData.containsKey('rank')) {
        _cachedTeamRank = teamData['rank'];
        return _cachedTeamRank;
      }
      _cachedTeamRank = null;
      return null;
    } catch (e) {
      print('Error fetching team rank: $e');
      // Return cached data if available
      return _cachedTeamRank;
    }
  }
  
  // Clear cache when needed (e.g., after completing a survey)
  void clearCache() {
    _cachedSurveys = null;
    _cachedDailySurvey = null;
    _cachedAchievements = null;
    _cachedTeam = null;
    _cachedTeamRank = null;
    _lastRefreshTime = DateTime.now().subtract(const Duration(days: 1));
  }
}
