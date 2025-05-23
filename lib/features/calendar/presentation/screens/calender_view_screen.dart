import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/calendar/data/models/calendar_event_model.dart';
import 'package:timetide/features/calendar/providers/calendar_provider.dart';
import 'package:timetide/features/calendar/widgets/calendar_widgets.dart';
import 'package:timetide/core/colors.dart';
import 'package:timetide/features/home/screens/app_drawer.dart';
import 'dart:ui';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddEventModal(BuildContext context) {
    // Placeholder for adding new event
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                const SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.textMedium,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Add Event',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                          // Add form fields for event creation
                        ],
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final calendarProvider = Provider.of<CalendarProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      drawer: AppDrawer(authProvider: authProvider),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AppBar(
            backgroundColor: AppColors.background.withOpacity(0.8),
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: AppColors.background.withOpacity(0.5),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textLight, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Open menu',
            ),
            title: Text(
              'Calendar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
              textScaler: const TextScaler.linear(1.0),
            ),
            actions: [
              Semantics(
                label: 'User Profile',
                child: IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        authProvider.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.poppins(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.background, AppColors.secondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: PatternBackground(color: AppColors.textLight.withOpacity(0.02)),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(20 * (1 - _fadeAnimation.value), 0),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: CalendarWidget(
                          focusedDate: calendarProvider.focusedDate,
                          selectedDate: calendarProvider.selectedDate,
                          events: [], // Populated by StreamBuilder
                          onDateSelected: (date) {
                            calendarProvider.setSelectedDate(date);
                            calendarProvider.setFocusedDate(date);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(20 * (1 - _fadeAnimation.value), 0),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          'Events on ${calendarProvider.selectedDate.day} ${_monthName(calendarProvider.selectedDate.month)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<CalendarEventModel>>(
                        stream: calendarProvider.getEvents(authProvider.user!.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                                strokeWidth: 3,
                              ),
                            );
                          }
                          final events = snapshot.data!.where((event) =>
                          event.date.year == calendarProvider.selectedDate.year &&
                              event.date.month == calendarProvider.selectedDate.month &&
                              event.date.day == calendarProvider.selectedDate.day).toList();
                          if (events.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: AppColors.textMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No events on this date.',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textLight,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    textScaler: const TextScaler.linear(1.0),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return AnimatedBuilder(
                                animation: _fadeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(20 * (1 - _fadeAnimation.value), 0),
                                    child: Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: EventCard(
                                  event: event,
                                  onEdit: () {
                                    // Placeholder for edit functionality
                                  },
                                  onDelete: () {
                                    HapticFeedback.mediumImpact();
                                    calendarProvider.deleteEvent(authProvider.user!.id, event.id);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _fadeAnimation.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: FloatingActionButton(
          onPressed: () => _showAddEventModal(context),
          backgroundColor: AppColors.accent,
          elevation: 6,
          child: const Icon(Icons.add, color: AppColors.textLight, size: 24),
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 56 * (1 - _fadeAnimation.value)),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: BottomNavigationBar(
                backgroundColor: AppColors.secondary,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textLight.withOpacity(0.7),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                type: BottomNavigationBarType.fixed,
                currentIndex: 1, // Planner tab for Calendar
                onTap: (index) {
                  HapticFeedback.lightImpact();
                  switch (index) {
                    case 0:
                      Navigator.pushNamed(context, '/home');
                      break;
                    case 1:
                      break; // Already on Calendar
                    case 2:
                      Navigator.pushNamed(context, '/checklist');
                      break;
                    case 3:
                      Navigator.pushNamed(context, '/reminders');
                      break;
                    case 4:
                      Navigator.pushNamed(context, '/health');
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: 24),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today, size: 24),
                    label: 'Planner',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.checklist_rounded, size: 24),
                    label: 'Checklist',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_rounded, size: 24),
                    label: 'Reminders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite, size: 24),
                    label: 'Health',
                  ),
                ],
              ),
            ),
          );
        },
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

class PatternBackground extends CustomPainter {
  final Color color;

  PatternBackground({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;
    const dotSize = 1.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.round;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}