import 'dart:math';

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
import 'dart:ui';

// Enhanced AppColors with premium dark theme
class AppColors {
  static const Color primary = Color(0xFF003459); // Deep Blue
  static const Color secondary = Color(0xFF1A1A2E); // Dark Blue-Black
  static const Color accent = Color(0xFF613DC1); // Royal Purple
  static const Color highlight = Color(0xFFA23B72); // Magenta
  static const Color cardBg = Color(0xFF0A1128); // Rich Dark Blue
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFBDC7C9); // Light Gray
  static const Color success = Color(0xFF39A388); // Teal
  static const Color error = Color(0xFFCF1259); // Crimson
}

class HealthHabitsScreen extends StatefulWidget {
  const HealthHabitsScreen({super.key});

  @override
  State<HealthHabitsScreen> createState() => _HealthHabitsScreenState();
}

class _HealthHabitsScreenState extends State<HealthHabitsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start staggered animations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showHabitModal(BuildContext context, {HabitModel? habit}) {
    final provider = Provider.of<HealthHabitsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF613DC1),
                blurRadius: 12,
                spreadRadius: -8,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
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
                  Navigator.pop(context);
                  _showSuccessSnackBar(context, habit == null ? 'Habit created' : 'Habit updated');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.success,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthHabitsProvider = Provider.of<HealthHabitsProvider>(context);

    // Title animation
    final titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );    return Scaffold(
      backgroundColor: AppColors.cardBg, // Using Rich Dark Blue from local AppColors
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FadeTransition(
          opacity: titleAnimation,
          child: Text(
            'Health Habits',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: AppColors.primary.withOpacity(0.8),
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights, color: AppColors.textPrimary),
            onPressed: () {
              // Show insights action
            },
            splashRadius: 24,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary,
              AppColors.cardBg,
              AppColors.primary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health metrics section with animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final metricsAnimation = CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.1, 0.6, curve: Curves.easeOutQuart),
                    );

                    return FadeTransition(
                      opacity: metricsAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(metricsAnimation),
                        child: child,
                      ),
                    );
                  },
                  child: StreamBuilder<List<HealthMetricModel>>(
                    stream: healthHabitsProvider
                        .getHealthMetrics(authProvider.user!.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.poppins(
                              color: AppColors.error,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                            strokeWidth: 3,
                          ),
                        );
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
                ),

                const SizedBox(height: 24),

                // Section title with animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final headerAnimation = CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
                    );

                    return FadeTransition(
                      opacity: headerAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(headerAnimation),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Your Habits',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // Habits list with staggered animations
                StreamBuilder<List<HabitModel>>(
                  stream: healthHabitsProvider.getHabits(authProvider.user!.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                      );
                    }

                    final habits = snapshot.data!;

                    if (habits.isEmpty) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final emptyAnimation = CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                          );

                          return FadeTransition(
                            opacity: emptyAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(emptyAnimation),
                              child: child,
                            ),
                          );
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_task,
                                  size: 48,
                                  color: AppColors.accent.withOpacity(0.7),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No habits yet. Tap + to add one!',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];

                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final listAnimation = CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                0.4 + (index * 0.05),
                                min(1.0, 0.7 + (index * 0.05)),
                                curve: Curves.easeOutQuart,
                              ),
                            );

                            return FadeTransition(
                              opacity: listAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0.3),
                                  end: Offset.zero,
                                ).animate(listAnimation),
                                child: child,
                              ),
                            );
                          },
                          child: FutureBuilder<List<HabitLogModel>>(
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

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HabitCard(
                                  habit: habit,
                                  isCompleted: isCompleted,
                                  onToggle: () {
                                    healthHabitsProvider.logHabit(
                                      authProvider.user!.id,
                                      habit.id,
                                      !isCompleted,
                                    );
                                  },
                                  onEdit: () => _showHabitModal(context, habit: habit),
                                  onDelete: () {
                                    healthHabitsProvider.deleteHabit(
                                        authProvider.user!.id, habit.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.delete, color: AppColors.error),
                                            const SizedBox(width: 12),
                                            Text(
                                              '${habit.name} deleted',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.cardBg,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(
                                            color: AppColors.error,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(12),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                // Bottom padding for FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final fabAnimation = CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
          );

          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(fabAnimation),
            child: child,
          );
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.highlight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _showHabitModal(context),
              splashColor: AppColors.highlight.withOpacity(0.3),
              highlightColor: Colors.transparent,
              child: const Icon(
                Icons.add,
                color: AppColors.textPrimary,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}