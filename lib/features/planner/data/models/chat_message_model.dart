class ChatMessageModel {
  final String id;
  final String userId;
  final String message;
  final bool isUser;
  final List<Map<String, dynamic>>? tasks;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    this.tasks,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      message: json['message'] ?? '',
      isUser: json['isUser'] ?? false,
      tasks: json['tasks'] != null
          ? List<Map<String, dynamic>>.from(json['tasks'])
          : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'isUser': isUser,
      'tasks': tasks,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}