import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';

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

class _TaskInputModalState extends State<TaskInputModal> {
  final _titleController = TextEditingController();
  String _category = 'Work';
  String _priority = 'Medium';
  DateTime? _time;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _category = widget.task!.category;
      _priority = widget.task!.priority;
      _time = widget.task!.time;
      _completed = widget.task!.completed;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task == null ? 'Add Task' : 'Edit Task',
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(
              labelText: 'Category',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
            items: widget.categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
            items: ['Low', 'Medium', 'High']
                .map((pri) => DropdownMenuItem(value: pri, child: Text(pri)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _priority = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
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
            child: Text(
              _time != null
                  ? 'Time: ${_time!.toString().substring(11, 16)}'
                  : 'Select Time',
              style: GoogleFonts.poppins(color: const Color(0xFF219EBC)),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Completed'),
            value: _completed,
            onChanged: (value) {
              setState(() {
                _completed = value!;
              });
            },
            activeColor: const Color(0xFFFFB703),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty) return;
              final task = TaskModel(
                id: widget.task?.id ?? '',
                title: _titleController.text.trim(),
                category: _category,
                time: _time,
                priority: _priority,
                completed: _completed,
                order: widget.task?.order ?? 0,
              );
              widget.onSave(task);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB703),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
