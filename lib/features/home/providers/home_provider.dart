import 'package:flutter/material.dart';
import '../../authentication/data/models/user_model.dart';
import '../data/models/task_model.dart';
import '../data/repositories/home_repository.dart';

class HomeProvider with ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();
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
}