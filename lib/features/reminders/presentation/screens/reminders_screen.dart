import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/checklist/providers/checklist_provider.dart';
import 'package:timetide/features/health_habits/presentation/widgets/habit_input_modal.dart';
import 'package:timetide/features/health_habits/providers/health_habits_provider.dart';
import 'package:timetide/features/reminders/data/models/reminder_model.dart';
import 'package:timetide/features/reminders/providers/reminders_provider.dart';
import 'package:timetide/models/unified_task_model.dart';
import '../../../health_habits/data/models/habit_model.dart';
import '../widgets/reminder_card.dart';
import '../widgets/unified_task_adapter.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RemindersProvider>(context, listen: false);
    provider.initializeNotifications();
  }

  void _showEditModal(BuildContext context,
      {UnifiedTaskModel? task, HabitModel? habit}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checklistProvider =
        Provider.of<ChecklistProvider>(context, listen: false);
    final healthHabitsProvider =
        Provider.of<HealthHabitsProvider>(context, listen: false);
    if (task != null) {
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
            child: UnifiedTaskInputAdapter(
              unifiedTask: task,
              categories: checklistProvider.categories,
              onSave: (newTask) {
                checklistProvider.updateTaskFromUnified(
                    authProvider.user!.id, newTask);
              },
            ),
          ),
        ),
      );
    } else if (habit != null) {
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
                healthHabitsProvider.updateHabit(
                    authProvider.user!.id, newHabit);
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final remindersProvider = Provider.of<RemindersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reminders',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
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
        child: StreamBuilder<List<ReminderModel>>(
          stream: remindersProvider.getReminders(authProvider.user!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final reminders = snapshot.data!;
            if (reminders.isEmpty) {
              return Center(
                child: Text(
                  'No active reminders',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return FutureBuilder(
                  future: reminder.type == 'task'
                      ? remindersProvider.getTask(reminder.referenceId)
                      : remindersProvider.getHabit(reminder.referenceId),
                  builder: (context, AsyncSnapshot snapshot) {
                    final task = reminder.type == 'task'
                        ? snapshot.data as UnifiedTaskModel?
                        : null;
                    final habit = reminder.type == 'habit'
                        ? snapshot.data as HabitModel?
                        : null;
                    return ReminderCard(
                      reminder: reminder,
                      task: task,
                      habit: habit,
                      onSnooze10Min: () {
                        remindersProvider.snoozeReminder(
                            reminder.id, const Duration(minutes: 10));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '$reminder.type snoozed for 10 minutes')),
                        );
                      },
                      onSnooze1Hour: () {
                        remindersProvider.snoozeReminder(
                            reminder.id, const Duration(hours: 1));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('$reminder.type snoozed for 1 hour')),
                        );
                      },
                      onDismiss: () {
                        remindersProvider.dismissReminder(reminder.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$reminder.type dismissed')),
                        );
                      },
                      onEdit: () =>
                          _showEditModal(context, task: task, habit: habit),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
