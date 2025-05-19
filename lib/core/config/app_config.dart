class AppConfig {
  // API Keys
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String habitsCollection = 'habits';

  // App Settings
  static const int splashScreenDuration = 3; // seconds
  static const int tokenExpirationTime = 60; // minutes
  static const int maxTasksPerDay = 10;

  // Feature Flags
  static const bool enableCalendarSync = true;
  static const bool enableLocationBasedReminders = false;
  static const bool enableExportFeature = true;

  // App Defaults
  static const int defaultReminderTime = 15; // minutes before task
  static const String defaultTimeFormat = 'h:mm a'; // e.g., 3:30 PM
  static const String defaultDateFormat = 'MMM d, yyyy'; // e.g., Jan 1, 2023

  // Notifications
  static const String notificationChannelId = 'task_reminders';
  static const String notificationChannelName = 'Task Reminders';
  static const String notificationChannelDescription =
      'Notifications for task reminders';
}
