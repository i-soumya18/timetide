class OnboardingPreferences {
  final List<String> selectedGoals;
  final TimeOfDay wakeUpTime;
  final TimeOfDay bedTime;
  final bool timeBasedReminders;
  final bool locationBasedReminders;
  final bool repeatingReminders;
  final bool hasCompletedOnboarding;

  OnboardingPreferences({
    required this.selectedGoals,
    required this.wakeUpTime,
    required this.bedTime,
    required this.timeBasedReminders,
    required this.locationBasedReminders,
    required this.repeatingReminders,
    this.hasCompletedOnboarding = false,
  });

  factory OnboardingPreferences.defaultPreferences() {
    return OnboardingPreferences(
      selectedGoals: [],
      wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
      bedTime: const TimeOfDay(hour: 23, minute: 0),
      timeBasedReminders: true,
      locationBasedReminders: false,
      repeatingReminders: false,
      hasCompletedOnboarding: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedGoals': selectedGoals,
      'wakeUpTime': {
        'hour': wakeUpTime.hour,
        'minute': wakeUpTime.minute,
      },
      'bedTime': {
        'hour': bedTime.hour,
        'minute': bedTime.minute,
      },
      'timeBasedReminders': timeBasedReminders,
      'locationBasedReminders': locationBasedReminders,
      'repeatingReminders': repeatingReminders,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory OnboardingPreferences.fromJson(Map<String, dynamic> json) {
    return OnboardingPreferences(
      selectedGoals: List<String>.from(json['selectedGoals'] ?? []),
      wakeUpTime: TimeOfDay(
        hour: json['wakeUpTime']?['hour'] ?? 7,
        minute: json['wakeUpTime']?['minute'] ?? 0,
      ),
      bedTime: TimeOfDay(
        hour: json['bedTime']?['hour'] ?? 23,
        minute: json['bedTime']?['minute'] ?? 0,
      ),
      timeBasedReminders: json['timeBasedReminders'] ?? true,
      locationBasedReminders: json['locationBasedReminders'] ?? false,
      repeatingReminders: json['repeatingReminders'] ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }

  OnboardingPreferences copyWith({
    List<String>? selectedGoals,
    TimeOfDay? wakeUpTime,
    TimeOfDay? bedTime,
    bool? timeBasedReminders,
    bool? locationBasedReminders,
    bool? repeatingReminders,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingPreferences(
      selectedGoals: selectedGoals ?? this.selectedGoals,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      bedTime: bedTime ?? this.bedTime,
      timeBasedReminders: timeBasedReminders ?? this.timeBasedReminders,
      locationBasedReminders:
          locationBasedReminders ?? this.locationBasedReminders,
      repeatingReminders: repeatingReminders ?? this.repeatingReminders,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
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

  String format12Hour() {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
