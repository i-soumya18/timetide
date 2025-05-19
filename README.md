# AI Task Planner

AI-Powered Daily Task Planner and Reminder App built with Flutter and Firebase.

## Features

- **AI-Powered Planning**: Generate optimized daily and weekly plans based on your goals
- **Task Management**: Create, organize, and track your tasks with ease
- **Smart Reminders**: Get notifications based on time, location, and priority
- **Progress Tracking**: Monitor your productivity with visual statistics
- **Calendar Integration**: View and manage tasks in a calendar view
- **Habit Building**: Track habits and build streaks to achieve your goals
- **PDF Export**: Export your plans and achievements to PDF

## Architecture

This project is built with a clean, feature-based architecture:

- **Feature-Based Structure**: Each feature is organized into its own module
- **Data-Provider-UI Layers**: Separation of concerns for maintainability
- **Provider State Management**: Efficient and readable state management
- **Firebase Backend**: Authentication, data storage, and analytics

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Firebase account
- Gemini API key (for AI features)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/ai_task_planner.git
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to the project
   - Download and place the configuration files
   - Enable Authentication and Firestore

4. Add your Gemini API key:
   - Open `lib/core/config/app_config.dart`
   - Replace `YOUR_GEMINI_API_KEY` with your actual API key

5. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
ai_task_planner/
├── assets/                          # Static assets
├── lib/                             # Main source code
│   ├── core/                        # Core app utilities
│   ├── features/                    # Feature-based modules
│   ├── models/                      # Shared data models
│   ├── services/                    # Shared services
│   ├── widgets/                     # Shared UI widgets
│   ├── firebase_options.dart        # Firebase configuration
│   └── main.dart                    # App entry point
└── test/                            # Test files
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
