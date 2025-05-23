import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetide/models/unified_task_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:timetide/features/reminders/data/models/reminder_model.dart';

enum CalendarEventType { task, habit, reminder }

class CalendarEventModel {
  final String id;
  final String userId;
  final CalendarEventType type;
  final String title;
  final DateTime date;
  final bool isCompleted;
  final UnifiedTaskModel? task;
  final HabitModel? habit;
  final ReminderModel? reminder;

  CalendarEventModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.date,
    required this.isCompleted,
    this.task,
    this.habit,
    this.reminder,
  });

  factory CalendarEventModel.fromTask(UnifiedTaskModel task) {
    return CalendarEventModel(
      id: task.id,
      userId: task.userId,
      type: CalendarEventType.task,
      title: task.title,
      date: task.dueDate,
      isCompleted: task.isCompleted,
      task: task,
    );
  }

  factory CalendarEventModel.fromHabit(HabitModel habit, DateTime date) {
    return CalendarEventModel(
      id: '${habit.id}_$date',
      userId: habit.userId,
      type: CalendarEventType.habit,
      title: habit.name,
      date: date,
      isCompleted: false, // Placeholder; fetch from logs
      habit: habit,
    );
  }

  factory CalendarEventModel.fromReminder(ReminderModel reminder) {
    return CalendarEventModel(
      id: reminder.id,
      userId: reminder.userId,
      type: CalendarEventType.reminder,
      title: reminder.type == 'task' ? 'Task Reminder' : 'Habit Reminder',
      date: reminder.time,
      isCompleted: false,
      reminder: reminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
    };
  }

  factory CalendarEventModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id'],
      userId: map['userId'],
      type: CalendarEventType.values
          .firstWhere((e) => e.toString() == map['type']),
      title: map['title'],
      date: (map['date'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'],
    );
  }
}