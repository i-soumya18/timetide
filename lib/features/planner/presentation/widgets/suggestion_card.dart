import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/core/colors.dart';
import 'task_edit_modal.dart';

/// A card widget for displaying AI-suggested tasks in the planner interface.
/// Supports task selection, modification, and addition to the checklist with animations and adaptive styling.
class SuggestionCard extends StatefulWidget {
  final Map<String, dynamic> task;
  final bool isSelected;
  final bool isFinalized;
  final VoidCallback onAdd;
  final Function(Map<String, dynamic>)? onModify;
  final Function(bool)? onSelectionChanged;

  const SuggestionCard({
    super.key,
    required this.task,
    required this.isSelected,
    required this.isFinalized,
    required this.onAdd,
    this.onModify,
    this.onSelectionChanged,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for scale effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Define scale animation for card appearance
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog before adding a task to the checklist.
  void _confirmAddTask(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add to Checklist',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        content: Text(
          'Add "${widget.task['title']}" to your checklist?',
          style: GoogleFonts.poppins(
            color: AppColors.textMedium,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textDark),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAdd();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: AppColors.success.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    '${widget.task['title']} added to checklist',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isDarkMode ? AppColors.backgroundMedium : Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isFinalized
                  ? [
                      isDarkMode
                          ? AppColors.backgroundDark.withOpacity(0.7)
                          : Colors.grey[200]!.withOpacity(0.7),
                      isDarkMode
                          ? AppColors.backgroundMedium.withOpacity(0.7)
                          : Colors.grey[300]!.withOpacity(0.7),
                    ]
                  : [
                      const Color(0xFF613DC1)
                          .withOpacity(0.6), // Deep Indigo/Violet
                      const Color(0xFF7752E3).withOpacity(0.5), // Royal Purple
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.task['title'] ?? 'Untitled',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isFinalized
                              ? AppColors.textMedium
                              : Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!widget.isFinalized)
                      Tooltip(
                        message: 'Select for finalization',
                        child: Checkbox(
                          value: widget.isSelected,
                          onChanged: widget.onSelectionChanged != null
                              ? (value) {
                                  HapticFeedback.selectionClick();
                                  widget.onSelectionChanged!(value ?? false);
                                }
                              : null,
                          activeColor: const Color(0xFF613DC1), // Deep Indigo
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTaskDetail(
                  icon: Icons.category_rounded,
                  label: 'Category',
                  value: widget.task['category'] ?? 'Unknown',
                  isFinalized: widget.isFinalized,
                  isDarkMode: isDarkMode,
                ),
                _buildTaskDetail(
                  icon: Icons.priority_high_rounded,
                  label: 'Priority',
                  value: widget.task['priority'] ?? 'Medium',
                  isFinalized: widget.isFinalized,
                  isDarkMode: isDarkMode,
                ),
                if (widget.task['time'] != null)
                  _buildTaskDetail(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: widget.task['time'] as String,
                    isFinalized: widget.isFinalized,
                    isDarkMode: isDarkMode,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!widget.isFinalized && widget.onModify != null)
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.backgroundDark,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                            ),
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.7,
                              maxChildSize: 0.9,
                              minChildSize: 0.5,
                              expand: false,
                              builder: (context, scrollController) =>
                                  SingleChildScrollView(
                                controller: scrollController,
                                child: TaskEditModal(
                                  task: widget.task,
                                  categories: const [
                                    'Work',
                                    'Health',
                                    'Errands',
                                    'Personal'
                                  ],
                                  onSave: (updatedTask) {
                                    widget.onModify!(updatedTask);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        backgroundColor:
                                            AppColors.success.withOpacity(0.9),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        content: Text(
                                          '${updatedTask['title']} modified',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Modify',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.isFinalized
                          ? null
                          : () => _confirmAddTask(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isFinalized
                            ? AppColors.textDark.withOpacity(0.5)
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: widget.isFinalized ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Add to Checklist',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.isFinalized)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.success.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Finalized',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.success.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a task detail row with icon, label, and value.
  Widget _buildTaskDetail({
    required IconData icon,
    required String label,
    required String value,
    required bool isFinalized,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isFinalized
                ? AppColors.textMedium.withOpacity(0.7)
                : Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isFinalized
                    ? AppColors.textMedium.withOpacity(0.7)
                    : Colors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
