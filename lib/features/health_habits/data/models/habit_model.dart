class HabitModel {
  final String id;
  final String userId;
  final String name;
  final TimeOfDay? reminderTime;
  final int streak;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.reminderTime,
    this.streak = 0,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
        hour: int.parse(json['reminderTime'].split(':')[0]),
        minute: int.parse(json['reminderTime'].split(':')[1]),
      )
          : null,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'reminderTime': reminderTime != null ? '${reminderTime!.hour}:${reminderTime!.minute}' : null,
      'streak': streak,
    };
  }
}