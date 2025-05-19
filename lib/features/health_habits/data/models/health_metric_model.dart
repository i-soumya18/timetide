class HealthMetricModel {
  final String id;
  final String userId;
  final DateTime date;
  final String type; // 'water' or 'steps'
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
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      value: json['value'] as int,
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