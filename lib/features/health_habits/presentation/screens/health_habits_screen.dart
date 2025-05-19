import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/habit_model.dart';
import '../providers/health_habits_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_input_modal.dart';
import '../widgets/health_insight_card.dart';

class HealthHabitsScreen extends StatefulWidget {
  const HealthHabitsScreen({super.key});

  @override
  State<HealthHabitsScreen> createState() => _HealthHabitsScreenState();
}

class _HealthHabitsScreenState extends State<HealthHabitsScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HealthHabitsProvider>(context, listen: false);
    provider.initializeNotifications();
  }

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
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.4,
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
          'Health & Habits',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF219EBC),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8ECAE6), Color(0xFF219EBC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Insights',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<HealthMetricModel>>(
                stream: healthHabitsProvider.getHealthMetrics(authProvider.user!.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  final metrics = snapshot.data ?? [];
                  return Column(
                    children: [
                      HealthInsightCard(
                        title: 'Water Intake',
                        type: 'water',
                        metrics: metrics.where((m) => m.type == 'water').toList(),
                        goal: 8, // 8 glasses
                        onUpdate: (value) =>
                            healthHabitsProvider.updateHealthMetric(authProvider.user!.id, 'water', value),
                      ),
                      const SizedBox(height: 16),
                      HealthInsightCard(
                        title: 'Steps',
                        type: 'steps',
                        metrics: metrics.where((m) => m.type == 'steps').toList(),
                        goal: 10000, // 10,000 steps
                        onUpdate: (value) =>
                            healthHabitsProvider.updateHealthMetric(authProvider.user!.id, 'steps', value),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Daily Habits',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<HabitModel>>(
                stream: healthHabitsProvider.getHabits(authProvider.user!.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
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
                        future: healthHabitsProvider.getHabitLogs(authProvider.user!.id, habit.id),
                        builder: (context, logSnapshot) {
                          final today = DateTime.now();
                          final isCompletedToday = logSnapshot.data?.any((log) =>
                          log.date.day == today.day &&
                              log.date.month == today.month &&
                              log.date.year == today.year &&
                              log.completed) ??
                              false;
                          return HabitCard(
                            habit: habit,
                            isCompletedToday: isCompletedToday,
                            onToggle: () => healthHabitsProvider.logHabit(
                                authProvider.user!.id, habit.id, !isCompletedToday),
                            onEdit: () => _showHabitModal(context, habit: habit),
                            onDelete: () {
                              healthHabitsProvider.deleteHabit(habit.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${habit.name} deleted')),
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
        backgroundColor: const Color(0xFFFFB703),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}