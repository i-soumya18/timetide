import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetide/models/unified_task_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:timetide/features/reminders/data/models/reminder_model.dart';
import 'package:timetide/features/calendar/data/models/calendar_event_model.dart';

import '../models/calender_event_model.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore;

  CalendarRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<UnifiedTaskModel>> getTasks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UnifiedTaskModel.fromMap(doc.data()))
        .toList());
  }

  Stream<List<HabitModel>> getHabits(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HabitModel.fromMap(doc.data()))
        .toList());
  }

  Stream<List<ReminderModel>> getReminders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReminderModel.fromMap(doc.data()))
        .toList());
  }

  Future<void> addEvent(String userId, CalendarEventModel event) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(event.id)
        .set(event.toMap());
  }

  Future<void> updateEvent(String userId, CalendarEventModel event) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(event.id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar_events')
        .doc(eventId)
        .delete();
  }
}