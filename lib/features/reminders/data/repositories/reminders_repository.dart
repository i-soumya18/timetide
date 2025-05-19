import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timetide/models/unified_task_model.dart';
import '../../../../features/health_habits/data/models/habit_model.dart';
import '../models/reminder_model.dart';

class RemindersRepository {
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

  Stream<List<ReminderModel>> getReminders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromJson(doc.data()))
            .toList());
  }

  Future<UnifiedTaskModel?> getTask(String taskId) async {
    final doc = await _firestore.collection('tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return UnifiedTaskModel.fromJson(doc.data()!);
  }

  Future<HabitModel?> getHabit(String habitId) async {
    final doc = await _firestore.collection('habits').doc(habitId).get();
    if (!doc.exists) return null;
    return HabitModel.fromJson(doc.data()!);
  }

  Future<void> addReminder(String userId, ReminderModel reminder) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc();
    final newReminder = reminder.copyWith(id: docRef.id);
    await docRef.set(newReminder.toJson());

    await _scheduleNotification(
      docRef.id,
      reminder.type == 'task' ? 'Task Reminder' : 'Habit Reminder',
      reminder.scheduledTime,
    );
  }

  Future<void> snoozeReminder(String reminderId, Duration duration) async {
    final doc = await _firestore
        .collectionGroup('reminders')
        .where('id', isEqualTo: reminderId)
        .get();
    if (doc.docs.isNotEmpty) {
      final reminder = ReminderModel.fromJson(doc.docs.first.data());
      final newTime = reminder.scheduledTime.add(duration);
      await doc.docs.first.reference.update({
        'scheduledTime': newTime.toIso8601String(),
      });
      await _scheduleNotification(
        reminderId,
        reminder.type == 'task' ? 'Task Reminder' : 'Habit Reminder',
        newTime,
      );
    }
  }

  Future<void> dismissReminder(String reminderId) async {
    final doc = await _firestore
        .collectionGroup('reminders')
        .where('id', isEqualTo: reminderId)
        .get();
    if (doc.docs.isNotEmpty) {
      await doc.docs.first.reference.delete();
      await _notificationsPlugin.cancel(reminderId.hashCode);
    }
  }

  Future<void> _scheduleNotification(
      String id, String title, DateTime scheduledTime) async {
    await _notificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      'Scheduled for ${scheduledTime.toString()}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

extension on ReminderModel {
  ReminderModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? referenceId,
    DateTime? scheduledTime,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}
