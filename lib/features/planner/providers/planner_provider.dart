import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';
import 'package:timetide/features/checklist/data/repositories/checklist_repository.dart';
import 'package:timetide/features/planner/data/models/chat_message_model.dart';
import 'package:timetide/features/planner/data/repositories/planner_repository.dart';

/// Provider for managing planner-related state and business logic.
/// Handles conversations, task refinement, finalization, and analytics.
class PlannerProvider with ChangeNotifier {
  final PlannerRepository _plannerRepository = PlannerRepository();
  final ChecklistRepository _checklistRepository = ChecklistRepository();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  String? _errorMessage;
  String? _currentConversationId;
  bool _isProcessing = false;
  final Map<String, Map<String, dynamic>> _selectedTasks = {};
  final Map<String, Map<String, dynamic>> _finalizedTasks = {};

  String? get errorMessage => _errorMessage;
  String? get currentConversationId => _currentConversationId;
  bool get isProcessing => _isProcessing;
  Map<String, Map<String, dynamic>> get selectedTasks =>
      Map.unmodifiable(_selectedTasks);
  Map<String, Map<String, dynamic>> get finalizedTasks =>
      Map.unmodifiable(_finalizedTasks);

  /// Retrieves chat history for a user, optionally filtered by conversation ID.
  Stream<List<ChatMessageModel>> getChatHistory(
    String userId, {
    String? conversationId,
  }) {
    return _plannerRepository.getChatHistory(
      userId,
      conversationId: conversationId,
      limit: 50, // Pagination limit
    );
  }

  /// Retrieves all conversation IDs for a user.
  Stream<List<String>> getUserConversations(String userId) {
    return _plannerRepository.getUserConversations(userId);
  }

