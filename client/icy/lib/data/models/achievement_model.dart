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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      reward: json['reward'],
      timestamp: json['timestamp'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'timestamp': timestamp,
      'icon': icon,
      'color': color,
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
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      xpReward: json['xpReward'],
      conditions: json['conditions'],
    );
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
  final bool repeatable;
  final int? cooldownDays;
  final String? startDate;
  final String? endDate;
  final bool active;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.reward,
    required this.conditions,
    required this.repeatable,
    this.cooldownDays,
    this.startDate,
    this.endDate,
    required this.active,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      reward: ChallengeReward.fromJson(json['reward']),
      conditions: json['conditions'],
      repeatable: json['repeatable'],
      cooldownDays: json['cooldownDays'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      active: json['active'] ?? true,
    );
  }
}

class ChallengeReward {
  final int xp;
  final int coins;
  final String? badge;

  ChallengeReward({required this.xp, required this.coins, this.badge});

  factory ChallengeReward.fromJson(Map<String, dynamic> json) {
    return ChallengeReward(
      xp: json['xp'],
      coins: json['coins'],
      badge: json['badge'],
    );
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

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      reward: json['reward'],
      icon: json['icon'],
      color: json['color'],
      type: json['type'],
    );
  }
}

// Rename this class to avoid ambiguity with UserModel
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

// Use alias for backward compatibility
typedef UserAchievement = AchievementUser;
