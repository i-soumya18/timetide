class ReminderModel {
  final String id;
  final String userId;
  final String type; // 'task' or 'habit'
  final String referenceId; // taskId or habitId
  final DateTime scheduledTime;
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.referenceId,
    required this.scheduledTime,
    this.isActive = true,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      referenceId: json['referenceId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'referenceId': referenceId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isActive': isActive,
    };
  }
}