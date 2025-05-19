class ChatMessageModel {
  final String id;
  final String userId;
  final String content;
  final bool isUserMessage;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? suggestedTasks;

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
    this.suggestedTasks,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      isUserMessage: json['isUserMessage'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      suggestedTasks: json['suggestedTasks'] != null
          ? List<Map<String, dynamic>>.from(json['suggestedTasks'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
      'suggestedTasks': suggestedTasks,
    };
  }
}