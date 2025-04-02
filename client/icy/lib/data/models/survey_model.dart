class SurveyModel {
  final String id;
  final String title;
  final String description;
  final List<SurveyQuestion> questions;
  final String estimatedTime;
  final SurveyReward reward;
  final String createdAt;
  final String expiresAt;
  final List<String> tags;
  final List<String> targetDepartments;
  final bool archived;

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.estimatedTime,
    required this.reward,
    required this.createdAt,
    required this.expiresAt,
    required this.tags,
    required this.targetDepartments,
    this.archived = false,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      questions:
          (json['questions'] as List)
              .map((q) => SurveyQuestion.fromJson(q))
              .toList(),
      estimatedTime: json['estimatedTime'],
      reward: SurveyReward.fromJson(json['reward']),
      createdAt: json['createdAt'],
      expiresAt: json['expiresAt'],
      tags: List<String>.from(json['tags'] ?? []),
      targetDepartments: List<String>.from(json['targetDepartments'] ?? []),
      archived: json['archived'] ?? false,
    );
  }

  // Convert from Survey type to SurveyModel
  factory SurveyModel.fromSurvey(Survey survey) {
    return SurveyModel(
      id: survey.id,
      title: survey.title,
      description: survey.description,
      questions: survey.questions,
      estimatedTime: survey.estimatedTime,
      reward: survey.reward,
      createdAt: survey.createdAt,
      expiresAt: survey.expiresAt,
      tags: survey.tags,
      targetDepartments: survey.targetDepartments,
      archived: survey.archived,
    );
  }
}

// Re-export for backwards compatibility
typedef Survey = SurveyModel;

class SurveyQuestion {
  final String id;
  final String text;
  final String type;
  final List<dynamic> options;
  final bool optional;

  SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.optional = false,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      options: json['options'] ?? [],
      optional: json['optional'] ?? false,
    );
  }
}

class SurveyReward {
  final int xp;
  final int coins;

  SurveyReward({required this.xp, required this.coins});

  factory SurveyReward.fromJson(Map<String, dynamic> json) {
    return SurveyReward(xp: json['xp'], coins: json['coins']);
  }
}

class SurveyProgress {
  final String userId;
  final String surveyId;
  final int completed;
  final int totalQuestions;
  final String lastUpdated;
  final List<SurveyAnswer> answers;

  SurveyProgress({
    required this.userId,
    required this.surveyId,
    required this.completed,
    required this.totalQuestions,
    required this.lastUpdated,
    required this.answers,
  });

  factory SurveyProgress.fromJson(Map<String, dynamic> json) {
    return SurveyProgress(
      userId: json['userId'],
      surveyId: json['surveyId'],
      completed: json['completed'],
      totalQuestions: json['totalQuestions'],
      lastUpdated: json['lastUpdated'],
      answers:
          json['answers'] != null
              ? (json['answers'] as List)
                  .map((a) => SurveyAnswer.fromJson(a))
                  .toList()
              : [],
    );
  }
}

class SurveyAnswer {
  final String questionId;
  final dynamic answer;

  SurveyAnswer({required this.questionId, required this.answer});

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(questionId: json['questionId'], answer: json['answer']);
  }
}

class SurveyDetail {
  final Survey survey;
  final SurveyProgress? progress;

  SurveyDetail({required this.survey, this.progress});
}

extension SurveyModelDateHelpers on SurveyModel {
  // Helper method to safely get expiry date whether it's a String or DateTime
  DateTime getExpiryDate() {
    if (expiresAt is String) {
      return DateTime.parse(expiresAt as String);
    }
    return expiresAt as DateTime;
  }

  // Check if survey is expired
  bool isExpired() {
    return getExpiryDate().isBefore(DateTime.now());
  }
}
