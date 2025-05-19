import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../authentication/data/models/user_model.dart';
import '../data/models/task_model.dart';
import '../data/repositories/home_repository.dart';
import '../../health_habits/data/models/habit_model.dart';

class HomeProvider with ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  List<TaskModel> _todayTasks = [];
  String? _errorMessage;

  UserModel? get user => _user;
  List<TaskModel> get todayTasks => _todayTasks;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserData(String userId) async {
    try {
      _errorMessage = null;
      _user = await _homeRepository.getUser(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTodayTasks(String userId) async {
    try {
      _errorMessage = null;
      _todayTasks = await _homeRepository.getTodayTasks(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Stream<Map<String, dynamic>> getDashboardData(String userId) {
    // Create a stream controller to combine multiple data sources
    final controller = StreamController<Map<String, dynamic>>();

    // Get tasks
    _homeRepository.getTodayTasks(userId).then((tasks) {
      // Get habits from Firestore
      _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get()
          .then((snapshot) {
        final habits = snapshot.docs
            .map((doc) => HabitModel.fromJson(doc.data()))
            .toList();

        // Combine data and add to stream
        controller.add({
          'tasks': tasks,
          'habits': habits,
        });
      }).catchError((error) {
        controller.addError(error);
      });
    }).catchError((error) {
      controller.addError(error);
    });

    // Set up a refresh every 30 seconds to keep data current
    Timer.periodic(const Duration(seconds: 30), (_) {
      _homeRepository.getTodayTasks(userId).then((tasks) {
        _firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .get()
            .then((snapshot) {
          final habits = snapshot.docs
              .map((doc) => HabitModel.fromJson(doc.data()))
              .toList();

          controller.add({
            'tasks': tasks,
            'habits': habits,
          });
        }).catchError((error) {
          // Just log errors for periodic updates, don't add to stream
          print('Error updating habits: $error');
        });
      }).catchError((error) {
        print('Error updating tasks: $error');
      });
    });

    // Return a broadcast stream that closes the controller when no listeners
    return controller.stream.asBroadcastStream(
      onCancel: (_) => controller.close(),
    );
  }
}
