import 'package:uuid/uuid.dart';

/// Represents a chat message in the AI planner application.
/// Supports continuous conversations, task refinement, scheduling, and history access.
class ChatMessageModel {
  /// Unique identifier for the message.
  final String id;

  /// Identifier for the user who sent or received the message.
  final String userId;

  /// Identifier for the conversation this message belongs to.
  final String conversationId;

  /// The content of the message.
  final String message;

  /// Indicates whether the message is from the user (true) or AI (false).
  final bool isUser;

  /// List of tasks associated with the message (optional, typically from AI responses).
  final List<Map<String, dynamic>>? tasks;

  /// Timestamp when the message was created.
  final DateTime timestamp;

  /// Timestamp when the message was last modified (e.g., task updates).
  final DateTime lastModified;

  /// Indicates whether the message is soft-deleted (for history management).
  final bool isDeleted;

  /// Indicates whether tasks in this message have been finalized for scheduling.
  final bool isFinalized;

  ChatMessageModel({
    String? id,
    required this.userId,
    required this.conversationId,
    required this.message,
    required this.isUser,
    this.tasks,
    DateTime? timestamp,
    DateTime? lastModified,
    this.isDeleted = false,
    this.isFinalized = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        lastModified = lastModified ?? timestamp ?? DateTime.now();

  /// Creates a ChatMessageModel from a JSON map (e.g., from Firestore).
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['userId'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? const Uuid().v4(),
      message: json['message'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      tasks: json['tasks'] != null
          ? (json['tasks'] as List<dynamic>)
              .map((task) => Map<String, dynamic>.from(task as Map))
              .toList()
          : null,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      lastModified: DateTime.tryParse(json['lastModified'] as String? ?? '') ??
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      isFinalized: json['isFinalized'] as bool? ?? false,
    );
  }

  /// Converts the ChatMessageModel to a JSON map (e.g., for Firestore).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'conversationId': conversationId,
      'message': message,
      'isUser': isUser,
      'tasks': tasks,
      'timestamp': timestamp.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'isDeleted': isDeleted,
      'isFinalized': isFinalized,
    };
  }

  /// Creates a copy of the ChatMessageModel with updated fields.
  ChatMessageModel copyWith({
    String? id,
    String? userId,
    String? conversationId,
    String? message,
    bool? isUser,
    List<Map<String, dynamic>>? tasks,
    DateTime? timestamp,
    DateTime? lastModified,
    bool? isDeleted,
    bool? isFinalized,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      tasks: tasks ?? this.tasks,
      timestamp: timestamp ?? this.timestamp,
      lastModified: lastModified ?? this.lastModified,
      isDeleted: isDeleted ?? this.isDeleted,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }

  /// Validates the message model for required fields and constraints.
  bool isValid() {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        conversationId.isNotEmpty &&
        message.isNotEmpty &&
        (tasks == null ||
            tasks!.every((task) => _isValidTask(task)));
  }

  /// Validates a task for required fields and constraints.
  bool _isValidTask(Map<String, dynamic> task) {
    return task.containsKey('id') &&
        task['id'] is String &&
        task.containsKey('title') &&
        task['title'] is String &&
        task.containsKey('category') &&
        task['category'] is String &&
        task.containsKey('priority') &&
        task['priority'] is String &&
        (task['time'] == null || task['time'] is String);
  }
}