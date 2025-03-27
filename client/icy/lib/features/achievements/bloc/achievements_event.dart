part of 'achievements_bloc.dart';

abstract class AchievementsEvent extends Equatable {
  const AchievementsEvent();

  @override
  List<Object> get props => [];
}

class LoadAchievementsEvent extends AchievementsEvent {}

class LoadBadgesEvent extends AchievementsEvent {}

class LoadChallengesEvent extends AchievementsEvent {}
