class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String avatar;
  final String department;
  final String role;
  final LevelModel? level;
  final UserStats? stats;
  final UserPreferences? preferences;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.avatar,
    required this.department,
    required this.role,
    this.level,
    this.stats,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? 'https://via.placeholder.com/150',
      department: json['department'] ?? 'General',
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
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'avatar': avatar,
      'department': department,
      'role': role,
      if (level != null) 'level': level!.toJson(),
      if (stats != null) 'stats': stats!.toJson(),
      if (preferences != null) 'preferences': preferences!.toJson(),
    };
  }
}

class LevelModel {
  final int current;
  final String title;
  final LevelXP xp;

  LevelModel({required this.current, required this.title, required this.xp});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      current: json['current'] ?? 1,
      title: json['title'] ?? 'Beginner',
      xp: LevelXP.fromJson(json['xp'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'title': title, 'xp': xp.toJson()};
  }
}

class LevelXP {
  final int current;
  final int nextLevel;

  LevelXP({required this.current, required this.nextLevel});

  factory LevelXP.fromJson(Map<String, dynamic> json) {
    return LevelXP(
      current: json['current'] ?? 0,
      nextLevel: json['nextLevel'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'nextLevel': nextLevel};
  }
}

class UserStats {
  final int surveysCompleted;
  final int totalXp;
  final int totalCoins;
  final int currentLevel;
  final UserStreak streak;
  final double participationRate;
  final double averageResponseTime;

  UserStats({
    required this.surveysCompleted,
    required this.totalXp,
    required this.totalCoins,
    required this.currentLevel,
    required this.streak,
    required this.participationRate,
    required this.averageResponseTime,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      surveysCompleted: json['surveysCompleted'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
      totalCoins: json['totalCoins'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      streak: UserStreak.fromJson(json['streak'] ?? {}),
      participationRate: (json['participationRate'] ?? 0.0).toDouble(),
      averageResponseTime: (json['averageResponseTime'] ?? 5.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveysCompleted': surveysCompleted,
      'totalXp': totalXp,
      'totalCoins': totalCoins,
      'currentLevel': currentLevel,
      'streak': streak.toJson(),
      'participationRate': participationRate,
      'averageResponseTime': averageResponseTime,
    };
  }
}

class UserStreak {
  final int current;
  final int longest;

  UserStreak({required this.current, required this.longest});

  // Add best getter to fix the error
  int get best => longest; // Alias for longest to fix the stats_card reference

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      current: json['current'] ?? 0,
      longest: json['longest'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'longest': longest};
  }
}

class UserPreferences {
  final String language;
  final String theme;
  final bool notifications;
  final String dailyReminderTime;

  UserPreferences({
    required this.language,
    required this.theme,
    required this.notifications,
    required this.dailyReminderTime,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'light',
      notifications: json['notifications'] ?? true,
      dailyReminderTime: json['dailyReminderTime'] ?? '09:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications': notifications,
      'dailyReminderTime': dailyReminderTime,
    };
  }
}

class UserBadges {
  final List<EarnedBadge> earned;
  final List<InProgressBadge> inProgress;

  UserBadges({required this.earned, required this.inProgress});

  factory UserBadges.fromJson(Map<String, dynamic> json) {
    return UserBadges(
      earned:
          ((json['earned'] ?? []) as List)
              .map((badge) => EarnedBadge.fromJson(badge))
              .toList(),
      inProgress:
          ((json['inProgress'] ?? []) as List)
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
      dateEarned: json['dateEarned'] ?? '',
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

class UserProfileModel {
  final UserPreferences preferences;
  final UserBadges badges;
  final Map<String, dynamic> challenges;
  final List<Map<String, dynamic>> achievements;
  final Map<String, dynamic> surveys;
  final List<String> friends;
  final List<Map<String, dynamic>> notifications;

  UserProfileModel({
    required this.preferences,
    required this.badges,
    required this.challenges,
    required this.achievements,
    required this.surveys,
    required this.friends,
    required this.notifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'preferences': preferences.toJson(),
      'badges': badges.toJson(),
      'challenges': challenges,
      'achievements': achievements.map((achievement) => achievement).toList(),
      'surveys': surveys,
      'friends': friends,
      'notifications':
          notifications.map((notification) => notification).toList(),
    };
  }
}
