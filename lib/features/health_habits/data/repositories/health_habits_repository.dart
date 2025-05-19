import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:timetide/features/health_habits/data/models/health_metric_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_log_model.dart';
import 'package:flutter/material.dart';

class HealthHabitsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Stream<List<HabitModel>> getHabits(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HabitModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addHabit(String userId, HabitModel habit) async {
    final docRef =
        _firestore.collection('users').doc(userId).collection('habits').doc();
    final newHabit = habit.copyWith(id: docRef.id);
    await docRef.set(newHabit.toJson());
  }

  Future<void> updateHabit(String userId, HabitModel habit) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habit.id)
        .set(habit.toJson());
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .delete();
  }

  Future<void> logHabit(String userId, String habitId, bool completed) async {
    final today = DateTime.now();
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .doc('${habitId}_${today.year}${today.month}${today.day}');
    final habit = await getHabit(habitId);
    final newLog = HabitLogModel(
      id: docRef.id,
      userId: userId,
      habitId: habitId,
      date: today,
      completed: completed,
    );
    await docRef.set(newLog.toJson());

    if (completed) {
      await updateHabit(
        userId,
        habit.copyWith(streak: habit.streak + 1),
      );
    }
  }

  Future<List<HabitLogModel>> getHabitLogs(
      String userId, String habitId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .where('habitId', isEqualTo: habitId)
        .get();
    return snapshot.docs
        .map((doc) => HabitLogModel.fromJson(doc.data()))
        .toList();
  }

  Stream<List<HealthMetricModel>> getHealthMetrics(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('health_metrics')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthMetricModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addHealthMetric(String userId, HealthMetricModel metric) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('health_metrics')
        .doc();
    final newMetric = metric.copyWith(id: docRef.id);
    await docRef.set(newMetric.toJson());
  }

  Future<void> updateHealthMetric(String userId, String type, int value) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Check if there's an existing metric for today
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_metrics')
        .where('type', isEqualTo: type)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: startOfDay.add(const Duration(days: 1)))
        .get();

    if (query.docs.isNotEmpty) {
      // Update existing metric
      final docId = query.docs.first.id;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_metrics')
          .doc(docId)
          .update({'value': value});
    } else {
      // Create new metric
      final metric = HealthMetricModel(
        id: '',
        userId: userId,
        date: today,
        type: type,
        value: value,
      );
      await addHealthMetric(userId, metric);
    }
  }

  Future<HabitModel> getHabit(String habitId) async {
    final doc = await _firestore
        .collectionGroup('habits')
        .where('id', isEqualTo: habitId)
        .get();
    return HabitModel.fromJson(doc.docs.first.data());
  }

  Future<void> scheduleHabitReminder(
      String habitId, String habitName, TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    await _notificationsPlugin.zonedSchedule(
      habitId.hashCode,
      'Habit Reminder: $habitName',
      'Time to work on your habit!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

extension on HabitModel {
  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    TimeOfDay? reminderTime,
    int? streak,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      reminderTime: reminderTime ?? this.reminderTime,
      streak: streak ?? this.streak,
    );
  }
}

extension on HealthMetricModel {
  HealthMetricModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? type,
    int? value,
  }) {
    return HealthMetricModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }
}
