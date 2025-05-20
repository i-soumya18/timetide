import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color categoryColor;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Priority colors using our premium palette
    final priorityColors = {
      'High': const Color(0xFFA23B72),  // Rose for high priority
      'Medium': const Color(0xFF6564DB), // Indigo for medium priority
      'Low': const Color(0xFF183A37),    // Teal for low priority
    };

    final priorityColor = priorityColors[task.priority] ?? categoryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF222222),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            splashColor: categoryColor.withOpacity(0.15),
            highlightColor: categoryColor.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  // Main content area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox with custom animation
                        TaskCheckbox(
                          value: task.completed,
                          onChanged: (_) => onEdit(),
                          color: categoryColor,
                        ),

                        const SizedBox(width: 16),

                        // Task information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with strikethrough when completed
                              Text(
                                task.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: task.completed ? Colors.white60 : Colors.white,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.white60,
                                  decorationThickness: 2,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Task metadata with icons
                              Row(
                                children: [
                                  // Time indicator
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.white60,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    task.time != null
                                        ? task.time!.toString().substring(11, 16)
                                        : 'Anytime',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white60,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Priority chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: priorityColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: priorityColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          task.priority,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: priorityColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Column(
                          children: [
                            TaskActionButton(
                              icon: Icons.edit_outlined,
                              color: const Color(0xFF613DC1),
                              onTap: onEdit,
                              tooltip: 'Edit',
                            ),
                            const SizedBox(height: 8),
                            TaskActionButton(
                              icon: Icons.delete_outlined,
                              color: const Color(0xFFA23B72),
                              onTap: onDelete,
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom indicator showing category
                  if (!task.completed) ...[
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.milliseconds)
        .slideX(begin: 0.05, end: 0, duration: 300.milliseconds, curve: Curves.easeOutCubic);
  }
}

// Custom checkbox with animation
class TaskCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color color;

  const TaskCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  State<TaskCheckbox> createState() => _TaskCheckboxState();
}

class _TaskCheckboxState extends State<TaskCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.transparent,
                widget.color,
                _animation.value,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.value
                    ? widget.color
                    : Colors.white38,
                width: 2,
              ),
              boxShadow: widget.value ? [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ] : [],
            ),
            child: Center(
              child: Transform.scale(
                scale: _animation.value,
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom action button with hover effect
class TaskActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const TaskActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<TaskActionButton> createState() => _TaskActionButtonState();
}

class _TaskActionButtonState extends State<TaskActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.color.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              color: _isHovered ? widget.color : Colors.white60,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}