part of 'achievements_bloc.dart';

abstract class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object> get props => [];
}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoading extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final List<AchievementModel> achievements;

  const AchievementsLoaded({required this.achievements});

  @override
  List<Object> get props => [achievements];
}

class BadgesLoading extends AchievementsState {}

class BadgesLoaded extends AchievementsState {
  final Map<String, dynamic> badges;

  const BadgesLoaded({required this.badges});

  @override
  List<Object> get props => [badges];
}

class ChallengesLoading extends AchievementsState {}

class ChallengesLoaded extends AchievementsState {
  final List<Map<String, dynamic>> challenges;

  const ChallengesLoaded({required this.challenges});

  @override
  List<Object> get props => [challenges];
}

class AchievementsError extends AchievementsState {
  final String message;

  const AchievementsError({required this.message});

  @override
  List<Object> get props => [message];
}
