class TaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime? time;
  final String priority;
  final bool completed;
  final int order;
  final String? userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    this.time,
    this.priority = 'Medium',
    this.completed = false,
    this.order = 0,
    this.userId,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? time,
    String? priority,
    bool? completed,
    int? order,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      order: order ?? this.order,
      userId: userId ?? this.userId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      time:
          json['time'] != null ? DateTime.parse(json['time'] as String) : null,
      priority: json['priority'] as String,
      completed: json['completed'] as bool,
      order: json['order'] as int? ?? 0,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'time': time?.toIso8601String(),
      'priority': priority,
      'completed': completed,
      'order': order,
      'userId': userId,
    };
  }
}
