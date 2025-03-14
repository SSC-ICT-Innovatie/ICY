import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/team_model.dart';
import 'package:icy/services/api_service.dart';

class TeamRepository {
  final ApiService _apiService;

  TeamRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all teams
  Future<List<Team>> getTeams() async {
    try {
      final response = await _apiService.get(ApiConstants.teamsEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((teamJson) => Team.fromJson(teamJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }

  // Get current user's team
  Future<TeamDetails?> getUserTeam() async {
    try {
      final response = await _apiService.get(ApiConstants.myTeamEndpoint);

      if (response['success'] == true && response['data'] != null) {
        final teamData = response['data'];

        // If user has no team
        if (teamData == null) {
          return null;
        }

        return TeamDetails(
          team: Team.fromJson(teamData['team']),
          stats:
              teamData['stats'] != null
                  ? TeamStats.fromJson(teamData['stats'])
                  : null,
        );
      }

      return null;
    } catch (e) {
      print('Error fetching user team: $e');
      return null;
    }
  }

  // Get team leaderboard
  Future<Leaderboard?> getLeaderboard() async {
    try {
      final response = await _apiService.get(ApiConstants.leaderboardEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return Leaderboard.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return null;
    }
  }

  // Get leagues
  Future<List<League>> getLeagues() async {
    try {
      final response = await _apiService.get(ApiConstants.leaguesEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((leagueJson) => League.fromJson(leagueJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching leagues: $e');
      return [];
    }
  }
}
