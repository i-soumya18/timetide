class HealthMetricModel {
  final String id;
  final String userId;
  final DateTime date;
  final String type;
  final int value;

  HealthMetricModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.value,
  });

  factory HealthMetricModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'] ?? '',
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'type': type,
      'value': value,
    };
  }
}