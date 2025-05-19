import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetide/core/config/theme.dart';
import 'package:timetide/core/services/navigation_service.dart';
import 'package:timetide/features/splash/presentation/screens/splash_screen.dart';
import 'package:timetide/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AITaskPlannerApp());
}

class AITaskPlannerApp extends StatelessWidget {
  const AITaskPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        // Add other providers here as needed
      ],
      child: Consumer<NavigationService>(
        builder: (context, navigationService, _) {
          return MaterialApp(
            title: 'AI Task Planner',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            navigatorKey: navigationService.navigatorKey,
            home: const SplashScreen(),
            routes: {
              '/auth': (context) =>
                  const Placeholder(), // TODO: Replace with actual auth screen
              '/home': (context) =>
                  const Placeholder(), // TODO: Replace with actual home screen
            },
          );
        },
      ),
    );
  }
}
