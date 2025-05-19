import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit_model.dart';

class HabitInputModal extends StatefulWidget {
  final HabitModel? habit;
  final Function(HabitModel) onSave;

  const HabitInputModal({
    super.key,
    this.habit,
    required this.onSave,
  });

  @override
  State<HabitInputModal> createState() => _HabitInputModalState();
}

class _HabitInputModalState extends State<HabitInputModal> {
  final _nameController = TextEditingController();
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _reminderTime = widget.habit!.reminderTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            widget.habit == null ? 'Add Habit' : 'Edit Habit',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Habit Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime ?? TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  _reminderTime = picked;
                });
              }
            },
            child: Text(
              _reminderTime != null
                  ? 'Reminder: ${_reminderTime!.format(context)}'
                  : 'Set Reminder',
              style: GoogleFonts.poppins(color: const Color(0xFF219EBC)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) return;
              final habit = HabitModel(
                id: widget.habit?.id ?? '',
                userId: '',
                name: _nameController.text.trim(),
                reminderTime: _reminderTime,
                streak: widget.habit?.streak ?? 0,
              );
              widget.onSave(habit);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB703),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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