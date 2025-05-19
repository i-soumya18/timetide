import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import '../data/models/task_model.dart';
import '../data/repositories/checklist_repository.dart';
import '../../reminders/data/models/reminder_model.dart';
import '../../reminders/data/repositories/reminders_repository.dart';

class ChecklistProvider with ChangeNotifier {
  final ChecklistRepository _checklistRepository = ChecklistRepository();
  final RemindersRepository _remindersRepository = RemindersRepository();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _errorMessage;
  final List<String> _categories = ['Work', 'Health', 'Errands', 'Personal'];

  String? get errorMessage => _errorMessage;
  List<String> get categories => _categories;

  Stream<List<TaskModel>> getTasks(String userId, String category) {
    return _checklistRepository.getTasks(userId, category);
  }

  Future<void> addTask(String userId, TaskModel task) async {
    try {
      _errorMessage = null;
      await _checklistRepository.addTask(userId, task);
      await _analytics.logEvent(
        name: 'task_created',
        parameters: {
          'category': task.category,
          'priority': task.priority,
          'has_time': task.time != null,
        },
      );
      if (task.time != null) {
        final reminder = ReminderModel(
          id: '',
          userId: userId,
          type: 'task',
          referenceId: task.id,
          scheduledTime: task.time!,
        );
        await _remindersRepository.addReminder(userId, reminder);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    try {
      _errorMessage = null;
      await _checklistRepository.updateTask(userId, task);
      await _analytics.logEvent(
        name: 'task_updated',
        parameters: {
          'category': task.category,
          'priority': task.priority,
          'has_time': task.time != null,
        },
      );
      if (task.time != null) {
        final reminder = ReminderModel(
          id: '',
          userId: userId,
          type: 'task',
          referenceId: task.id,
          scheduledTime: task.time!,
        );
        await _remindersRepository.addReminder(userId, reminder);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Adapter method to update a task from a UnifiedTaskModel
  Future<void> updateTaskFromUnified(String userId, dynamic unifiedTask) async {
    try {
      _errorMessage = null;
      // Convert the UnifiedTaskModel to TaskModel
      final TaskModel task = TaskModel(
        id: unifiedTask.id,
        title: unifiedTask.title,
        category: unifiedTask.category,
        time: unifiedTask.time,
        priority: unifiedTask.priority,
        completed: unifiedTask.completed,
        order: unifiedTask.order,
      );

      await _checklistRepository.updateTask(userId, task);
      await _analytics.logEvent(
        name: 'task_updated',
        parameters: {
          'category': task.category,
          'priority': task.priority,
          'has_time': task.time != null,
          'is_completed': task.completed,
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      _errorMessage = null;
      await _checklistRepository.deleteTask(userId, taskId);
      await _analytics.logEvent(name: 'task_deleted');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> reorderTasks(
      String userId, String category, List<TaskModel> tasks,
      {required int oldIndex, required int newIndex}) async {
    try {
      _errorMessage = null;
      await _checklistRepository.reorderTasks(userId, category, tasks,
          oldIndex: oldIndex, newIndex: newIndex);
      await _analytics.logEvent(
        name: 'tasks_reordered',
        parameters: {'category': category},
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Uint8List> generateChecklistPdf(String userId) async {
    try {
      final tasks = await _checklistRepository.getAllTasks(userId);
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
                level: 0,
                child: pw.Text('Daily Checklist',
                    style: const pw.TextStyle(fontSize: 24))),
            ..._categories.map((category) {
              final categoryTasks =
                  tasks.where((task) => task.category == category).toList();
              if (categoryTasks.isEmpty) return pw.SizedBox();
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                      level: 1,
                      child: pw.Text(category,
                          style: const pw.TextStyle(fontSize: 18))),
                  ...categoryTasks.map((task) => pw.Bullet(
                        text:
                            '${task.title} (${task.priority}, ${task.time != null ? task.time!.toString().substring(11, 16) : 'Anytime'})',
                      )),
                  pw.SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      await _analytics.logEvent(name: 'pdf_generated');
      return pdfBytes;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
