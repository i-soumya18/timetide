import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../data/models/habit_model.dart';
import '../data/models/habit_log_model.dart';
import '../data/models/health_metric_model.dart';
import '../data/repositories/health_habits_repository.dart';
import '../../reminders/data/models/reminder_model.dart';
import '../../reminders/data/repositories/reminders_repository.dart';

class HealthHabitsProvider with ChangeNotifier {
  final HealthHabitsRepository _healthHabitsRepository =
      HealthHabitsRepository();
  final RemindersRepository _remindersRepository = RemindersRepository();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> initializeNotifications() async {
    try {
      await _healthHabitsRepository.initializeNotifications();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addHabit(String userId, HabitModel habit) async {
    try {
      _errorMessage = null;
      await _healthHabitsRepository.addHabit(userId, habit);
      await _analytics.logEvent(
        name: 'habit_created',
        parameters: {
          'name': habit.name,
          'has_reminder': habit.reminderTime != null,
        },
      );
      if (habit.reminderTime != null) {
        final scheduledTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          habit.reminderTime!.hour,
          habit.reminderTime!.minute,
        );
        final reminder = ReminderModel(
          id: '',
          userId: userId,
          type: 'habit',
          referenceId: habit.id,
          scheduledTime: scheduledTime,
        );
        await _remindersRepository.addReminder(userId, reminder);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateHabit(String userId, HabitModel habit) async {
    try {
      _errorMessage = null;
      await _healthHabitsRepository.updateHabit(userId, habit);
      await _analytics.logEvent(
        name: 'habit_updated',
        parameters: {
          'name': habit.name,
          'has_reminder': habit.reminderTime != null,
        },
      );
      if (habit.reminderTime != null) {
        final scheduledTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          habit.reminderTime!.hour,
          habit.reminderTime!.minute,
        );
        final reminder = ReminderModel(
          id: '',
          userId: userId,
          type: 'habit',
          referenceId: habit.id,
          scheduledTime: scheduledTime,
        );
        await _remindersRepository.addReminder(userId, reminder);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    try {
      _errorMessage = null;
      await _healthHabitsRepository.deleteHabit(userId, habitId);
      await _analytics.logEvent(name: 'habit_deleted');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Stream<List<HabitModel>> getHabits(String userId) {
    return _healthHabitsRepository.getHabits(userId);
  }

  Future<void> logHabit(String userId, String habitId, bool completed) async {
    try {
      _errorMessage = null;
      await _healthHabitsRepository.logHabit(userId, habitId, completed);
      await _analytics.logEvent(
        name: 'habit_logged',
        parameters: {
          'habit_id': habitId,
          'completed': completed,
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<HabitLogModel>> getHabitLogs(
      String userId, String habitId) async {
    try {
      return await _healthHabitsRepository.getHabitLogs(userId, habitId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateHealthMetric(String userId, String type, int value) async {
    try {
      _errorMessage = null;
      await _healthHabitsRepository.updateHealthMetric(userId, type, value);
      await _analytics.logEvent(
        name: 'health_metric_updated',
        parameters: {
          'type': type,
          'value': value,
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Stream<List<HealthMetricModel>> getHealthMetrics(String userId) {
    return _healthHabitsRepository.getHealthMetrics(userId);
  }
}
