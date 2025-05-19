import 'package:flutter/material.dart';
import 'package:timetide/features/onboarding/data/models/onboarding_preferences.dart';
import 'package:timetide/features/onboarding/data/repositories/onboarding_repository.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingRepository _repository = OnboardingRepository();

  OnboardingPreferences _preferences =
      OnboardingPreferences.defaultPreferences();
  bool _isLoading = false;

  OnboardingPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;

  // Goals
  List<String> get selectedGoals => _preferences.selectedGoals;

  // Time settings
  TimeOfDay get wakeUpTime => _preferences.wakeUpTime;
  TimeOfDay get bedTime => _preferences.bedTime;

  // Reminder preferences
  bool get timeBasedReminders => _preferences.timeBasedReminders;
  bool get locationBasedReminders => _preferences.locationBasedReminders;
  bool get repeatingReminders => _preferences.repeatingReminders;

  // Onboarding status
  bool get hasCompletedOnboarding => _preferences.hasCompletedOnboarding;

  Future<void> initialize() async {
    _setLoading(true);
    _preferences = await _repository.getPreferences();
    _setLoading(false);
  }

  void toggleGoal(String goal) {
    final updatedGoals = List<String>.from(selectedGoals);

    if (updatedGoals.contains(goal)) {
      updatedGoals.remove(goal);
    } else {
      updatedGoals.add(goal);
    }

    _updatePreferences(
      _preferences.copyWith(selectedGoals: updatedGoals),
    );
  }

  void setWakeUpTime(TimeOfDay time) {
    _updatePreferences(
      _preferences.copyWith(wakeUpTime: time),
    );
  }

  void setBedTime(TimeOfDay time) {
    _updatePreferences(
      _preferences.copyWith(bedTime: time),
    );
  }

  void setTimeBasedReminders(bool value) {
    _updatePreferences(
      _preferences.copyWith(timeBasedReminders: value),
    );
  }

  void setLocationBasedReminders(bool value) {
    _updatePreferences(
      _preferences.copyWith(locationBasedReminders: value),
    );
  }

  void setRepeatingReminders(bool value) {
    _updatePreferences(
      _preferences.copyWith(repeatingReminders: value),
    );
  }

  Future<void> completeOnboarding() async {
    _setLoading(true);

    final updatedPreferences = _preferences.copyWith(
      hasCompletedOnboarding: true,
    );

    await _repository.savePreferences(updatedPreferences);
    _preferences = updatedPreferences;

    _setLoading(false);
  }

  Future<void> resetOnboarding() async {
    _setLoading(true);
    await _repository.resetOnboarding();
    _preferences = OnboardingPreferences.defaultPreferences();
    _setLoading(false);
  }

  void _updatePreferences(OnboardingPreferences newPreferences) {
    _preferences = newPreferences;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    _setLoading(true);
    await _repository.savePreferences(_preferences);
    _setLoading(false);
  }
}
