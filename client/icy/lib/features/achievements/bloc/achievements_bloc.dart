import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/data/models/achievement_model.dart';
import 'package:icy/data/repositories/achievement_repository.dart';

part 'achievements_event.dart';
part 'achievements_state.dart';

class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  final AchievementRepository achievementRepository;

  AchievementsBloc({required this.achievementRepository})
    : super(AchievementsInitial()) {
    on<LoadAchievementsEvent>(_onLoadAchievements);
    on<LoadBadgesEvent>(_onLoadBadges);
    on<LoadChallengesEvent>(_onLoadChallenges);
  }

  Future<void> _onLoadAchievements(
    LoadAchievementsEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(AchievementsLoading());
    try {
      final achievements = await achievementRepository.getRecentAchievements();
      emit(
        AchievementsLoaded(
          achievements:
              achievements
                  .map((a) => AchievementModel.fromJson(a.toJson()))
                  .toList(),
        ),
      );
    } catch (e) {
      emit(AchievementsError(message: e.toString()));
    }
  }

  Future<void> _onLoadBadges(
    LoadBadgesEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(BadgesLoading());
    try {
      final badges = await achievementRepository.getUserBadges();

      final badgesMap = {
        'earned':
            badges.earned
                .map(
                  (badge) => {
                    'badgeId': badge.badgeId,
                    'dateEarned': badge.dateEarned,
                    'xpAwarded': badge.xpAwarded,
                  },
                )
                .toList(),
        'inProgress':
            badges.inProgress
                .map(
                  (badge) => {
                    'badgeId': badge.badgeId,
                    'progress': badge.progress,
                  },
                )
                .toList(),
      };

      emit(BadgesLoaded(badges: badgesMap));
    } catch (e) {
      emit(AchievementsError(message: e.toString()));
    }
  }

  Future<void> _onLoadChallenges(
    LoadChallengesEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(ChallengesLoading());
    try {
      final challenges = await achievementRepository.getUserChallenges();

      final challengesMaps =
          challenges
              .map(
                (challenge) => <String, dynamic>{
                  'id': challenge.id,
                  'title': challenge.challenge.title,
                  'description': challenge.challenge.description,
                  'progress': challenge.progress,
                  'reward': challenge.challenge.reward,
                  'dueDate': challenge.challenge.expiresAt,
                },
              )
              .toList();

      emit(ChallengesLoaded(challenges: challengesMaps));
    } catch (e) {
      emit(AchievementsError(message: e.toString()));
    }
  }
}
