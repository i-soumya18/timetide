import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../home/data/models/task_model.dart';

class ChecklistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskModel>> getTasks(String userId, String category) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList());
  }

  Future<void> addTask(String userId, TaskModel task) async {
    try {
      final taskId = const Uuid().v4();
      final order = await _getNextOrder(userId, task.category);
      final taskData = task.toJson()
        ..['id'] = taskId
        ..['userId'] = userId
        ..['order'] = order;
      await _firestore.collection('tasks').doc(taskId).set(taskData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderTasks(String userId, String category, List<TaskModel> tasks) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        batch.update(
          _firestore.collection('tasks').doc(task.id),
          {'order': i},
        );
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> _getNextOrder(String userId, String category) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 0;
    return (snapshot.docs.first.data()['order'] as int) + 1;
  }

  Future<List<TaskModel>> getAllTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}