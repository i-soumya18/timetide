class ReminderModel {
  final String id;
  final String userId;
  final String type;
  final String referenceId;
  final DateTime scheduledTime;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.referenceId,
    required this.scheduledTime,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['referenceId'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'referenceId': referenceId,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }
}