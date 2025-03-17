import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/team_model.dart';
import 'package:icy/services/api_service.dart';

class TeamRepository {
  final ApiService _apiService;

  TeamRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get all teams
  Future<List<Team>> getAllTeams() async {
    try {
      final response = await _apiService.get(ApiConstants.teamsEndpoint);
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Team.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }

  /// Get current user's team
  Future<Team?> getMyTeam() async {
    try {
      final response = await _apiService.get(ApiConstants.myTeamEndpoint);
      if (response['success'] == true && response['data'] != null) {
        return Team.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching my team: $e');
      return null;
    }
  }

  /// Get team members
  Future<List<TeamMember>> getTeamMembers(String teamId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.teamsEndpoint}/$teamId/members',
      );
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TeamMember.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching team members: $e');
      return [];
    }
  }

  /// Get team leaderboard
  Future<List<TeamLeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _apiService.get(ApiConstants.leaderboardEndpoint);
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TeamLeaderboardEntry.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Get team/department statistics
  Future<TeamStats?> getTeamStats(String teamId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.teamsEndpoint}/$teamId/stats',
      );
      if (response['success'] == true && response['data'] != null) {
        return TeamStats.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching team stats: $e');
      return null;
    }
  }

  /// Get league information
  Future<List<League>> getLeagues() async {
    try {
      final response = await _apiService.get(ApiConstants.leaguesEndpoint);
      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => League.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching leagues: $e');
      return [];
    }
  }
}
