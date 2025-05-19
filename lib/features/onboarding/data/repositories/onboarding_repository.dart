import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetide/features/onboarding/data/models/onboarding_preferences.dart';
import 'package:timetide/core/services/logging_service.dart';

class OnboardingRepository {
  static const String _preferencesKey = 'onboarding_preferences';
  final LoggingService _logger = LoggingService();

  Future<void> savePreferences(OnboardingPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(preferences.toJson());
      await prefs.setString(_preferencesKey, jsonData);
      _logger.info('Onboarding preferences saved');
    } catch (e) {
      _logger.error('Error saving onboarding preferences', error: e);
      rethrow;
    }
  }

  Future<OnboardingPreferences> getPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_preferencesKey);

      if (jsonData == null) {
        return OnboardingPreferences.defaultPreferences();
      }

      return OnboardingPreferences.fromJson(json.decode(jsonData));
    } catch (e) {
      _logger.error('Error loading onboarding preferences', error: e);
      return OnboardingPreferences.defaultPreferences();
    }
  }

  Future<bool> hasCompletedOnboarding() async {
    try {
      final preferences = await getPreferences();
      return preferences.hasCompletedOnboarding;
    } catch (e) {
      _logger.error('Error checking onboarding status', error: e);
      return false;
    }
  }

  Future<void> markOnboardingComplete() async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences =
          preferences.copyWith(hasCompletedOnboarding: true);
      await savePreferences(updatedPreferences);
      _logger.info('Onboarding marked as complete');
    } catch (e) {
      _logger.error('Error marking onboarding as complete', error: e);
      rethrow;
    }
  }

  Future<void> resetOnboarding() async {
    try {
      await savePreferences(OnboardingPreferences.defaultPreferences());
      _logger.info('Onboarding preferences reset');
    } catch (e) {
      _logger.error('Error resetting onboarding preferences', error: e);
      rethrow;
    }
  }
}
