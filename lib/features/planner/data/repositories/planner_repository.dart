import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:timetide/core/services/gemini_service.dart';
import '../models/chat_message_model.dart';

/// Repository for managing planner-related data operations, including chat messages,
/// conversation history, and task planning with AI integration.
class PlannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  /// Key for storing current conversation ID in SharedPreferences.
  static const String _currentConversationKey =
      'current_planner_conversation_id';

  /// Gets the current conversation ID for a user, or creates a new one if none exists.
  Future<String> _getCurrentConversationId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? conversationId =
        prefs.getString('${_currentConversationKey}_$userId');

    if (conversationId == null) {
      conversationId = const Uuid().v4();
      await prefs.setString(
          '${_currentConversationKey}_$userId', conversationId);
    }

    return conversationId;
  }

  /// Creates a new conversation ID and saves it to SharedPreferences.
  Future<String> createNewConversation(String userId) async {
    final conversationId = const Uuid().v4();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_currentConversationKey}_$userId', conversationId);
    return conversationId;
  }

  /// Retrieves all conversation IDs for a user, ordered by most recent message.
  Stream<List<String>> getUserConversations(String userId) {
    return _firestore
        .collection('plannerChats')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final conversationIds = snapshot.docs
          .map((doc) => doc.data()['conversationId'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();
      return conversationIds
          .cast<String>()
          .take(20)
          .toList(); // Limit for pagination
    });
  }

  /// Retrieves chat history for a user, optionally filtered by conversation ID.
  Stream<List<ChatMessageModel>> getChatHistory(
    String userId, {
    String? conversationId,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection('plannerChats')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp')
        .limit(limit); // Limit for pagination

    if (conversationId != null) {
      query = query.where('conversationId', isEqualTo: conversationId);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>))
        .where((message) => message.isValid())
        .toList());
  }

  /// Saves a single message to Firestore.
  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      if (!message.isValid()) {
        throw Exception('Invalid message data');
      }
      await _firestore
          .collection('plannerChats')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  /// Sends a user message and generates an AI response with tasks.
  Future<void> sendMessage(
    String userId,
    String message, {
    bool isNewConversation = false,
  }) async {
    try {
      if (message.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      // Get or create a conversation ID
      String conversationId;
      if (isNewConversation) {
        conversationId = await createNewConversation(userId);
      } else {
        conversationId = await _getCurrentConversationId(userId);
      }

      // Create and save user message
      final messageId = const Uuid().v4();
      final userMessage = ChatMessageModel(
        id: messageId,
        userId: userId,
        conversationId: conversationId,
        message: message.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );
      await saveMessage(userMessage); // Generate AI response with tasks
      final tasks = await _geminiService.generateTaskPlan(
        message.trim(),
      );

      // Create and save AI response
      final aiMessageId = const Uuid().v4();
      final aiMessage = ChatMessageModel(
        id: aiMessageId,
        userId: userId,
        conversationId: conversationId,
        message: 'Here’s a suggested plan based on our conversation:',
        isUser: false,
        tasks: tasks,
        timestamp: DateTime.now(),
      );
      await saveMessage(aiMessage);
    } catch (e) {
      if (e.toString().contains('API key')) {
        throw Exception('Invalid API key configuration');
      } else if (e.toString().contains('Network error')) {
        throw Exception('Network issue: Unable to reach AI service');
      } else {
        throw Exception('Failed to send message: $e');
      }
    }
  }

  /// Updates tasks in a specific message (e.g., after user edits).
  Future<void> updateTasks(
    String messageId,
    List<Map<String, dynamic>> updatedTasks,
  ) async {
    try {
      final doc =
          await _firestore.collection('plannerChats').doc(messageId).get();
      if (!doc.exists) {
        throw Exception('Message not found');
      }

      final message = ChatMessageModel.fromJson(doc.data()!);
      if (message.tasks == null) {
        throw Exception('No tasks to update');
      } // Validate updated tasks
      for (final task in updatedTasks) {
        if (!_isValidTask(task)) {
          throw Exception('Invalid task data');
        }
      }

      // Update tasks and lastModified
      await _firestore.collection('plannerChats').doc(messageId).update({
        'tasks': updatedTasks,
        'lastModified': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update tasks: $e');
    }
  }

  /// Marks tasks in a message as finalized for scheduling.
  Future<void> finalizeTasks(String messageId) async {
    try {
      final doc =
          await _firestore.collection('plannerChats').doc(messageId).get();
      if (!doc.exists) {
        throw Exception('Message not found');
      }

      await _firestore.collection('plannerChats').doc(messageId).update({
        'isFinalized': true,
        'lastModified': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to finalize tasks: $e');
    }
  }

  /// Clears all messages in a specific conversation (soft deletion).
  Future<void> clearConversation(String userId, String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('plannerChats')
          .where('userId', isEqualTo: userId)
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(
          _firestore.collection('plannerChats').doc(doc.id),
          {
            'isDeleted': true,
            'lastModified': DateTime.now().toIso8601String(),
          },
        );
      }
      await batch.commit();

      // If this is the current conversation, create a new one
      final currentId = await _getCurrentConversationId(userId);
      if (currentId == conversationId) {
        await createNewConversation(userId);
      }

      // Clear GeminiService history
      _geminiService.clearConversationHistory(userId);
    } catch (e) {
      throw Exception('Failed to clear conversation: $e');
    }
  }

  /// Archives the current conversation and starts a new one.
  Future<void> archiveAndStartNewConversation(String userId) async {
    try {
      // Create a new conversation ID
      await createNewConversation(userId);

      // Clear GeminiService history
      _geminiService.clearConversationHistory(userId);
    } catch (e) {
      throw Exception('Failed to archive and start new conversation: $e');
    }
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
