class SurveyModel {
  final String id;
  final String title;
  final String description;
  final int questions;
  final String estimatedTime;
  final SurveyReward reward;
  final String? expiresAt;
  final List<String> tags;
  final int? completed;
  final double? progress;
  final String? completedAt;

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.estimatedTime,
    required this.reward,
    this.expiresAt,
    required this.tags,
    this.completed,
    this.progress,
    this.completedAt,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle tags safely
      List<String> parsedTags = [];
      if (json['tags'] != null) {
        parsedTags =
            (json['tags'] as List).map((tag) => tag.toString()).toList();
      }

      // Handle questions that could be either int or List
      int questionCount;
      if (json['questions'] is int) {
        questionCount = json['questions'] as int;
      } else if (json['questions'] is List) {
        questionCount = (json['questions'] as List).length;
      } else {
        questionCount = 0; // Default if neither type matches
      }

      return SurveyModel(
        id: json['id'] as String? ?? 'unknown',
        title: json['title'] as String? ?? 'Untitled Survey',
        description: json['description'] as String? ?? 'No description',
        questions: questionCount,
        estimatedTime: json['estimatedTime'] as String? ?? 'Unknown',
        reward:
            json['reward'] != null
                ? SurveyReward.fromJson(json['reward'] as Map<String, dynamic>)
                : SurveyReward(xp: 0, coins: 0), // Default values
        expiresAt: json['expiresAt'] as String?,
        tags: parsedTags,
        completed: json['completed'] as int?,
        progress:
            json['progress'] != null
                ? (json['progress'] as num).toDouble()
                : null,
        completedAt: json['completedAt'] as String?,
      );
    } catch (e) {
      print('Error parsing SurveyModel from JSON: $e');
      // Return a default model when parsing fails
      return SurveyModel(
        id: 'error',
        title: 'Error Loading Survey',
        description: 'There was an error loading this survey',
        questions: 0,
        estimatedTime: 'Unknown',
        reward: SurveyReward(xp: 0, coins: 0),
        tags: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions,
      'estimatedTime': estimatedTime,
      'reward': reward.toJson(),
      'tags': tags,
    };

    if (expiresAt != null) data['expiresAt'] = expiresAt;
    if (completed != null) data['completed'] = completed;
    if (progress != null) data['progress'] = progress;
    if (completedAt != null) data['completedAt'] = completedAt;

    return data;
  }
}

class SurveyReward {
  final int xp;
  final int coins;

  SurveyReward({required this.xp, required this.coins});

  factory SurveyReward.fromJson(Map<String, dynamic> json) {
    return SurveyReward(
      xp: (json['xp'] as num).toInt(),
      coins: (json['coins'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'xp': xp, 'coins': coins};
  }
}
