class TaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime? time;
  final String priority;
  final bool completed;
  final int order;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    this.time,
    this.priority = 'Medium',
    this.completed = false,
    this.order = 0,
  });

  // Add operator [] to allow accessing properties like a map
  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'title':
        return title;
      case 'category':
        return category;
      case 'time':
        return time;
      case 'priority':
        return priority;
      case 'completed':
        return completed;
      case 'order':
        return order;
      default:
        return null;
    }
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
    };
  }
}
