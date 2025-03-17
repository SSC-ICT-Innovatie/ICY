class Team {
  final String id;
  final String name;
  final String description;
  final String department;
  final TeamMember leader;
  final List<TeamMember> members;
  final String createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.department,
    required this.leader,
    required this.members,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'],
      description: json['description'],
      department: json['department'],
      leader: TeamMember.fromJson(json['leader']),
      members:
          (json['members'] as List)
              .map((member) => TeamMember.fromJson(member))
              .toList(),
      createdAt: json['createdAt'],
    );
  }
}

class TeamMember {
  final String id;
  final String username;
  final String fullName;
  final String avatar;
  final String? email;

  TeamMember({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatar,
    this.email,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'],
      fullName: json['fullName'],
      avatar: json['avatar'],
      email: json['email'],
    );
  }
}

class TeamStats {
  final String league;
  final int rank;
  final int totalTeams;
  final double activeRate;
  final double? goldLeagueProgress;
  final double? silverLeagueProgress;
  final double averageLevel;
  final int totalSurveysCompleted;
  final String lastUpdated;

  TeamStats({
    required this.league,
    required this.rank,
    required this.totalTeams,
    required this.activeRate,
    this.goldLeagueProgress,
    this.silverLeagueProgress,
    required this.averageLevel,
    required this.totalSurveysCompleted,
    required this.lastUpdated,
  });

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
      league: json['league'],
      rank: json['rank'],
      totalTeams: json['totalTeams'],
      activeRate: json['activeRate'].toDouble(),
      goldLeagueProgress: json['goldLeagueProgress']?.toDouble(),
      silverLeagueProgress: json['silverLeagueProgress']?.toDouble(),
      averageLevel: json['averageLevel'].toDouble(),
      totalSurveysCompleted: json['totalSurveysCompleted'],
      lastUpdated: json['lastUpdated'],
    );
  }
}

class League {
  final String id;
  final String name;
  final double requiredParticipation;
  final LeagueRewards rewards;

  League({
    required this.id,
    required this.name,
    required this.requiredParticipation,
    required this.rewards,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'],
      requiredParticipation: json['requiredParticipation'].toDouble(),
      rewards: LeagueRewards.fromJson(json['rewards']),
    );
  }
}

class LeagueRewards {
  final int xp;
  final int coins;

  LeagueRewards({required this.xp, required this.coins});

  factory LeagueRewards.fromJson(Map<String, dynamic> json) {
    return LeagueRewards(xp: json['xp'], coins: json['coins']);
  }
}

class LeaderboardTeam {
  final String teamId;
  final String name;
  final int score;
  final int surveysCompleted;

  LeaderboardTeam({
    required this.teamId,
    required this.name,
    required this.score,
    required this.surveysCompleted,
  });

  factory LeaderboardTeam.fromJson(Map<String, dynamic> json) {
    return LeaderboardTeam(
      teamId: json['teamId'],
      name: json['name'],
      score: json['score'],
      surveysCompleted: json['surveysCompleted'],
    );
  }
}

class LeaderboardPeriod {
  final String startDate;
  final String endDate;
  final List<LeaderboardTeam> teams;

  LeaderboardPeriod({
    required this.startDate,
    required this.endDate,
    required this.teams,
  });

  factory LeaderboardPeriod.fromJson(Map<String, dynamic> json) {
    return LeaderboardPeriod(
      startDate: json['startDate'],
      endDate: json['endDate'],
      teams:
          (json['teams'] as List)
              .map((team) => LeaderboardTeam.fromJson(team))
              .toList(),
    );
  }
}

class Leaderboard {
  final LeaderboardPeriod currentWeek;
  final LeaderboardPeriod previousWeek;

  Leaderboard({required this.currentWeek, required this.previousWeek});

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      currentWeek: LeaderboardPeriod.fromJson(json['currentWeek']),
      previousWeek: LeaderboardPeriod.fromJson(json['previousWeek']),
    );
  }
}

class TeamDetails {
  final Team team;
  final TeamStats? stats;

  TeamDetails({required this.team, this.stats});
}

class TeamLeaderboardEntry {
  final String id;
  final String name;
  final int position;
  final int score;
  final String department;
  final int memberCount;
  final int weeklyProgress;

  TeamLeaderboardEntry({
    required this.id,
    required this.name,
    required this.position,
    required this.score,
    required this.department,
    required this.memberCount,
    required this.weeklyProgress,
  });

  factory TeamLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return TeamLeaderboardEntry(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? 0,
      score: json['score'] ?? 0,
      department: json['department'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      weeklyProgress: json['weeklyProgress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'score': score,
      'department': department,
      'memberCount': memberCount,
      'weeklyProgress': weeklyProgress,
    };
  }
}
