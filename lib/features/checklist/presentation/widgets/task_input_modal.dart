import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';
import 'package:flutter/services.dart';

class TaskInputModal extends StatefulWidget {
  final TaskModel? task;
  final List<String> categories;
  final Function(TaskModel) onSave;

  const TaskInputModal({
    super.key,
    this.task,
    required this.categories,
    required this.onSave,
  });

  @override
  State<TaskInputModal> createState() => _TaskInputModalState();
}

class _TaskInputModalState extends State<TaskInputModal> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  String _category = 'Work';
  String _priority = 'Medium';
  DateTime? _time;
  bool _completed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Define our premium color palette
  final Color _primaryColor = const Color(0xFF6564DB); // Purple primary
  final Color _accentColor = const Color(0xFFA23B72);  // Rose accent
  final Color _backgroundColor = const Color(0xFF121212); // Dark background
  final Color _surfaceColor = const Color(0xFF1E1E1E); // Surface color
  final Color _textColor = const Color(0xFFE0E0E0);    // Light text
  final Color _secondaryTextColor = const Color(0xFFB0B0B0); // Secondary text

  // Priority colors
  final Map<String, Color> _priorityColors = {
    'Low': const Color(0xFF183A37),
    'Medium': const Color(0xFF004643),
    'High': const Color(0xFFA23B72),
  };

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animation
    _animationController.forward();

    // Initialize values from existing task if editing
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _category = widget.task!.category;
      _priority = widget.task!.priority;
      _time = widget.task!.time;
      _completed = widget.task!.completed;
    }

    // Set system UI overlay style to match our dark theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle for bottom sheet
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _secondaryTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.task == null ? Icons.add_task : Icons.edit,
                        color: _primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.task == null ? 'Add Task' : 'Edit Task',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Task title field
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(color: _textColor),
                  cursorColor: _primaryColor,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: GoogleFonts.poppins(color: _secondaryTextColor),
                    hintText: 'What needs to be done?',
                    hintStyle: GoogleFonts.poppins(color: _secondaryTextColor.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.task_alt, color: _primaryColor.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _surfaceColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: _surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // Category dropdown with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: _surfaceColor,
                    icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                    style: GoogleFonts.poppins(color: _textColor),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: GoogleFonts.poppins(color: _secondaryTextColor),
                      prefixIcon: Icon(Icons.category, color: _accentColor.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _surfaceColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _accentColor, width: 2),
                      ),
                      filled: true,
                      fillColor: _surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: widget.categories
                        .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: GoogleFonts.poppins())
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Priority dropdown with color indicators
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    dropdownColor: _surfaceColor,
                    icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                    style: GoogleFonts.poppins(color: _textColor),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: GoogleFonts.poppins(color: _secondaryTextColor),
                      prefixIcon: Icon(Icons.flag, color: _priorityColors[_priority]!),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _surfaceColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _priorityColors[_priority]!, width: 2),
                      ),
                      filled: true,
                      fillColor: _surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map((pri) => DropdownMenuItem(
                      value: pri,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _priorityColors[pri],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(pri, style: GoogleFonts.poppins()),
                        ],
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Time selector with custom styling
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _time != null
                            ? TimeOfDay(hour: _time!.hour, minute: _time!.minute)
                            : TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: _primaryColor,
                                onPrimary: Colors.white,
                                surface: _surfaceColor,
                                onSurface: _textColor,
                              ), dialogTheme: DialogThemeData(backgroundColor: _backgroundColor),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _time = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _time != null ? _primaryColor.withOpacity(0.7) : _surfaceColor,
                          width: _time != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: _time != null ? _primaryColor : _secondaryTextColor,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _time != null
                                ? 'Time: ${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
                                : 'Select Time',
                            style: GoogleFonts.poppins(
                              color: _time != null ? _textColor : _secondaryTextColor,
                              fontWeight: _time != null ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: _secondaryTextColor.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Completed checkbox with custom styling
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CheckboxListTile(
                      title: Text('Completed',
                        style: GoogleFonts.poppins(
                          color: _textColor,
                          decoration: _completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      value: _completed,
                      onChanged: (value) {
                        setState(() {
                          _completed = value!;
                        });
                        // Add haptic feedback
                        HapticFeedback.lightImpact();
                      },
                      activeColor: _accentColor,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: Icon(
                        _completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: _completed ? _accentColor : _secondaryTextColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save button with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty) return;

                        // Add haptic feedback
                        HapticFeedback.mediumImpact();

                        final task = TaskModel(
                          id: widget.task?.id ?? '',
                          title: _titleController.text.trim(),
                          category: _category,
                          time: _time,
                          priority: _priority,
                          completed: _completed,
                          order: widget.task?.order ?? 0,
                        );

                        // Run a quick "save" animation then save and close
                        _animationController.reverse().then((_) {
                          widget.onSave(task);
                          Navigator.pop(context);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Save Task',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel button - text only
                if (widget.task != null)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _animationController.reverse().then((_) {
                          Navigator.pop(context);
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: _secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}