import 'package:equatable/equatable.dart';

enum NotificationType { survey, achievement, team, general }

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read; // Make this final
  final NotificationType type;
  final String? actionId;
  final String actionUrl;

  const NotificationModel({
    // Add const constructor
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.read,
    required this.type,
    this.actionId,
    this.actionUrl = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'],
      type: _parseNotificationType(json['type']),
      actionId: json['actionId'],
      actionUrl: json['actionUrl'] ?? '',
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'type': type.toString().split('.').last,
      'actionId': actionId,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? read,
    NotificationType? type,
    String? actionId,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      type: type ?? this.type,
      actionId: actionId ?? this.actionId,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    timestamp,
    read,
    type,
    actionId,
    actionUrl,
  ];
}
