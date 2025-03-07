import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/data/models/challenge_model.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/home/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc({required HomeRepository homeRepository})
    : _homeRepository = homeRepository,
      super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final dailySurveys = await _homeRepository.getDailySurveys();
        final activeChallenges = await _homeRepository.getActiveChallenges(
          event.userId,
        );
        final recentAchievements = await _homeRepository.getRecentAchievements(
          event.userId,
        );

        emit(
          HomeLoaded(
            dailySurveys: dailySurveys,
            activeChallenges: activeChallenges,
            recentAchievements: recentAchievements,
          ),
        );
      } catch (e) {
        emit(HomeError(message: 'Failed to load home data: $e'));
      }
    });
  }
}
