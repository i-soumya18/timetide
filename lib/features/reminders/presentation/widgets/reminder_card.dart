import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../checklist/data/models/task_model.dart';
import '../../health_habits/data/models/habit_model.dart';
import '../models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final TaskModel? task;
  final HabitModel? habit;
  final VoidCallback onSnooze10Min;
  final VoidCallback onSnooze1Hour;
  final VoidCallback onDismiss;
  final VoidCallback onEdit;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.task,
    this.habit,
    required this.onSnooze10Min,
    required this.onSnooze1Hour,
    required this.onDismiss,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final title = task?.title ?? habit?.name ?? 'Unknown';
    final subtitle = reminder.type == 'task'
        ? 'Task • ${task?.category ?? 'Unknown'}'
        : 'Habit • Streak: ${habit?.streak ?? 0}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$subtitle\nTime: ${reminder.scheduledTime.toString().substring(11, 16)}',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'snooze_10min':
                onSnooze10Min();
                break;
              case 'snooze_1hour':
                onSnooze1Hour();
                break;
              case 'dismiss':
                onDismiss();
                break;
              case 'edit':
                onEdit();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'snooze_10min',
              child: Text('Snooze 10 min'),
            ),
            const PopupMenuItem(
              value: 'snooze_1hour',
              child: Text('Snooze 1 hour'),
            ),
            const PopupMenuItem(
              value: 'dismiss',
              child: Text('Dismiss'),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: Color(0xFF219EBC)),
        ),
      ),
    );
  }
}