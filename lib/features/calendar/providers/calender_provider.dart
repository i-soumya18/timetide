import 'package:flutter/material.dart';
import 'package:timetide/models/unified_task_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:timetide/features/reminders/data/models/reminder_model.dart';
import 'package:timetide/features/calendar/data/models/calendar_event_model.dart';
import 'package:timetide/features/calendar/data/repositories/calendar_repository.dart';

class CalendarProvider with ChangeNotifier {
  final CalendarRepository _repository;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  CalendarProvider({CalendarRepository? repository})
      : _repository = repository ?? CalendarRepository();

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  Stream<List<CalendarEventModel>> getEvents(String userId) {
    return Stream.value([]).map((_) {
      final List<CalendarEventModel> events = [];
      _repository.getTasks(userId).listen((tasks) {
        events.addAll(tasks.map((task) => CalendarEventModel.fromTask(task)));
        notifyListeners();
      });
      _repository.getHabits(userId).listen((habits) {
        for (var habit in habits) {
          // Placeholder: Add habits for the current month
          events.add(CalendarEventModel.fromHabit(habit, _selectedDate));
        }
        notifyListeners();
      });
      _repository.getReminders(userId).listen((reminders) {
        events.addAll(reminders.map((reminder) => CalendarEventModel.fromReminder(reminder)));
        notifyListeners();
      });
      return events;
    });
  }

  Future<void> addEvent(String userId, CalendarEventModel event) async {
    await _repository.addEvent(userId, event);
    notifyListeners();
  }

  Future<void> updateEvent(String userId, CalendarEventModel event) async {
    await _repository.updateEvent(userId, event);
    notifyListeners();
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    await _repository.deleteEvent(userId, eventId);
    notifyListeners();
  }
}