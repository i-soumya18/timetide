import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import '../../checklist/data/models/task_model.dart';
import '../../health_habits/data/models/habit_model.dart';
import '../models/reminder_model.dart';

class RemindersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('app_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notificationsPlugin.initialize(initSettings);
  }

  Stream<List<ReminderModel>> getReminders(String userId) {
    return _firestore
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReminderModel.fromJson(doc.data()))
        .toList());
  }

  Future<TaskModel?> getTask(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitModel?> getHabit(String habitId) async {
    try {
      final doc = await _firestore.collection('habits').doc(habitId).get();
      if (!doc.exists) return null;
      return HabitModel.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addReminder(String userId, ReminderModel reminder) async {
    try {
      final reminderId = const Uuid().v4();
      final reminderData = reminder.toJson()..['id'] = reminderId;
      await _firestore.collection('reminders').doc(reminderId).set(reminderData);
      await _scheduleNotification(reminder);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> snoozeReminder(String reminderId, Duration duration) async {
    try {
      final doc = await _firestore.collection('reminders').doc(reminderId).get();
      if (!doc.exists) return;
      final reminder = ReminderModel.fromJson(doc.data()!);
      final newTime = reminder.scheduledTime.add(duration);
      await _firestore.collection('reminders').doc(reminderId).update({
        'scheduledTime': newTime.toIso8601String(),
      });
      await _scheduleNotification(
        reminder.copyWith(scheduledTime: newTime),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> dismissReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).update({
        'isActive': false,
      });
      await _notificationsPlugin.cancel(reminderId.hashCode);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _scheduleNotification(ReminderModel reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Notifications for task and habit reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = reminder.type == 'task' ? 'Task Reminder' : 'Habit Reminder';
    final body = 'Time to complete your ${reminder.type}!';

    await _notificationsPlugin.schedule(
      reminder.id.hashCode,
      title,
      body,
      reminder.scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
    );
  }
}

extension on ReminderModel {
  ReminderModel copyWith({DateTime? scheduledTime}) {
    return ReminderModel(
      id: id,
      userId: userId,
      type: type,
      referenceId: referenceId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive,
    );
  }
}