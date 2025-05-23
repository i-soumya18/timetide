import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/features/calendar/data/models/calendar_event_model.dart';
import 'package:timetide/core/colors.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDate;
  final DateTime selectedDate;
  final List<CalendarEventModel> events;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarWidget({
    super.key,
    required this.focusedDate,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDayOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstDayWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedDate.year, focusedDate.month, day);
      final hasEvents = events.any((event) =>
      event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day);
      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selectedDate.day == day &&
                  selectedDate.month == focusedDate.month
                  ? AppColors.accent
                  : hasEvents
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$day',
                style: GoogleFonts.poppins(
                  color: selectedDate.day == day &&
                      selectedDate.month == focusedDate.month
                      ? AppColors.textLight
                      : AppColors.textLight.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(focusedDate.month)} ${focusedDate.year}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.textLight),
                    onPressed: () => onDateSelected(DateTime(
                        focusedDate.year, focusedDate.month - 1, 1)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.textLight),
                    onPressed: () => onDateSelected(DateTime(
                        focusedDate.year, focusedDate.month + 1, 1)),
                  ),
                ],
              ),
            ],
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1,
            children: [
              for (var day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Center(
                  child: Text(
                    day,
                    style: GoogleFonts.poppins(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ...dayWidgets,
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class EventCard extends StatelessWidget {
  final CalendarEventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            event.type == CalendarEventType.task
                ? Icons.check_circle
                : event.type == CalendarEventType.habit
                ? Icons.favorite
                : Icons.notifications,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  event.type.toString().split('.').last,
                  style: GoogleFonts.poppins(
                    color: AppColors.textMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textLight, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}