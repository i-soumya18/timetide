import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String userId;
  final String name;
  final TimeOfDay? reminderTime;
  final int streak;
  final List<int> frequency;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.reminderTime,
    this.streak = 0,
    this.frequency = const [],
  });
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<int> frequencyList = [];
    if (json['frequency'] != null) {
      if (json['frequency'] is List) {
        frequencyList = List<int>.from(json['frequency'].map((x) => x));
      }
    }

    return HabitModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['reminderTime'].split(':')[0]),
              minute: int.parse(json['reminderTime'].split(':')[1]),
            )
          : null,
      streak: json['streak'] ?? 0,
      frequency: frequencyList,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'streak': streak,
      'frequency': frequency,
    };
  }

  // Add operator [] to allow accessing properties like a map
  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'userId':
        return userId;
      case 'name':
        return name;
      case 'reminderTime':
        return reminderTime;
      case 'streak':
        return streak;
      case 'frequency':
        return frequency;
      case 'completedToday':
        return false; // Default value when accessed like a map
      default:
        return null;
    }
  }
}
