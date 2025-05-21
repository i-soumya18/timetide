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
    required this.completed,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      habitId: json['habitId'] ?? '',
      date: DateTime.parse(json['date']),
      completed: json['completed'] ?? false,
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
  
  // Add operator [] to allow accessing properties like a map
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'userId': return userId;
      case 'habitId': return habitId;
      case 'date': return date;
      case 'completed': return completed;
      default: return null;
    }
  }
}