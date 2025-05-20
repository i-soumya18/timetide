import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:timetide/features/health_habits/data/models/health_metric_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_log_model.dart';
import 'package:timetide/features/health_habits/providers/health_habits_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_input_modal.dart';
import '../widgets/health_insight_card.dart';
import 'package:timetide/core/colors.dart';

class HealthHabitsScreen extends StatefulWidget {
  const HealthHabitsScreen({super.key});

  @override
  State<HealthHabitsScreen> createState() => _HealthHabitsScreenState();
}

class _HealthHabitsScreenState extends State<HealthHabitsScreen> {
  void _showHabitModal(BuildContext context, {HabitModel? habit}) {
    final provider = Provider.of<HealthHabitsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: HabitInputModal(
            habit: habit,
            onSave: (newHabit) {
              if (habit == null) {
                provider.addHabit(authProvider.user!.id, newHabit);
              } else {
                provider.updateHabit(authProvider.user!.id, newHabit);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthHabitsProvider = Provider.of<HealthHabitsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Habits',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<List<HealthMetricModel>>(
                stream: healthHabitsProvider
                    .getHealthMetrics(authProvider.user!.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final metrics = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HealthInsightCard(
                        title: 'Water Intake',
                        icon: Icons.local_drink,
                        metrics:
                            metrics.where((m) => m.type == 'water').toList(),
                        type: 'water',
                        goal: 8,
                        onUpdate: (value) {
                          healthHabitsProvider.updateHealthMetric(
                              authProvider.user!.id, 'water', value);
                        },
                      ),
                      HealthInsightCard(
                        title: 'Steps',
                        icon: Icons.directions_walk,
                        metrics:
                            metrics.where((m) => m.type == 'steps').toList(),
                        type: 'steps',
                        goal: 10000,
                        onUpdate: (value) {
                          healthHabitsProvider.updateHealthMetric(
                              authProvider.user!.id, 'steps', value);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Your Habits',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 18),
              ),
              StreamBuilder<List<HabitModel>>(
                stream: healthHabitsProvider.getHabits(authProvider.user!.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final habits = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return FutureBuilder<List<HabitLogModel>>(
                        future: healthHabitsProvider.getHabitLogs(
                            authProvider.user!.id, habit.id),
                        builder: (context, logSnapshot) {
                          final today = DateTime.now();
                          final isCompleted = logSnapshot.data?.any((log) =>
                                  log.date.day == today.day &&
                                  log.date.month == today.month &&
                                  log.date.year == today.year &&
                                  log.completed) ??
                              false;
                          return HabitCard(
                            habit: habit,
                            isCompleted: isCompleted,
                            onToggle: () {
                              healthHabitsProvider.logHabit(
                                authProvider.user!.id,
                                habit.id,
                                !isCompleted,
                              );
                            },
                            onEdit: () =>
                                _showHabitModal(context, habit: habit),
                            onDelete: () {
                              healthHabitsProvider.deleteHabit(
                                  authProvider.user!.id, habit.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${habit.name} deleted')),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitModal(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
