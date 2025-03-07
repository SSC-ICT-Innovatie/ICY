class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final double progress;
  final String progressText;
  final ChallengeReward reward;
  final String? endDate;
  final bool repeatable;
  final int? cooldownDays;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.progress,
    required this.progressText,
    required this.reward,
    this.endDate,
    this.repeatable = false,
    this.cooldownDays,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      progress:
          json['progress'] is double
              ? json['progress']
              : double.tryParse(json['progress'].toString()) ?? 0.0,
      progressText: json['progressText'] as String,
      reward: ChallengeReward.fromJson(json['reward'] as Map<String, dynamic>),
      endDate: json['endDate'] as String?,
      repeatable: json['repeatable'] as bool? ?? false,
      cooldownDays: json['cooldownDays'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'progress': progress,
      'progressText': progressText,
      'reward': reward.toJson(),
      'repeatable': repeatable,
    };

    if (endDate != null) data['endDate'] = endDate;
    if (cooldownDays != null) data['cooldownDays'] = cooldownDays;

    return data;
  }
}

class ChallengeReward {
  final int xp;
  final int coins;
  final String? badge;

  ChallengeReward({required this.xp, required this.coins, this.badge});

  factory ChallengeReward.fromJson(Map<String, dynamic> json) {
    return ChallengeReward(
      xp: (json['xp'] as num).toInt(),
      coins: (json['coins'] as num).toInt(),
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'xp': xp, 'coins': coins};

    if (badge != null) {
      data['badge'] = badge;
    }

    return data;
  }
}
