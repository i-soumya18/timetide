import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/signup_screen.dart';
import 'features/authentication/presentation/screens/profile_setup_screen.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/checklist/presentation/screens/checklist_builder_screen.dart';
import 'features/checklist/providers/checklist_provider.dart';
import 'features/health_habits/presentation/screens/health_habits_screen.dart';
import 'features/health_habits/providers/health_habits_provider.dart';
import 'features/home/presentation/screens/home_dashboard_screen.dart';
import 'features/home/providers/home_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/planner/presentation/screens/planner_screen.dart';
import 'features/planner/providers/planner_provider.dart';
import 'features/reminders/presentation/screens/reminders_screen.dart';
import 'features/reminders/providers/reminders_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.logAppOpen();
  runApp(const AITaskPlannerApp());
}

class AITaskPlannerApp extends StatelessWidget {
  const AITaskPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => HealthHabitsProvider()),
        ChangeNotifierProvider(create: (_) => RemindersProvider()),
      ],
      child: MaterialApp(
        title: 'AI Task Planner',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        home: const AuthWrapper(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/profile_setup': (context) => const ProfileSetupScreen(),
          '/home': (context) => const HomeDashboardScreen(),
          '/tasks': (context) => const ChecklistBuilderScreen(),
          '/planner': (context) => const PlannerScreen(),
          '/habits': (context) => const HealthHabitsScreen(),
          '/reminders': (context) => const RemindersScreen(),
          '/add_task': (context) => const ChecklistBuilderScreen(),
          '/checklist': (context) => const ChecklistBuilderScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return StreamBuilder(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        if (authProvider.needsProfileSetup && !user.isAnonymous) {
          return const ProfileSetupScreen();
        }
        return const HomeDashboardScreen();
      },
    );
  }
}