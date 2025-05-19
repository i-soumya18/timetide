class HabitLogModel {
  final String id;
  final String userId;
  final String habitId;
  final DateTime date;
  final bool completed;

  HabitLogModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    this.completed = false,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'completed': completed,
    };
  }
}