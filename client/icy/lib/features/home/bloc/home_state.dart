part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SurveyModel> availableSurveys;
  final SurveyModel? dailySurvey;
  final List<AchievementModel> recentAchievements;
  final TeamModel? userTeam;
  final int? teamRank;

  const HomeLoaded({
    required this.availableSurveys,
    this.dailySurvey,
    required this.recentAchievements,
    this.userTeam,
    this.teamRank,
  });

  @override
  List<Object?> get props => [
    availableSurveys,
    dailySurvey,
    recentAchievements,
    userTeam,
    teamRank,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
