import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../../checklist/data/models/task_model.dart';
import '../../checklist/data/repositories/checklist_repository.dart';
import '../data/models/chat_message_model.dart';
import '../data/repositories/planner_repository.dart';

class PlannerProvider with ChangeNotifier {
  final PlannerRepository _plannerRepository = PlannerRepository();
  final ChecklistRepository _checklistRepository = ChecklistRepository();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Stream<List<ChatMessageModel>> getChatHistory(String userId) {
    return _plannerRepository.getChatHistory(userId);
  }

  Future<void> sendMessage(String userId, String message) async {
    try {
      _errorMessage = null;
      await _plannerRepository.sendMessage(userId, message);
      await _analytics.logEvent(
        name: 'planner_message_sent',
        parameters: {'message_length': message.length},
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().contains('API key')
          ? 'Invalid or missing API key. Please check your configuration.'
          : 'Failed to generate plan. Please try again later.';
      notifyListeners();
    }
  }

  Future<void> addTaskToChecklist(String userId, Map<String, dynamic> taskData) async {
    try {
      _errorMessage = null;
      final task = TaskModel(
        id: '',
        userId: userId,
        title: taskData['title'] as String,
        category: taskData['category'] as String,
        priority: taskData['priority'] as String,
        time: taskData['time'] != null
            ? DateTime.parse('2025-05-19 ${taskData['time']}:00')
            : null,
        order: 0,
      );
      await _checklistRepository.addTask(userId, task);
      await _analytics.logEvent(
        name: 'planner_task_added',
        parameters: {
          'category': task.category,
          'priority': task.priority,
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add task to checklist: $e';
      notifyListeners();
    }
  }

  Future<void> modifyTask(String userId, String messageId, Map<String, dynamic> updatedTask) async {
    try {
      _errorMessage = null;
      final doc = await FirebaseFirestore.instance
          .collection('plannerChats')
          .doc(messageId)
          .get();
      if (!doc.exists) throw Exception('Message not found');
      final message = ChatMessageModel.fromJson(doc.data()!);
      if (message.tasks == null) throw Exception('No tasks to modify');

      final updatedTasks = message.tasks!.map((task) {
        if (task['title'] == updatedTask['title']) return updatedTask;
        return task;
      }).toList();

      await FirebaseFirestore.instance
          .collection('plannerChats')
          .doc(messageId)
          .update({
        'tasks': updatedTasks,
      });
      await _analytics.logEvent(
        name: 'planner_task_modified',
        parameters: {
          'category': updatedTask['category'],
          'priority': updatedTask['priority'],
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to modify task: $e';
      notifyListeners();
    }
  }
}