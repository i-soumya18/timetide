import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/core/colors.dart';

/// A modal widget for editing task details in the planner interface.
/// Supports task ID preservation, animations, and adaptive styling for light/dark modes.
class TaskEditModal extends StatefulWidget {
  final Map<String, dynamic> task;
  final List<String> categories;
  final Function(Map<String, dynamic>) onSave;

  const TaskEditModal({
    super.key,
    required this.task,
    required this.categories,
    required this.onSave,
  });

  @override
  State<TaskEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TaskEditModal> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late String _category;
  late String _priority;
  late TimeOfDay? _time;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state
    _titleController = TextEditingController(text: widget.task['title'] ?? '');
    _category = widget.task['category'] != null && widget.categories.contains(widget.task['category'])
        ? widget.task['category'] as String
        : widget.categories.first;
    _priority = widget.task['priority'] != null && ['Low', 'Medium', 'High'].contains(widget.task['priority'])
        ? widget.task['priority'] as String
        : 'Medium';
    _time = widget.task['time'] != null ? _parseTime(widget.task['time'] as String) : null;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Parses time string (e.g., "14:30") to TimeOfDay.
  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  /// Shows a custom snackbar with the given message and color.
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: backgroundColor.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Task',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.poppins(
                        color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? AppColors.backgroundMedium.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                      prefixIcon: Icon(
                        Icons.title_rounded,
                        color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      if (value.trim().length > 100) {
                        return 'Title cannot exceed 100 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _category,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: GoogleFonts.poppins(
                        color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? AppColors.backgroundMedium.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                      ),
                    ),
                    items: widget.categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: GoogleFonts.poppins(
                        color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? AppColors.backgroundMedium.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                      prefixIcon: Icon(
                        Icons.priority_high_rounded,
                        color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                      ),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a priority';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: _time ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: isDarkMode ? AppColors.backgroundDark : Colors.white,
                                      onSurface: isDarkMode ? AppColors.textLight : AppColors.textDark,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedTime != null) {
                              setState(() {
                                _time = selectedTime;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isDarkMode
                                  ? AppColors.backgroundMedium.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: isDarkMode ? AppColors.textMedium : AppColors.textDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _time == null ? 'No time selected' : _time!.format(context),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_time != null)
                        IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: AppColors.error.withOpacity(0.8),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _time = null;
                            });
                          },
                          tooltip: 'Clear time',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: isDarkMode ? AppColors.textLight : AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            HapticFeedback.mediumImpact();
                            final updatedTask = {
                              'id': widget.task['id'] ?? '', // Preserve task ID
                              'title': _titleController.text.trim(),
                              'category': _category,
                              'priority': _priority,
                              'time': _time?.format(context),
                            };
                            widget.onSave(updatedTask);
                            Navigator.pop(context);
                            _showSnackBar('Task saved successfully', AppColors.success);
                          } else {
                            _showSnackBar('Please fix the errors', AppColors.error);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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