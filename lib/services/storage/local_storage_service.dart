import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetide/core/services/logging_service.dart';

class LocalStorageService {
  final LoggingService _logger = LoggingService();

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<void> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      _logger.error('Error saving string: $key', error: e);
      rethrow;
    }
  }

  Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      _logger.error('Error getting string: $key', error: e);
      return null;
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      _logger.error('Error saving bool: $key', error: e);
      rethrow;
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      _logger.error('Error getting bool: $key', error: e);
      return null;
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      _logger.error('Error saving int: $key', error: e);
      rethrow;
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      _logger.error('Error getting int: $key', error: e);
      return null;
    }
  }

  Future<void> saveDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (e) {
      _logger.error('Error saving double: $key', error: e);
      rethrow;
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(key);
    } catch (e) {
      _logger.error('Error getting double: $key', error: e);
      return null;
    }
  }

  Future<void> saveStringList(String key, List<String> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, value);
    } catch (e) {
      _logger.error('Error saving string list: $key', error: e);
      rethrow;
    }
  }

  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      _logger.error('Error getting string list: $key', error: e);
      return null;
    }
  }

  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(value));
    } catch (e) {
      _logger.error('Error saving object: $key', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(key);

      if (jsonStr == null) {
        return null;
      }

      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Error getting object: $key', error: e);
      return null;
    }
  }

  Future<bool> hasKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      _logger.error('Error checking if key exists: $key', error: e);
      return false;
    }
  }

  Future<bool> removeKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      _logger.error('Error removing key: $key', error: e);
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      _logger.error('Error clearing all storage', error: e);
      return false;
    }
  }
}
