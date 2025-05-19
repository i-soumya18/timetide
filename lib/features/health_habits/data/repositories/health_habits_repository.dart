import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';
import '../models/health_metric_model.dart';

class HealthHabitsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('app_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> addHabit(String userId, HabitModel habit) async {
    try {
      final habitId = const Uuid().v4();
      final habitData = habit.toJson()
        ..['id'] = habitId
        ..['userId'] = userId;
      await _firestore.collection('habits').doc(habitId).set(habitData);
      if (habit.reminderTime != null) {
        await _scheduleNotification(habitId, habit.name, habit.reminderTime!);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHabit(String userId, HabitModel habit) async {
    try {
      await _firestore.collection('habits').doc(habit.id).update(habit.toJson());
      if (habit.reminderTime != null) {
        await _scheduleNotification(habit.id, habit.name, habit.reminderTime!);
      } else {
        await _notificationsPlugin.cancel(habit.id.hashCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).delete();
      await _notificationsPlugin.cancel(habitId.hashCode);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<HabitModel>> getHabits(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HabitModel.fromJson(doc.data()))
        .toList());
  }

  Future<void> logHabit(String userId, String habitId, bool completed) async {
    try {
      final logId = const Uuid().v4();
      final today = DateTime.now();
      final log = HabitLogModel(
        id: logId,
        userId: userId,
        habitId: habitId,
        date: DateTime(today.year, today.month, today.day),
        completed: completed,
      );
      await _firestore.collection('habit_logs').doc(logId).set(log.toJson());

      // Update streak
      final habitDoc = await _firestore.collection('habits').doc(habitId).get();
      final habit = HabitModel.fromJson(habitDoc.data()!);
      final yesterdayLog = await _firestore
          .collection('habit_logs')
          .where('userId', isEqualTo: userId)
          .where('habitId', isEqualTo: habitId)
          .where('date',
          isEqualTo: today.subtract(const Duration(days: 1)).toIso8601String())
          .limit(1)
          .get();
      int newStreak = completed
          ? (yesterdayLog.docs.isNotEmpty && yesterdayLog.docs.first['completed']
          ? habit.streak + 1
          : 1)
          : 0;
      await _firestore
          .collection('habits')
          .doc(habitId)
          .update({'streak': newStreak});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HabitLogModel>> getHabitLogs(String userId, String habitId) async {
    try {
      final snapshot = await _firestore
          .collection('habit_logs')
          .where('userId', isEqualTo: userId)
          .where('habitId', isEqualTo: habitId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => HabitLogModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHealthMetric(String userId, String type, int value) async {
    try {
      final metricId = const Uuid().v4();
      final today = DateTime.now();
      final metric = HealthMetricModel(
        id: metricId,
        userId: userId,
        date: DateTime(today.year, today.month, today.day),
        type: type,
        value: value,
      );
      await _firestore.collection('health_metrics').doc(metricId).set(metric.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<HealthMetricModel>> getHealthMetrics(String userId) {
    return _firestore
        .collection('health_metrics')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HealthMetricModel.fromJson(doc.data()))
        .toList());
  }

  Future<void> _scheduleNotification(
      String habitId, String habitName, TimeOfDay time) async {
    final androidDetails = AndroidNotificationDetails(
      'habit_channel',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.showDailyAtTime(
      habitId.hashCode,
      'Reminder: $habitName',
      'Time to complete your habit!',
      time,
      notificationDetails,
    );
  }
}