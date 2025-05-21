import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/models/unified_task_model.dart';
import '../../data/models/reminder_model.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class EnhancedReminderCard extends StatefulWidget {
  final ReminderModel reminder;
  final UnifiedTaskModel? task;
  final HabitModel? habit;
  final VoidCallback onSnooze10Min;
  final VoidCallback onSnooze1Hour;
  final VoidCallback onDismiss;
  final VoidCallback onEdit;
  final int index; // Added to align with staggered animation

  const EnhancedReminderCard({
    super.key,
    required this.reminder,
    this.task,
    this.habit,
    required this.onSnooze10Min,
    required this.onSnooze1Hour,
    required this.onDismiss,
    required this.onEdit,
    required this.index,
  });

  @override
  State<EnhancedReminderCard> createState() => _EnhancedReminderCardState();
}

class _EnhancedReminderCardState extends State<EnhancedReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 150)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
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
    final accentColor = _getTypeColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16), // Align with ListView padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF004643), // Match RemindersScreen gradient
                    const Color(0xFF003459),
                  ],
                  stops: const [0.3, 1.0],
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
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onEdit();
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: accentColor.withOpacity(0.15),
                  highlightColor: accentColor.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16), // Reduced for better fit
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Type indicator
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.2 * value),
                                    blurRadius: 12 * value,
                                    spreadRadius: 0.5 * value,
                                  ),
                                ],
                                border: Border.all(
                                  color: accentColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _getCategoryIcon(),
                                color: accentColor,
                                size: 26,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                                child: Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Type badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      widget.reminder.type == 'task'
                                          ? 'TASK'
                                          : 'HABIT',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: accentColor,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (widget.reminder.type == 'task')
                                    Text(
                                      widget.task?.category ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    )
                                  else
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 13,
                                          color: Colors.orange[300],
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Streak: ${widget.habit?.streak ?? 0}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
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
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: accentColor.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimeString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: accentColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Actions column
                        _buildEnhancedActions(accentColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedActions(Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Snooze button
        _EnhancedActionButton(
          icon: Icons.snooze_rounded,
          color: accentColor,
          tooltip: 'Snooze options',
          onPressed: () {
            HapticFeedback.selectionClick();
            _showEnhancedSnoozeOptions(context, accentColor);
          },
        ),
        const SizedBox(height: 8),
        // Dismiss button
        _EnhancedActionButton(
          icon: Icons.close_rounded,
          color: const Color(0xFFA23B72),
          tooltip: 'Dismiss',
          onPressed: () {
            HapticFeedback.mediumImpact();
            widget.onDismiss();
          },
        ),
      ],
    );
  }

  void _showEnhancedSnoozeOptions(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Match RemindersScreen modal
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF004643), // Match RemindersScreen modal
                const Color(0xFF003459),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF6564DB).withOpacity(0.6), // Match RemindersScreen
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [accentColor, const Color(0xFF6564DB)], // Consistent with RemindersScreen
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Snooze Reminder',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _EnhancedSnoozeOption(
                icon: Icons.timer_10_select_outlined,
                title: '10 Minutes',
                color: accentColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  widget.onSnooze10Min();
                },
              ),
              _EnhancedSnoozeOption(
                icon: Icons.hourglass_bottom_rounded,
                title: '1 Hour',
                color: accentColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  widget.onSnooze1Hour();
                },
              ),
              _EnhancedSnoozeOption(
                icon: Icons.edit_calendar_rounded,
                title: 'Custom Time',
                color: accentColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  widget.onEdit();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _EnhancedActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
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

class _EnhancedSnoozeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _EnhancedSnoozeOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.7),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}