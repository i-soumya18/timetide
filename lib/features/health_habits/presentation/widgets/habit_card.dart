import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/features/health_habits/data/models/habit_model.dart';
import 'dart:math' as math;

// Import AppColors class from your enhanced UI
// If not accessible, uncomment the class below
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

class HabitCard extends StatefulWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  bool _previousCompletionState = false;

  @override
  void initState() {
    super.initState();
    _previousCompletionState = widget.isCompleted;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != _previousCompletionState) {
      if (widget.isCompleted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _previousCompletionState = widget.isCompleted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorBasedOnDay() {
    // Determine color based on streak or days of week
    if (widget.habit.streak > 30) {
      return AppColors.highlight; // Long streak gets highlight color
    } else if (widget.habit.streak > 15) {
      return AppColors.accent; // Medium streak gets accent color
    } else {
      return AppColors.primary; // Short or no streak gets primary color
    }
  }

  // Get days of week string
  String _getFrequencyText() {
    if (widget.habit.frequency.isEmpty) {
      return 'Daily';
    }

    final days = widget.habit.frequency.map((day) {
      switch (day) {
        case 1: return 'Mon';
        case 2: return 'Tue';
        case 3: return 'Wed';
        case 4: return 'Thu';
        case 5: return 'Fri';
        case 6: return 'Sat';
        case 7: return 'Sun';
        default: return '';
      }
    }).join(', ');

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getColorBasedOnDay();
    final streakColor = widget.habit.streak > 0
        ? HSLColor.fromColor(baseColor).withLightness(0.6).toColor()
        : AppColors.textSecondary;

    // Calculate streak progress for the progress indicator
    final streakProgress = math.min(1.0, widget.habit.streak / 30);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBg,
            Color.lerp(AppColors.cardBg, baseColor, 0.15) ?? AppColors.cardBg,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.isCompleted
                ? baseColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: widget.isCompleted
              ? baseColor.withOpacity(0.8)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onToggle,
            splashColor: baseColor.withOpacity(0.1),
            highlightColor: baseColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Animated checkbox
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: AnimatedBuilder(
                          animation: _checkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isCompleted
                                    ? baseColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: widget.isCompleted
                                      ? baseColor
                                      : AppColors.textSecondary,
                                  width: 2,
                                ),
                              ),
                              child: widget.isCompleted
                                  ? Center(
                                child: Transform.scale(
                                  scale: _checkAnimation.value,
                                  child: Icon(
                                    Icons.check,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              )
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title with completion strikethrough animation
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                decoration: widget.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationThickness: 2,
                                color: widget.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                              child: Text(widget.habit.name),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  widget.habit.reminderTime != null
                                      ? Icons.access_time
                                      : Icons.repeat,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.habit.reminderTime != null
                                      ? widget.habit.reminderTime!.format(context)
                                      : _getFrequencyText(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            icon: Icons.edit,
                            color: AppColors.accent,
                            onPressed: widget.onEdit,
                          ),
                          _ActionButton(
                            icon: Icons.delete,
                            color: AppColors.error,
                            onPressed: widget.onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Streak indicator with animated progress
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: streakColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Streak: ${widget.habit.streak} day${widget.habit.streak == 1 ? '' : 's'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: streakColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 4,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutCubic,
                                    width: constraints.maxWidth * streakProgress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [baseColor, streakColor],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom animated action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }
}