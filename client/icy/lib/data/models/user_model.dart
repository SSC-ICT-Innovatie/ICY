class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String avatar;
  final String department;
  final String role;
  final LevelModel? level;
  final UserStats? stats;
  final UserPreferences? preferences;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.avatar,
    required this.department,
    required this.role,
    this.level,
    this.stats,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      avatar: json['avatar'],
      department: json['department'],
      role: json['role'] ?? 'user',
      level: json['level'] != null ? LevelModel.fromJson(json['level']) : null,
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      preferences:
          json['preferences'] != null
              ? UserPreferences.fromJson(json['preferences'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'department': department,
      'role': role,
    };

    if (level != null) {
      data['level'] = level!.toJson();
    }

    if (stats != null) {
      data['stats'] = stats!.toJson();
    }

    if (preferences != null) {
      data['preferences'] = preferences!.toJson();
    }

    return data;
  }

  // Add a copyWith method for immutability
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? avatar,
    String? department,
    String? role,
    LevelModel? level,
    UserStats? stats,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      department: department ?? this.department,
      role: role ?? this.role,
      level: level ?? this.level,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
    );
  }
}

class LevelModel {
  final int current;
  final String title;
  final XpModel xp;

  LevelModel({required this.current, required this.title, required this.xp});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      current: json['current'],
      title: json['title'],
      xp: XpModel.fromJson(json['xp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'title': title, 'xp': xp.toJson()};
  }
}

class XpModel {
  final int current;
  final int nextLevel;

  XpModel({required this.current, required this.nextLevel});

  factory XpModel.fromJson(Map<String, dynamic> json) {
    return XpModel(current: json['current'], nextLevel: json['nextLevel']);
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'nextLevel': nextLevel};
  }
}

class UserStats {
  final int surveysCompleted;
  final StreakModel streak;
  final int totalXp;
  final double participationRate;
  final double averageResponseTime;
  final int totalCoins;

  UserStats({
    required this.surveysCompleted,
    required this.streak,
    required this.totalXp,
    required this.participationRate,
    required this.averageResponseTime,
    required this.totalCoins,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      surveysCompleted: json['surveysCompleted'],
      streak: StreakModel.fromJson(json['streak']),
      totalXp: json['totalXp'],
      participationRate: json['participationRate'].toDouble(),
      averageResponseTime: json['averageResponseTime'].toDouble(),
      totalCoins: json['totalCoins'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveysCompleted': surveysCompleted,
      'streak': streak.toJson(),
      'totalXp': totalXp,
      'participationRate': participationRate,
      'averageResponseTime': averageResponseTime,
      'totalCoins': totalCoins,
    };
  }
}

class StreakModel {
  final int current;
  final int best;

  StreakModel({required this.current, required this.best});

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(current: json['current'], best: json['best']);
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'best': best};
  }
}

class UserPreferences {
  final bool notifications;
  final String dailyReminderTime;
  final String language;
  final String theme;

  UserPreferences({
    required this.notifications,
    required this.dailyReminderTime,
    required this.language,
    required this.theme,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notifications: json['notifications'],
      dailyReminderTime: json['dailyReminderTime'],
      language: json['language'],
      theme: json['theme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'dailyReminderTime': dailyReminderTime,
      'language': language,
      'theme': theme,
    };
  }
}

class UserProfileModel {
  final String userId;
  final LevelModel level;
  final UserStats stats;
  final UserPreferences preferences;
  final UserBadges badges;
  final UserChallenges challenges;
  final List<UserAchievement> achievements;
  final UserSurveys surveys;
  final List<String> friends;
  final List<UserNotification> notifications;

