import 'package:equatable/equatable.dart';

enum NotificationType { survey, achievement, team, general }

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionId;
  final String actionUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionId,
    required this.actionUrl,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? actionId,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionId: actionId ?? this.actionId,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: _parseNotificationType(json['type'] as String),
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actionId: json['actionId'] as String?,
      actionUrl: json['actionUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': _typeToString(type),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'actionId': actionId,
      'actionUrl': actionUrl,
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'survey':
        return NotificationType.survey;
      case 'achievement':
        return NotificationType.achievement;
      case 'team':
        return NotificationType.team;
      default:
        return NotificationType.general;
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.survey:
        return 'survey';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.team:
        return 'team';
      case NotificationType.general:
        return 'general';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    isRead,
    createdAt,
    actionId,
    actionUrl,
  ];
}
