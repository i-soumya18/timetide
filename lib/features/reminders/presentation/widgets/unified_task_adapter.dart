import 'package:flutter/material.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';
import 'package:timetide/features/checklist/presentation/widgets/task_input_modal.dart';
import 'package:timetide/models/unified_task_model.dart';

/// This widget adapts the UnifiedTaskModel to work with the existing TaskInputModal
class UnifiedTaskInputAdapter extends StatelessWidget {
  final UnifiedTaskModel? unifiedTask;
  final List<String> categories;
  final Function(UnifiedTaskModel) onSave;

  const UnifiedTaskInputAdapter({
    super.key,
    this.unifiedTask,
    required this.categories,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // Convert UnifiedTaskModel to TaskModel for the input modal
    final TaskModel? adaptedTask = unifiedTask != null
        ? TaskModel(
            id: unifiedTask!.id,
            title: unifiedTask!.title,
            category: unifiedTask!.category,
            time: unifiedTask!.time,
            priority: unifiedTask!.priority,
            completed: unifiedTask!.completed,
            order: unifiedTask!.order,
          )
        : null;

    return TaskInputModal(
      task: adaptedTask,
      categories: categories,
      onSave: (taskModel) {
        // Convert back to UnifiedTaskModel when saving
        onSave(
          UnifiedTaskModel(
            id: taskModel.id,
            title: taskModel.title,
            category: taskModel.category,
            time: taskModel.time,
            priority: taskModel.priority,
            completed: taskModel.completed,
            order: taskModel.order,
            userId: unifiedTask?.userId,
          ),
        );
      },
    );
  }
}