  UserProfileModel({
    required this.userId,
    required this.level,
    required this.stats,
    required this.preferences,
    required this.badges,
    required this.challenges,
    required this.achievements,
    required this.surveys,
    required this.friends,
    required this.notifications,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'],
      level: LevelModel.fromJson(json['level']),
      stats: UserStats.fromJson(json['stats']),
      preferences: UserPreferences.fromJson(json['preferences']),
      badges: UserBadges.fromJson(json['badges']),
      challenges: UserChallenges.fromJson(json['challenges']),
      achievements:
          (json['achievements'] as List)
              .map((achievement) => UserAchievement.fromJson(achievement))
              .toList(),
      surveys: UserSurveys.fromJson(json['surveys']),
      friends: (json['friends'] as List).map((e) => e.toString()).toList(),
      notifications:
          (json['notifications'] as List)
              .map((notification) => UserNotification.fromJson(notification))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'level': level.toJson(),
      'stats': stats.toJson(),
      'preferences': preferences.toJson(),
      'badges': badges.toJson(),
      'challenges': challenges.toJson(),
      'achievements':
          achievements.map((achievement) => achievement.toJson()).toList(),
      'surveys': surveys.toJson(),
      'friends': friends,
      'notifications':
          notifications.map((notification) => notification.toJson()).toList(),
    };
  }
}

// Add remaining model classes based on your JSON structure
class UserBadges {
  final List<EarnedBadge> earned;
  final List<InProgressBadge> inProgress;

  UserBadges({required this.earned, required this.inProgress});

  factory UserBadges.fromJson(Map<String, dynamic> json) {
    return UserBadges(
      earned:
          (json['earned'] as List)
              .map((badge) => EarnedBadge.fromJson(badge))
              .toList(),
      inProgress:
          (json['inProgress'] as List)
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
  final String id;
  final String dateEarned;
  final int xpAwarded;

  EarnedBadge({
    required this.id,
    required this.dateEarned,
    required this.xpAwarded,
  });

  factory EarnedBadge.fromJson(Map<String, dynamic> json) {
    return EarnedBadge(
      id: json['id'],
      dateEarned: json['dateEarned'],
      xpAwarded: json['xpAwarded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'dateEarned': dateEarned, 'xpAwarded': xpAwarded};
  }
}

class InProgressBadge {
  final String id;
  final double progress;
  final int? current;

  InProgressBadge({required this.id, required this.progress, this.current});

  factory InProgressBadge.fromJson(Map<String, dynamic> json) {
    return InProgressBadge(
      id: json['id'],
      progress: json['progress'].toDouble(),
      current: json['current'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'progress': progress, 'current': current};
  }
}

class UserChallenges {
  final List<String> active;
  final List<String> completed;
  final Map<String, ChallengeProgress> progress;

  UserChallenges({
    required this.active,
    required this.completed,
    required this.progress,
  });

  factory UserChallenges.fromJson(Map<String, dynamic> json) {
    final progressMap = <String, ChallengeProgress>{};
    final Map<String, dynamic> progressJson = json['progress'];

    progressJson.forEach((key, value) {
      progressMap[key] = ChallengeProgress.fromJson(value);
    });

    return UserChallenges(
      active: (json['active'] as List).map((e) => e.toString()).toList(),
      completed: (json['completed'] as List).map((e) => e.toString()).toList(),
      progress: progressMap,
    );
  }

  Map<String, dynamic> toJson() {
    final progressJson = <String, dynamic>{};
    progress.forEach((key, value) {
      progressJson[key] = value.toJson();
    });

    return {'active': active, 'completed': completed, 'progress': progressJson};
  }
}

class ChallengeProgress {
  final double progress;
  final String progressText;
  final String startDate;

  ChallengeProgress({
    required this.progress,
    required this.progressText,
    required this.startDate,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      progress: json['progress'].toDouble(),
      progressText: json['progressText'],
      startDate: json['startDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progress': progress,
      'progressText': progressText,
      'startDate': startDate,
    };
  }
}

class UserAchievement {
  final String id;
  final String timestamp;

  UserAchievement({required this.id, required this.timestamp});

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(id: json['id'], timestamp: json['timestamp']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'timestamp': timestamp};
  }
}

class UserSurveys {
  final List<String> completed;
  final List<String> ongoing;

  UserSurveys({required this.completed, required this.ongoing});

  factory UserSurveys.fromJson(Map<String, dynamic> json) {
    return UserSurveys(
      completed: (json['completed'] as List).map((e) => e.toString()).toList(),
      ongoing: (json['ongoing'] as List).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'completed': completed, 'ongoing': ongoing};
  }
}

class UserNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String timestamp;
  final bool read;
  final String actionUrl;

  UserNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.read,
    required this.actionUrl,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      timestamp: json['timestamp'],
      read: json['read'],
      actionUrl: json['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'read': read,
      'actionUrl': actionUrl,
    };
  }
}
