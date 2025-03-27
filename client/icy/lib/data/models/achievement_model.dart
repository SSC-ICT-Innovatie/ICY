class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String reward;
  final String timestamp;
  final String icon;
  final String color;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'star',
      color: json['color'] ?? '#4CAF50',
      reward: json['reward'] ?? '0 XP',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'reward': reward,
      'timestamp': timestamp,
    };
  }
}

class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final int xpReward;
  final Map<String, dynamic> conditions;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.conditions,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'star',
      color: json['color'] ?? '#4CAF50',
      xpReward: json['xpReward'] ?? 0,
      conditions: json['conditions'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'xpReward': xpReward,
      'conditions': conditions,
    };
  }
}

class UserBadge {
  final String id;
  final Badge badgeId;
  final String dateEarned;
  final int xpAwarded;

  UserBadge({
    required this.id,
    required this.badgeId,
    required this.dateEarned,
    required this.xpAwarded,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['_id'] ?? json['id'],
      badgeId: Badge.fromJson(json['badgeId']),
      dateEarned: json['dateEarned'],
      xpAwarded: json['xpAwarded'],
    );
  }
}

class BadgeProgress {
  final String id;
  final Badge badgeId;
  final double progress;
  final int? current;

  BadgeProgress({
    required this.id,
    required this.badgeId,
    required this.progress,
    this.current,
  });

  factory BadgeProgress.fromJson(Map<String, dynamic> json) {
    return BadgeProgress(
      id: json['_id'] ?? json['id'],
      badgeId: Badge.fromJson(json['badgeId']),
      progress: json['progress'].toDouble(),
      current: json['current'],
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final ChallengeReward reward;
  final Map<String, dynamic> conditions;
  final bool active;
  final bool repeatable;
  final String? expiresAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.reward,
    required this.conditions,
    required this.active,
    required this.repeatable,
    this.expiresAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'trophy',
      color: json['color'] ?? '#4CAF50',
      reward: ChallengeReward.fromJson(json['reward'] ?? {}),
      conditions: json['conditions'] ?? {},
      active: json['active'] ?? true,
      repeatable: json['repeatable'] ?? false,
      expiresAt: json['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'reward': reward.toJson(),
      'conditions': conditions,
      'active': active,
      'repeatable': repeatable,
      if (expiresAt != null) 'expiresAt': expiresAt,
    };
  }
}

class UserChallenge {
  final String id;
  final String userId;
  final Challenge challenge;
  final double progress;
  final bool completed;
  final String? completedAt;

  UserChallenge({
    required this.id,
    required this.userId,
    required this.challenge,
    required this.progress,
    required this.completed,
    this.completedAt,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      challenge: Challenge.fromJson(json['challenge'] ?? {}),
      progress: (json['progress'] ?? 0.0).toDouble(),
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'challenge': challenge.toJson(),
      'progress': progress,
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt,
    };
  }
}

class ChallengeReward {
  final int xp;
  final int coins;

  ChallengeReward({required this.xp, required this.coins});

  factory ChallengeReward.fromJson(Map<String, dynamic> json) {
    return ChallengeReward(xp: json['xp'] ?? 0, coins: json['coins'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'xp': xp, 'coins': coins};
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String reward;
  final String icon;
  final String color;
  final String type;
  final String timestamp;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.icon,
    required this.color,
    required this.type,
    required this.timestamp,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'badge',
      icon: json['icon'] ?? 'star',
      color: json['color'] ?? '#4CAF50',
      reward: json['reward'] ?? '0 XP',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'icon': icon,
      'color': color,
      'reward': reward,
      'timestamp': timestamp,
    };
  }
}

class AchievementUser {
  final String id;
  final String userId;
  final Achievement achievementId;
  final String timestamp;

  AchievementUser({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.timestamp,
  });

  factory AchievementUser.fromJson(Map<String, dynamic> json) {
    return AchievementUser(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      achievementId: Achievement.fromJson(json['achievementId']),
      timestamp: json['timestamp'],
    );
  }
}

class UserAchievement {
  final String id;
  final String userId;
  final Achievement achievementId;
  final String earnedAt;
  final int xpAwarded;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
    required this.xpAwarded,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      achievementId: Achievement.fromJson(json['achievementId'] ?? {}),
      earnedAt: json['earnedAt'] ?? DateTime.now().toIso8601String(),
      xpAwarded: json['xpAwarded'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'achievementId': achievementId.toJson(),
      'earnedAt': earnedAt,
      'xpAwarded': xpAwarded,
    };
  }
}

class UserBadges {
  final List<EarnedBadge> earned;
  final List<InProgressBadge> inProgress;

  UserBadges({required this.earned, required this.inProgress});

  factory UserBadges.fromJson(Map<String, dynamic> json) {
    final earnedList = (json['earned'] ?? []) as List;
    final inProgressList = (json['inProgress'] ?? []) as List;

    return UserBadges(
      earned: earnedList.map((badge) => EarnedBadge.fromJson(badge)).toList(),
      inProgress:
          inProgressList
              .map((badge) => InProgressBadge.fromJson(badge))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earned': earned.map((badge) => badge.toJson()).toList(),
      'inProgress': inProgress.map((badge) => badge.toJson()).toList(),
    };
  }
}

class EarnedBadge {
  final Map<String, dynamic> badgeId;
  final String dateEarned;
  final int xpAwarded;

  EarnedBadge({
    required this.badgeId,
    required this.dateEarned,
    required this.xpAwarded,
  });

  factory EarnedBadge.fromJson(Map<String, dynamic> json) {
    return EarnedBadge(
      badgeId: json['badgeId'] ?? {},
      dateEarned: json['dateEarned'] ?? DateTime.now().toIso8601String(),
      xpAwarded: json['xpAwarded'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'dateEarned': dateEarned,
      'xpAwarded': xpAwarded,
    };
  }
}

class InProgressBadge {
  final Map<String, dynamic> badgeId;
  final double progress;

  InProgressBadge({required this.badgeId, required this.progress});

  factory InProgressBadge.fromJson(Map<String, dynamic> json) {
    return InProgressBadge(
      badgeId: json['badgeId'] ?? {},
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'badgeId': badgeId, 'progress': progress};
  }
}
