/// Models for admin dashboard statistics
class AdminStats {
  final int totalUsers;
  final int totalSurveys;
  final int totalDepartments;
  final int activeUsers;
  final int participationRate;

  AdminStats({
    required this.totalUsers,
    required this.totalSurveys,
    required this.totalDepartments,
    required this.activeUsers,
    required this.participationRate,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalSurveys: json['totalSurveys'] ?? 0,
      totalDepartments: json['totalDepartments'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      participationRate: json['participationRate'] ?? 0,
    );
  }

  factory AdminStats.empty() {
    return AdminStats(
      totalUsers: 0,
      totalSurveys: 0,
      totalDepartments: 0,
      activeUsers: 0,
      participationRate: 0,
    );
  }
}

/// Model for the survey creation form
class SurveyCreationModel {
  final String title;
  final String description;
  final List<Map<String, dynamic>> questions;
  final String estimatedTime;
  final Map<String, dynamic> reward;
  final DateTime expiresAt;
  final List<String> tags;
  final List<String> targetDepartments;

  SurveyCreationModel({
    required this.title,
    required this.description,
    required this.questions,
    required this.estimatedTime,
    required this.reward,
    required this.expiresAt,
    required this.tags,
    required this.targetDepartments,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'questions': questions,
      'estimatedTime': estimatedTime,
      'reward': reward,
      'expiresAt': expiresAt.toIso8601String(),
      'tags': tags,
      'targetDepartments': targetDepartments,
    };
  }
}
