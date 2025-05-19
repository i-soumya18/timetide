import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:timetide/core/config/app_config.dart';
import 'package:timetide/core/services/logging_service.dart';
import 'package:timetide/models/task_model.dart';
import 'dart:io' show Platform;

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final LoggingService _logger = LoggingService();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_init.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _onNotificationSelected(details.payload);
      },
    );

    _isInitialized = true;
    _logger.info('Notification service initialized');
  }

  Future<bool> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedAndroid =
          await androidImplementation?.requestNotificationsPermission();

      bool? grantedIOS = false;

      if (Platform.isIOS) {
        final iosPlatformSpecific = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        grantedIOS = await iosPlatformSpecific?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      return grantedAndroid ?? grantedIOS ?? false;
    } catch (e) {
      _logger.error('Error requesting notification permissions', error: e);
      return false;
    }
  }

  Future<void> scheduleTaskReminder(TaskModel task) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (task.dueDate == null) {
        _logger.warning(
            'Cannot schedule reminder for task without due date: ${task.id}');
        return;
      }

      // Schedule for the task's due time
      await _scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: task.dueDate!,
        payload: 'task:${task.id}',
      );

      // If the task has reminder times, schedule those as well
      if (task.reminderTimes != null && task.reminderTimes!.isNotEmpty) {
        for (int i = 0; i < task.reminderTimes!.length; i++) {
          await _scheduleNotification(
            id: '${task.id}_reminder_$i'.hashCode,
            title: 'Task Reminder',
            body: task.title,
            scheduledDate: task.reminderTimes![i],
            payload: 'task:${task.id}',
          );
        }
      }

      _logger.info('Reminder scheduled for task: ${task.id}');
    } catch (e) {
      _logger.error('Error scheduling task reminder', error: e);
    }
  }

  Future<void> cancelTaskReminders(String taskId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Cancel the main task notification
      await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);

      // We don't know how many reminders were scheduled, so we'll just assume
      // some reasonable maximum number of reminders per task (e.g., 5)
      for (int i = 0; i < 5; i++) {
        await _flutterLocalNotificationsPlugin
            .cancel('${taskId}_reminder_$i'.hashCode);
      }

      _logger.info('Reminders cancelled for task: $taskId');
    } catch (e) {
      _logger.error('Error cancelling task reminders', error: e);
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        AppConfig.notificationChannelId,
        AppConfig.notificationChannelName,
        channelDescription: AppConfig.notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(),
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      _logger.info('Instant notification shown: $title');
    } catch (e) {
      _logger.error('Error showing instant notification', error: e);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _flutterLocalNotificationsPlugin.cancelAll();
      _logger.info('All notifications cancelled');
    } catch (e) {
      _logger.error('Error cancelling all notifications', error: e);
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final now = DateTime.now();

    // Don't schedule notifications in the past
    if (scheduledDate.isBefore(now)) {
      _logger.warning('Tried to schedule notification in the past. Skipping.');
      return;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConfig.notificationChannelId,
          AppConfig.notificationChannelName,
          channelDescription: AppConfig.notificationChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  void _onNotificationSelected(String? payload) {
    if (payload == null) return;

    _logger.info('Notification selected: $payload');

    // TODO: Handle notification selection
    // For example, navigate to task details page
    // This would need to be implemented with a navigation service
  }
}