  /// Sends a message to the planner, optionally starting a new conversation.
  Future<void> sendMessage(
    String userId,
    String message, {
    bool isNewConversation = false,
  }) async {
    try {
      _errorMessage = null;
      _isProcessing = true;
      notifyListeners();

      await _plannerRepository.sendMessage(
        userId,
        message,
        isNewConversation: isNewConversation,
      );

      if (isNewConversation) {
        _currentConversationId =
            await _plannerRepository.createNewConversation(userId);
      } else
        _currentConversationId ??=
            await _plannerRepository.createNewConversation(userId);
      await _analytics.logEvent(
        name: 'planner_message_sent',
        parameters: {
          'message_length': message.length,
          'conversation_id': _currentConversationId ?? 'unknown',
          'is_new_conversation':
              isNewConversation ? "true" : "false", // Convert boolean to string
        },
      );
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      await _analytics.logEvent(
        name: 'planner_message_error',
        parameters: {'error': e.toString()},
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Adds a task to the checklist.
  Future<void> addTaskToChecklist(
      String userId, Map<String, dynamic> taskData) async {
    try {
      _errorMessage = null;
      if (!_isValidTask(taskData)) {
        throw Exception('Invalid task data');
      }

      final task = TaskModel(
        id: taskData['id'] as String? ?? '',
        userId: userId,
        title: taskData['title'] as String,
        category: taskData['category'] as String,
        priority: taskData['priority'] as String,
        time: taskData['time'] != null
            ? _parseTaskTime(taskData['time'] as String)
            : null,
        order: 0,
      );

      await _checklistRepository.addTask(userId, task);
      await _analytics.logEvent(
        name: 'planner_task_added',
        parameters: {
          'task_id': task.id,
          'category': task.category,
          'priority': task.priority,
          'has_time':
              task.time != null ? "true" : "false", // Convert boolean to string
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Failed to add task to checklist: ${_formatErrorMessage(e)}';
      await _analytics.logEvent(
        name: 'planner_task_add_error',
        parameters: {'error': e.toString()},
      );
      notifyListeners();
    }
  }

  /// Modifies a task in a specific message.
  Future<void> modifyTask(
    String userId,
    String messageId,
    Map<String, dynamic> updatedTask,
  ) async {
    try {
      _errorMessage = null;
      if (!_isValidTask(updatedTask)) {
        throw Exception('Invalid task data');
      }

      await _plannerRepository.updateTasks(messageId, [updatedTask]);
      if (_selectedTasks.containsKey(updatedTask['id'])) {
        _selectedTasks[updatedTask['id']] = updatedTask;
      }

      await _analytics.logEvent(
        name: 'planner_task_modified',
        parameters: {
          'task_id': updatedTask['id'] as String? ?? 'unknown',
          'category': updatedTask['category'] as String,
          'priority': updatedTask['priority'] as String,
          'conversation_id': _currentConversationId ?? 'unknown',
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to modify task: ${_formatErrorMessage(e)}';
      await _analytics.logEvent(
        name: 'planner_task_modify_error',
        parameters: {'error': e.toString()},
      );
      notifyListeners();
    }
  }

  /// Toggles task selection for finalization.
  void toggleTaskSelection(String taskId, Map<String, dynamic> task) {
    if (_selectedTasks.containsKey(taskId)) {
      _selectedTasks.remove(taskId);
    } else {
      _selectedTasks[taskId] = task;
    }
    notifyListeners();

    _analytics.logEvent(
      name: 'planner_task_selection_toggled',
      parameters: {
        'task_id': taskId,
        'is_selected': _selectedTasks.containsKey(taskId),
        'category': task['category'] as String,
        'priority': task['priority'] as String,
      },
    );
  }

  /// Finalizes selected tasks and adds them to the checklist.
  Future<void> finalizeSelectedTasks(String userId) async {
    try {
      _errorMessage = null;
      if (_selectedTasks.isEmpty) {
        throw Exception('No tasks selected');
      }

      // Add tasks to checklist
      for (final task in _selectedTasks.values) {
        await addTaskToChecklist(userId, task);
        _finalizedTasks[task['id'] as String] = task;
      }

      // Find messages containing selected tasks and mark as finalized
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('plannerChats')
          .where('userId', isEqualTo: userId)
          .where('conversationId', isEqualTo: _currentConversationId)
          .where('isDeleted', isEqualTo: false)
          .get();

      for (final doc in messagesSnapshot.docs) {
        final message = ChatMessageModel.fromJson(doc.data());
        if (message.tasks == null || message.isFinalized) continue;

        final hasSelectedTask = message.tasks!
            .any((task) => _selectedTasks.containsKey(task['id']));
        if (hasSelectedTask) {
          await _plannerRepository.finalizeTasks(doc.id);
        }
      }

      // Clear selected tasks
      _selectedTasks.clear();

      await _analytics.logEvent(
        name: 'planner_tasks_finalized',
        parameters: {
          'task_count': _finalizedTasks.length,
          'conversation_id': _currentConversationId ?? 'unknown',
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to finalize tasks: ${_formatErrorMessage(e)}';
      await _analytics.logEvent(
        name: 'planner_task_finalize_error',
        parameters: {'error': e.toString()},
      );
      notifyListeners();
    }
  }

  /// Starts a new conversation.
  Future<void> startNewConversation(String userId) async {
    try {
      _errorMessage = null;
      _currentConversationId =
          await _plannerRepository.createNewConversation(userId);
      _selectedTasks.clear();
      _finalizedTasks.clear();
      notifyListeners();

      await _analytics.logEvent(
        name: 'planner_new_conversation',
        parameters: {'conversation_id': _currentConversationId ?? 'unknown'},
      );
    } catch (e) {
      _errorMessage =
          'Failed to start new conversation: ${_formatErrorMessage(e)}';
      await _analytics.logEvent(
        name: 'planner_new_conversation_error',
        parameters: {'error': e.toString()},
      );
      notifyListeners();
    }
  }

  /// Loads an existing conversation.
  Future<void> loadConversation(String userId, String conversationId) async {
    try {
      _errorMessage = null;
      _currentConversationId = conversationId;
      _selectedTasks.clear();
      _finalizedTasks.clear();
      notifyListeners();

      await _analytics.logEvent(
        name: 'planner_conversation_loaded',
        parameters: {'conversation_id': conversationId},
      );
    } catch (e) {
      _errorMessage = 'Failed to load conversation: ${_formatErrorMessage(e)}';
      await _analytics.logEvent(
        name: 'planner_conversation_load_error',
        parameters: {'error': e.toString()},
      );
      notifyListeners();
    }
  }

  /// Clears a conversation (soft deletion).
  Future<void> clearConversation(String userId, String conversationId) async {
    try {
      _errorMessage = null;
      await _plannerRepository.clearConversation(userId, conversationId);
      if (_currentConversationId == conversationId) {
        _currentConversationId =
            await _plannerRepository.createNewConversation(userId);
      }
      _selectedTasks.clear();
      _finalizedTasks.clear();
      notifyListeners();

      await _analytics.logEvent(
        name: 'planner_conversation_cleared',
        parameters: {'conversation_id': conversationId},
      );
    } catch (e) {
      _errorMessage = 'Failed to clear conversation: ${_formatErrorMessage(e)}';
      await _analytics.logEvent(
        name: 'planner_conversation_clear_error',
        parameters: {'error': e.toString()},
      );
      notifyListeners();
    }
  }

  /// Validates a task for required fields.
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

  /// Parses task time string to DateTime, assuming current date if needed.
  DateTime? _parseTaskTime(String time) {
    try {
      final now = DateTime.now();
      // Directly format the date without using DateFormat
      final parsedTime = DateTime.parse(
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $time:00');
      return parsedTime;
    } catch (e) {
      return null;
    }
  }

  /// Formats error messages for user-friendly display.
  String _formatErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.contains('API key')) {
      return 'Invalid or missing API key. Please contact support.';
    } else if (message.contains('Network error')) {
      return 'Network issue. Please check your connection and try again.';
    } else if (message.contains('Invalid task data')) {
      return 'Task data is incomplete or invalid. Please check and try again.';
    } else if (message.contains('Message not found')) {
      return 'The requested message could not be found.';
    } else if (message.contains('No tasks selected')) {
      return 'Please select at least one task to finalize.';
    }
    return message.replaceAll('Exception: ', '');
  }
}
