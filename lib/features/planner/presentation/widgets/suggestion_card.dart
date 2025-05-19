import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/colors.dart';
import 'task_edit_modal.dart';

class SuggestionCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onAdd;
  final Function(Map<String, dynamic>) onModify;

  const SuggestionCard({
    super.key,
    required this.task,
    required this.onAdd,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'] ?? 'Untitled',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${task['category'] ?? 'Unknown'}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              'Priority: ${task['priority'] ?? 'Medium'}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            if (task['time'] != null)
              Text(
                'Time: ${task['time']}',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        maxChildSize: 0.9,
                        minChildSize: 0.5,
                        expand: false,
                        builder: (context, scrollController) => SingleChildScrollView(
                          controller: scrollController,
                          child: TaskEditModal(
                            task: task,
                            categories: ['Work', 'Health', 'Errands', 'Personal'],
                            onSave: (updatedTask) {
                              onModify(updatedTask);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Modify',
                    style: GoogleFonts.poppins(color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Add to Checklist',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}