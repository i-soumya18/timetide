# TimeTide

<div align="center">
  <img src="assets/images/logo.png" alt="TimeTide Logo" width="200"/>
</div>

AI-Powered Daily Task Planner and Reminder App built with Flutter and Firebase. TimeTide helps you manage your time efficiently with intelligent task planning and organization.

## App Showcase

<div align="center">
  <img src="assets/images/pattern_overlay.png" alt="TimeTide UI" width="600"/>
  <p><em>TimeTide's elegant user interface with pattern overlay design</em></p>
</div>

## Features

<div align="center">
  <img src="assets/images/checklist.png" alt="Task Management" width="250" align="right"/>
</div>

- **AI-Powered Planning**: Generate optimized daily and weekly plans based on your goals and preferences
- **Intelligent Task Management**: Create, organize, and track your tasks with ease using our intuitive interface
- **Smart Reminders**: Get timely notifications based on time, location, and priority levels
- **Advanced Progress Tracking**: Monitor your productivity with detailed visual statistics and reports
- **Seamless Calendar Integration**: View and manage tasks in a clean, easy-to-use calendar view
- **Habit Building Tools**: Track habits and build streaks to achieve your long-term goals
- **PDF Export Functionality**: Export your plans, achievements, and statistics to PDF for record-keeping

<div align="center">
  <img src="assets/images/pattern.png" alt="Pattern Design" width="600"/>
  <p><em>TimeTide's unique pattern design enhances user experience</em></p>
</div>

## Architecture

This project is built with a clean, feature-based architecture:

- **Feature-Based Structure**: Each feature is organized into its own module
- **Data-Provider-UI Layers**: Separation of concerns for maintainability
- **Provider State Management**: Efficient and readable state management
- **Firebase Backend**: Authentication, data storage, and analytics

## What Makes TimeTide Special?

TimeTide stands out from other productivity apps with its unique combination of:

1. **AI-Powered Task Optimization**: Unlike regular task apps, TimeTide uses AI to analyze your productivity patterns and optimize your schedule
2. **Beautiful Fluid UI**: Custom animations and transitions create a delightful user experience
3. **Smart Context Awareness**: Tasks adjust based on your location, time of day, and available time slots
4. **Focus on Mental Well-being**: Built-in breaks and workload balancing to prevent burnout
5. **Learning Algorithm**: The more you use TimeTide, the smarter it becomes about your habits and preferences

## Current Development Status

TimeTide is currently under active development with:

- ✅ Core UI implementation
- ✅ Firebase integration
- ✅ Authentication flows
- ✅ Basic task management
- 🔄 AI planning features (in progress)
- 🔄 Calendar integration (in progress)
- 📅 Analytics dashboard (planned)
- 📅 Advanced sharing features (planned)

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Dart 3.0+
- Firebase account
- Gemini API key (for AI features)

### Development Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/timetide.git
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to the project
   - Download `google-services.json` and `GoogleService-Info.plist`
   - Enable Authentication, Firestore, and Storage

4. Configure Gemini API:
   - Create an API key at Google AI Studio
   - Set up your environment variables or secure storage

5. Run the app in debug mode:
   ```
   flutter run
   ```

### Building for Production

```
flutter build apk --release
flutter build ios --release
```

## Project Structure

```
timetide/
├── assets/                          # Static assets
│   ├── fonts/                       # Custom Poppins font family
│   ├── images/                      # App images and design elements
│   └── lottie/                      # Lottie animations for enhanced UX
├── lib/                             # Main source code
│   ├── core/                        # Core app utilities
│   ├── features/                    # Feature-based modules
│   ├── models/                      # Shared data models
│   ├── services/                    # Shared services
│   ├── templates/                   # Reusable template designs
│   ├── widgets/                     # Shared UI components
│   ├── firebase_options.dart        # Firebase configuration
│   ├── main.dart                    # App entry point
│   └── onboarding_screen.dart       # Onboarding experience
├── test/                            # Test files
└── [Platform folders]               # Native platform integrations
```

## Authentication Options

<div align="center">
  <img src="assets/images/google(1).png" alt="Google Sign-In" width="50"/>
  <p><em>Easy and secure Google sign-in integration</em></p>
</div>

TimeTide offers seamless authentication through:
- Google Sign-In
- Email and Password
- Guest Mode for quick access

## Technology Stack

- **Frontend**: Flutter with Material Design 3
- **State Management**: Provider pattern for efficient state handling
- **Backend**: Firebase (Firestore, Authentication, Storage, Analytics)
- **AI Integration**: Gemini API for intelligent planning
- **Animation**: Lottie for engaging micro-interactions
- **Notifications**: Flutter Local Notifications
- **Offline Support**: Local SQLite database with synchronization
- **UI Design**: Custom theme with Poppins font family

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
