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
