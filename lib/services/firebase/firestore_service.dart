import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetide/core/config/app_config.dart';
import 'package:timetide/core/services/logging_service.dart';
import 'package:timetide/features/authentication/data/models/user_model.dart';
import 'package:timetide/models/task_model.dart';
import 'package:timetide/models/habit_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggingService _logger = LoggingService();

  // User related methods
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppConfig.usersCollection);

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
      _logger.info('User created in Firestore: ${user.uid}');
    } catch (e) {
      _logger.error('Error creating user in Firestore', error: e);
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!..['uid'] = doc.id);
      }
      return null;
    } catch (e) {
      _logger.error('Error getting user from Firestore', error: e);
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
      _logger.info('User updated in Firestore: ${user.uid}');
    } catch (e) {
      _logger.error('Error updating user in Firestore', error: e);
      rethrow;
    }
  }

  Future<void> updateUserPreferences(
      String userId, Map<String, dynamic> preferences) async {
    try {
      await _usersCollection.doc(userId).update({'preferences': preferences});
      _logger.info('User preferences updated: $userId');
    } catch (e) {
      _logger.error('Error updating user preferences', error: e);
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      _logger.info('User deleted from Firestore: $userId');
    } catch (e) {
      _logger.error('Error deleting user from Firestore', error: e);
      rethrow;
    }
  }

  // Task related methods
  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection(AppConfig.tasksCollection);

  Stream<List<TaskModel>> getUserTasks(String userId) {
    try {
      return _tasksCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return TaskModel.fromJson(data);
        }).toList();
      });
    } catch (e) {
      _logger.error('Error getting user tasks stream', error: e);
      rethrow;
    }
  }

  Future<List<TaskModel>> getUserTasksFuture(String userId) async {
    try {
      final snapshot = await _tasksCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e) {
      _logger.error('Error getting user tasks', error: e);
      rethrow;
    }
  }

  Future<String> addTask(TaskModel task) async {
    try {
      final docRef = await _tasksCollection.add(task.toJson());
      _logger.info('Task added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.error('Error adding task', error: e);
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toJson());
      _logger.info('Task updated: ${task.id}');
    } catch (e) {
      _logger.error('Error updating task', error: e);
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      _logger.info('Task deleted: $taskId');
    } catch (e) {
      _logger.error('Error deleting task', error: e);
      rethrow;
    }
  }

  Future<List<TaskModel>> getTasksForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _tasksCollection
          .where('userId', isEqualTo: userId)
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e) {
      _logger.error('Error getting tasks for date', error: e);
      rethrow;
    }
  }

  // Habit related methods
  CollectionReference<Map<String, dynamic>> get _habitsCollection =>
      _firestore.collection(AppConfig.habitsCollection);

  Stream<List<HabitModel>> getUserHabits(String userId) {
    try {
      return _habitsCollection
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return HabitModel.fromJson(data);
        }).toList();
      });
    } catch (e) {
      _logger.error('Error getting user habits stream', error: e);
      rethrow;
    }
  }

  Future<String> addHabit(HabitModel habit) async {
    try {
      final docRef = await _habitsCollection.add(habit.toJson());
      _logger.info('Habit added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.error('Error adding habit', error: e);
      rethrow;
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitsCollection.doc(habit.id).update(habit.toJson());
      _logger.info('Habit updated: ${habit.id}');
    } catch (e) {
      _logger.error('Error updating habit', error: e);
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsCollection.doc(habitId).delete();
      _logger.info('Habit deleted: $habitId');
    } catch (e) {
      _logger.error('Error deleting habit', error: e);
      rethrow;
    }
  }
}
