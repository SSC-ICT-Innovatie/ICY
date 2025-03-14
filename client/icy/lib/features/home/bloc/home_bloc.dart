import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/data/models/achievement_model.dart' hide UserAchievement;
import 'package:icy/data/models/achievement_model.dart' as achievement_model;
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/home/repositories/home_repository.dart';
import 'package:icy/data/repositories/achievement_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final AchievementRepository _achievementRepository;

  HomeBloc({
    required HomeRepository homeRepository,
    required AchievementRepository achievementRepository,
  }) : _homeRepository = homeRepository,
       _achievementRepository = achievementRepository,
       super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<LoadHomeData>(_onLoadHome); // Map the old event to the same handler
  }

  Future<void> _onLoadHome(HomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final dailySurveys = await _homeRepository.getDailySurveys();
      final allSurveys = await _homeRepository.getAllSurveys();

      final activeChallenges =
          await _achievementRepository.getActiveChallenges();
      final recentAchievements =
          await _achievementRepository.getRecentAchievements();

      emit(
        HomeLoaded(
          dailySurveys: dailySurveys,
          allSurveys: allSurveys,
          activeChallenges: activeChallenges,
          recentAchievements: recentAchievements,
        ),
      );
    } catch (error) {
      emit(HomeError(message: 'Failed to load home data: $error'));
    }
  }
}
