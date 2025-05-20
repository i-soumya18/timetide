import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
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
import 'dart:ui';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    final provider = Provider.of<RemindersProvider>(context, listen: false);
    provider.initializeNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showEditModal(BuildContext context,
      {UnifiedTaskModel? task, HabitModel? habit}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checklistProvider =
    Provider.of<ChecklistProvider>(context, listen: false);
    final healthHabitsProvider =
    Provider.of<HealthHabitsProvider>(context, listen: false);

    // Add haptic feedback for premium tactile experience
    HapticFeedback.mediumImpact();

    if (task != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF004643),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                // Drag indicator
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6564DB).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: UnifiedTaskInputAdapter(
                      unifiedTask: task,
                      categories: checklistProvider.categories,
                      onSave: (newTask) {
                        checklistProvider.updateTaskFromUnified(
                            authProvider.user!.id, newTask);
                        // Add haptic feedback for confirmation
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (habit != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF004643),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.7,
            minChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                // Drag indicator
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6564DB).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: HabitInputModal(
                      habit: habit,
                      onSave: (newHabit) {
                        healthHabitsProvider.updateHabit(
                            authProvider.user!.id, newHabit);
                        // Add haptic feedback for confirmation
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                ),
              ],
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
        title: Row(
          children: [
            Text(
              'Reminders',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF613DC1),
                fontSize: 22,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Active reminder indicator - small glowing dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF6564DB),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6564DB).withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004643),
        elevation: 0,
        actions: [
          // Filter button with animation
          IconButton(
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.05,
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: const Color(0xFF613DC1),
                  ),
                );
              },
            ),
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
              HapticFeedback.selectionClick();
              // Filter functionality would go here
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new reminder functionality
          HapticFeedback.mediumImpact();
        },
        backgroundColor: const Color(0xFF613DC1),
        foregroundColor: Colors.white,
        elevation: 8,
        highlightElevation: 2,
        label: Row(
          children: [
            const Icon(Icons.notifications_active_outlined),
            const SizedBox(width: 8),
            Text(
              'Add Reminder',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004643), Color(0xFF183A37)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: const AssetImage('assets/images/pattern_overlay.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.05),
              BlendMode.dstIn,
            ),
          ),
        ),
        child: StreamBuilder<List<ReminderModel>>(
          stream: remindersProvider.getReminders(authProvider.user!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: const Color(0xFFA23B72),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA23B72),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Retry logic
                        setState(() {});
                        HapticFeedback.mediumImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF613DC1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              // Skeleton loading with shimmer effect
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return SkeletonReminderCard(
                    delayMilliseconds: index * 150,
                  );
                },
              );
            }

            final reminders = snapshot.data!;
            if (reminders.isEmpty) {
              // Enhanced empty state
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF004643),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF613DC1).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 56,
                        color: const Color(0xFF6564DB),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No active reminders',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6564DB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create a reminder to stay on track',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Add new reminder
                        HapticFeedback.mediumImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF613DC1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Create Reminder',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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

                    // Add staggered animation effect
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 300 + (index * 150)),
                          curve: Curves.easeOut,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.95, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 150)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ReminderCard(
                                reminder: reminder,
                                task: task,
                                habit: habit,
                                onSnooze10Min: () {
                                  remindersProvider.snoozeReminder(
                                      reminder.id, const Duration(minutes: 10));
                                  HapticFeedback.lightImpact();
                                  _showSnackBar(context, '${reminder.type} snoozed for 10 minutes');
                                },
                                onSnooze1Hour: () {
                                  remindersProvider.snoozeReminder(
                                      reminder.id, const Duration(hours: 1));
                                  HapticFeedback.lightImpact();
                                  _showSnackBar(context, '${reminder.type} snoozed for 1 hour');
                                },
                                onDismiss: () {
                                  remindersProvider.dismissReminder(reminder.id);
                                  HapticFeedback.mediumImpact();
                                  _showSnackBar(context, '${reminder.type} dismissed');
                                },
                                onEdit: () => _showEditModal(context, task: task, habit: habit),
                              ),
                            ),
                          ),
                        );
                      },
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF003459),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: const Color(0xFF6564DB),
          onPressed: () {},
        ),
      ),
    );
  }
}

// Skeleton loading card for shimmer effect
class SkeletonReminderCard extends StatefulWidget {
  final int delayMilliseconds;

  const SkeletonReminderCard({
    Key? key,
    this.delayMilliseconds = 0,
  }) : super(key: key);

  @override
  State<SkeletonReminderCard> createState() => _SkeletonReminderCardState();
}

class _SkeletonReminderCardState extends State<SkeletonReminderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    if (widget.delayMilliseconds > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
        if (mounted) {
          _shimmerController.repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
        }
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF003459).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF613DC1).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade500,
                    Colors.grey.shade800,
                  ],
                  stops: const [0.1, 0.3, 0.5],
                  begin: const Alignment(-1.0, -0.5),
                  end: const Alignment(1.0, 0.5),
                  transform: _SlidingGradientTransform(
                    slidePercent: _shimmerController.value,
                  ),
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}