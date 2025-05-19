import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetide/features/authentication/data/models/user_model.dart';
import '../models/task_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Placeholder for tasks (to be expanded in checklist feature)
  Future<List<TaskModel>> getTodayTasks(String userId) async {
    // Mock data for MVP
    return [
      TaskModel(
        id: '1',
        title: 'Complete project proposal',
        category: 'Work',
        time: DateTime.now().add(const Duration(hours: 2)),
        priority: 'High',
      ),
      TaskModel(
        id: '2',
        title: 'Morning workout',
        category: 'Health',
        time: DateTime.now().add(const Duration(hours: 1)),
        priority: 'Medium',
      ),
    ];
  }
}