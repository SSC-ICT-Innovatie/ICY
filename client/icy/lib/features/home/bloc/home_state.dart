part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SurveyModel> dailySurveys;
  final List<ChallengeModel> activeChallenges;
  final List<AchievementModel> recentAchievements;

  const HomeLoaded({
    required this.dailySurveys,
    required this.activeChallenges,
    required this.recentAchievements,
  });

  @override
  List<Object?> get props => [
    dailySurveys,
    activeChallenges,
    recentAchievements,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
