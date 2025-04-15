import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/data/models/team_model.dart';
import 'package:icy/data/repositories/achievement_repository.dart';
import 'package:icy/features/home/repositories/home_repository.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final AchievementRepository _achievementRepository;

  HomeBloc(SettingsBloc read, 
    {
    required HomeRepository homeRepository,
    required AchievementRepository achievementRepository,
  }) : _homeRepository = homeRepository,
       _achievementRepository = achievementRepository,
       super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      // Load data in parallel for efficiency
      final dailySurveyFuture = _homeRepository.getDailySurvey();
      final availableSurveysFuture = _homeRepository.getAvailableSurveys();
      final recentAchievementsFuture = _homeRepository.getRecentAchievements();
      final activeChallengesFuture =
          _achievementRepository.getActiveChallenges();
      final userTeamFuture = _homeRepository.getUserTeam();

      final dailySurvey = await dailySurveyFuture;
      final availableSurveys = await availableSurveysFuture;
      final recentAchievements = await recentAchievementsFuture;
      final activeChallenges = await activeChallengesFuture;
      final userTeam = await userTeamFuture;

      // Get team rank if there's a team
      int? teamRank;
      if (userTeam != null) {
        teamRank = await _homeRepository.getTeamRank();
      }

      emit(
        HomeLoaded(
          availableSurveys: availableSurveys,
          dailySurvey: dailySurvey,
          recentAchievements: recentAchievements,
          activeChallenges: activeChallenges,
          userTeam: userTeam,
          teamRank: teamRank,
        ),
      );
    } catch (e) {
      debugPrint('Error loading home data: $e');
      emit(HomeError('Failed to load data: $e'));
    }
  }
}
