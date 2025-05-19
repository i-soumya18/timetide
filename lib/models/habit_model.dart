import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitFrequency { daily, weekdays, weekly, custom }

class HabitModel {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final String userId;
  final HabitFrequency frequency;
  final List<int>? customDays; // For custom frequency: 1=Monday, 7=Sunday
  final TimeOfDay? reminderTime;
  final bool isArchived;
  final Map<String, bool>
      completionHistory; // Map of date strings to completion status
  final int currentStreak;
  final int longestStreak;

  HabitModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.userId,
    required this.frequency,
    this.customDays,
    this.reminderTime,
    this.isArchived = false,
    required this.completionHistory,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> historyJson =
        json['completionHistory'] as Map<String, dynamic>? ?? {};
    final Map<String, bool> history = historyJson.map(
      (key, value) => MapEntry(key, value as bool),
    );

    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      userId: json['userId'] as String,
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.toString() == 'HabitFrequency.${json['frequency']}',
        orElse: () => HabitFrequency.daily,
      ),
      customDays:
          (json['customDays'] as List<dynamic>?)?.map((e) => e as int).toList(),
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour:
                  (json['reminderTime'] as Map<String, dynamic>)['hour'] as int,
              minute: (json['reminderTime'] as Map<String, dynamic>)['minute']
                  as int,
            )
          : null,
      isArchived: json['isArchived'] as bool? ?? false,
      completionHistory: history,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic>? reminderTimeJson = reminderTime != null
        ? {
            'hour': reminderTime!.hour,
            'minute': reminderTime!.minute,
          }
        : null;

    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'frequency': frequency.toString().split('.').last,
      'customDays': customDays,
      'reminderTime': reminderTimeJson,
      'isArchived': isArchived,
      'completionHistory': completionHistory,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  HabitModel copyWith({
    String? title,
    String? description,
    HabitFrequency? frequency,
    List<int>? customDays,
    TimeOfDay? reminderTime,
    bool? isArchived,
    Map<String, bool>? completionHistory,
    int? currentStreak,
    int? longestStreak,
  }) {
    return HabitModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      userId: userId,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      completionHistory: completionHistory ?? this.completionHistory,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  bool shouldCompleteToday() {
    final now = DateTime.now();
    final weekday = now.weekday;

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return weekday >= 1 && weekday <= 5;
      case HabitFrequency.weekly:
        return weekday == 1; // Monday
      case HabitFrequency.custom:
        return customDays?.contains(weekday) ?? false;
    }
  }

  HabitModel markAsCompleted() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedHistory = Map<String, bool>.from(completionHistory);
    updatedHistory[today] = true;

    int newCurrentStreak = currentStreak;
    int newLongestStreak = longestStreak;

    // Calculate streak
    newCurrentStreak++;
    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }

    return copyWith(
      completionHistory: updatedHistory,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
    );
  }

  HabitModel markAsIncomplete() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedHistory = Map<String, bool>.from(completionHistory);
    updatedHistory[today] = false;

    return copyWith(
      completionHistory: updatedHistory,
      currentStreak: 0, // Reset streak when incomplete
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({
    required this.hour,
    required this.minute,
  });

  @override
  String toString() {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
