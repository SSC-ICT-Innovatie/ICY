part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SurveyModel> dailySurveys;
  final List<SurveyModel> allSurveys;
  final List<Challenge> activeChallenges;
  final List<achievement_model.UserAchievement> recentAchievements;
  final bool hasNewNotifications;

  const HomeLoaded({
    required this.dailySurveys,
    required this.allSurveys,
    required this.activeChallenges,
    required this.recentAchievements,
    this.hasNewNotifications = false,
  });

  @override
  List<Object> get props => [
    dailySurveys,
    allSurveys,
    activeChallenges,
    recentAchievements,
    hasNewNotifications,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
