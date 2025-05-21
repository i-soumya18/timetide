import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:timetide/models/unified_task_model.dart';
import '../../data/models/reminder_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:timetide/features/reminders/data/models/reminder_model.dart';

class ReminderCard extends StatefulWidget {
  final ReminderModel reminder;
  final UnifiedTaskModel? task;
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
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getTimeString() {
    final timeStr = widget.reminder.scheduledTime.toString().substring(11, 16);
    return timeStr;
  }

  IconData _getCategoryIcon() {
    if (widget.reminder.type == 'task') {
      final category = widget.task?.category.toLowerCase() ?? '';

      switch (category) {
        case 'work':
          return Icons.work_rounded;
        case 'personal':
          return Icons.person_rounded;
        case 'health':
          return Icons.favorite_rounded;
        case 'education':
          return Icons.school_rounded;
        default:
          return Icons.assignment_rounded;
      }
    } else {
      return Icons.repeat_rounded;
    }
  }

  Color _getTypeColor() {
    if (widget.reminder.type == 'task') {
      return const Color(0xFF6564DB); // Purple for tasks
    } else {
      return const Color(0xFFA23B72); // Pink for habits
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task?.title ?? widget.habit?.name ?? 'Unknown';
    final subtitle = widget.reminder.type == 'task'
        ? 'Task • ${widget.task?.category ?? 'Unknown'}'
        : 'Habit • Streak: ${widget.habit?.streak ?? 0}';
    final typeColor = _getTypeColor();

    // Define colors based on the provided premium color palette
    final Color cardBackground1 = const Color(0xFF004643); // Dark teal
    final Color cardBackground2 = const Color(0xFF003459); // Deep blue
    final Color accentColor = widget.reminder.type == 'task'
        ? const Color(0xFF6564DB) // Purple accent for tasks
        : const Color(0xFFA23B72); // Pink accent for habits

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardBackground1,
              cardBackground2,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 0.5,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onEdit,
            borderRadius: BorderRadius.circular(20),
            splashColor: accentColor.withOpacity(0.15),
            highlightColor: accentColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Enhanced type indicator with animated shadow
                  TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.2 * value),
                                blurRadius: 10 * value,
                                spreadRadius: 0.5 * value,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(),
                            color: accentColor,
                            size: 30,
                          ),
                        );
                      }),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.reminder.type == 'task'
                                    ? 'TASK'
                                    : 'HABIT',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.reminder.type == 'task')
                              Text(
                                widget.task?.category ?? 'Unknown',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 14,
                                    color: Colors.orange[300],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Streak: ${widget.habit?.streak ?? 0}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.white60,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  _buildActions(typeColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(Color typeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.snooze_rounded,
          color: typeColor,
          tooltip: 'Snooze options',
          onPressed: () {
            _showSnoozeOptions(context);
          },
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.close_rounded,
          color: const Color(0xFFA23B72),
          tooltip: 'Dismiss',
          onPressed: widget.onDismiss,
        ),
      ],
    );
  }

  void _showSnoozeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF003459),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Snooze Reminder',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _SnoozeOption(
              icon: Icons.timer_10_select_outlined,
              title: '10 Minutes',
              onTap: () {
                Navigator.pop(context);
                widget.onSnooze10Min();
              },
            ),
            _SnoozeOption(
              icon: Icons.hourglass_bottom_rounded,
              title: '1 Hour',
              onTap: () {
                Navigator.pop(context);
                widget.onSnooze1Hour();
              },
            ),
            _SnoozeOption(
              icon: Icons.edit_calendar_rounded,
              title: 'Custom Time',
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Tooltip(
              message: tooltip,
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnoozeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SnoozeOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6564DB).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF6564DB),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
