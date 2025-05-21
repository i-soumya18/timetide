import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, inProgress, completed, cancelled }

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String userId;
  final TaskPriority priority;
  final TaskStatus status;
  final String? category;
  final bool isAiGenerated;
  final List<String>? subtasks;
  final List<String>? attachments;
  final List<DateTime>? reminderTimes;
  final String? location;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    required this.userId,
    required this.priority,
    required this.status,
    this.category,
    this.isAiGenerated = false,
    this.subtasks,
    this.attachments,
    this.reminderTimes,
    this.location,
    this.completedAt,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      userId: json['userId'] as String,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${json['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.pending,
      ),
      category: json['category'] as String?,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
          ?.map((e) => (e as Timestamp).toDate())
          .toList(),
      location: json['location'] as String?,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'userId': userId,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category,
      'isAiGenerated': isAiGenerated,
      'subtasks': subtasks,
      'attachments': attachments,
      'reminderTimes':
          reminderTimes?.map((e) => Timestamp.fromDate(e)).toList(),
      'location': location,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? category,
    List<String>? subtasks,
    List<String>? attachments,
    List<DateTime>? reminderTimes,
    String? location,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      userId: userId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      isAiGenerated: isAiGenerated,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      location: location ?? this.location,
      completedAt: completedAt ?? this.completedAt,
    );
  }
  TaskModel markAsCompleted() {
    return copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
  }
  
  // Add operator [] to allow accessing properties like a map
  dynamic operator [](String key) {
    switch (key) {
      case 'id': return id;
      case 'title': return title;
      case 'description': return description;
      case 'createdAt': return createdAt;
      case 'dueDate': return dueDate;
      case 'userId': return userId;
      case 'priority': return priority;
      case 'status': return status;
      case 'category': return category;
      case 'isAiGenerated': return isAiGenerated;
      case 'subtasks': return subtasks;
      case 'attachments': return attachments;
      case 'reminderTimes': return reminderTimes;
      case 'location': return location;
      case 'completedAt': return completedAt;
      case 'completed': return isCompleted; // Map 'completed' to isCompleted getter
      default: return null;
    }
  }
}
