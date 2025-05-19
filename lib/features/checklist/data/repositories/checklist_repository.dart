import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';

class ChecklistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskModel>> getTasks(String userId, String category) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('category', isEqualTo: category)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addTask(String userId, TaskModel task) async {
    final docRef =
        _firestore.collection('users').doc(userId).collection('tasks').doc();
    final newTask = task.copyWith(id: docRef.id);
    await docRef.set(newTask.toJson());
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> reorderTasks(
      String userId, String category, List<TaskModel> tasks,
      {required int oldIndex, required int newIndex}) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final updatedTasks = List<TaskModel>.from(tasks);
    final task = updatedTasks.removeAt(oldIndex);
    updatedTasks.insert(newIndex, task);

    final batch = _firestore.batch();
    for (var i = 0; i < updatedTasks.length; i++) {
      final task = updatedTasks[i];
      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(task.id),
        task.copyWith(order: i).toJson(),
      );
    }
    await batch.commit();
  }

  Future<List<TaskModel>> getAllTasks(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();
    return snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
  }
}
