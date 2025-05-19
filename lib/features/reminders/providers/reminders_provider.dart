import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:timetide/models/unified_task_model.dart';
import '../../health_habits/data/models/habit_model.dart';
import '../data/models/reminder_model.dart';
import '../data/repositories/reminders_repository.dart';

class RemindersProvider with ChangeNotifier {
  final RemindersRepository _repository = RemindersRepository();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> initializeNotifications() async {
    try {
      await _repository.initializeNotifications();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Stream<List<ReminderModel>> getReminders(String userId) {
    return _repository.getReminders(userId);
  }

  Future<UnifiedTaskModel?> getTask(String taskId) async {
    try {
      return await _repository.getTask(taskId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<HabitModel?> getHabit(String habitId) async {
    try {
      return await _repository.getHabit(habitId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> addReminder(String userId, ReminderModel reminder) async {
    try {
      _errorMessage = null;
      await _repository.addReminder(userId, reminder);
      await _analytics.logEvent(
        name: 'reminder_added',
        parameters: {'type': reminder.type},
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> snoozeReminder(String reminderId, Duration duration) async {
    try {
      _errorMessage = null;
      await _repository.snoozeReminder(reminderId, duration);
      await _analytics.logEvent(
        name: 'reminder_snoozed',
        parameters: {
          'duration_minutes': duration.inMinutes,
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> dismissReminder(String reminderId) async {
    try {
      _errorMessage = null;
      await _repository.dismissReminder(reminderId);
      await _analytics.logEvent(name: 'reminder_dismissed');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
