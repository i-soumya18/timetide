class UnifiedTaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime? time;
  final String priority;
  final bool completed;
  final int order;
  final String? userId;

  UnifiedTaskModel({
    required this.id,
    required this.title,
    required this.category,
    this.time,
    this.priority = 'Medium',
    this.completed = false,
    this.order = 0,
    this.userId,
  });

  // Copy constructor from ChecklistTaskModel
  factory UnifiedTaskModel.fromChecklistTaskModel(dynamic task) {
    return UnifiedTaskModel(
      id: task.id,
      title: task.title,
      category: task.category,
      time: task.time,
      priority: task.priority,
      completed: task.completed,
      order: task.order,
      userId: task.userId,
    );
  }

  // Copy constructor from HomeTaskModel
  factory UnifiedTaskModel.fromHomeTaskModel(dynamic task) {
    return UnifiedTaskModel(
      id: task.id,
      title: task.title,
      category: task.category,
      time: task.time,
      priority: task.priority,
      completed: task.completed,
      order: task.order,
      userId: null, // Home model doesn't have userId
    );
  }

  UnifiedTaskModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? time,
    String? priority,
    bool? completed,
    int? order,
    String? userId,
  }) {
    return UnifiedTaskModel(
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

  factory UnifiedTaskModel.fromJson(Map<String, dynamic> json) {
    return UnifiedTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      time:
          json['time'] != null ? DateTime.parse(json['time'] as String) : null,
      priority: json['priority'] as String,
      completed: json['completed'] as bool? ?? false,
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
  
  // Add operator [] to allow accessing properties like a map
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'title': return title;
      case 'category': return category;
      case 'time': return time;
      case 'priority': return priority;
      case 'completed': return completed;
      case 'completedToday': return completed; // For compatibility with habits code
      case 'order': return order;
      case 'userId': return userId;
      default: return null;
    }
  }
}
