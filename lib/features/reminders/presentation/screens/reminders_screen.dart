import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/checklist/providers/checklist_provider.dart';
import 'package:timetide/features/health_habits/presentation/widgets/habit_input_modal.dart';
import 'package:timetide/features/health_habits/providers/health_habits_provider.dart';
import 'package:timetide/features/reminders/data/models/reminder_model.dart';
import 'package:timetide/features/reminders/providers/reminders_provider.dart';
import 'package:timetide/models/unified_task_model.dart';
import '../../../health_habits/data/models/habit_model.dart';
import '../widgets/reminder_card.dart';
import '../widgets/unified_task_adapter.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Premium Color Palette - Dark Pink & Black
  static const Color _primaryDark = Color(0xFF0A0A0B);
  static const Color _secondaryDark = Color(0xFF1A1A1B);
  static const Color _accentPink = Color(0xFF921D67);
  static const Color _accentPinkLight = Color(0xFFF06292);
  static const Color _accentPinkDark = Color(0xFFAD1457);
  static const Color _surfaceDark = Color(0xFF212121);
  static const Color _cardDark = Color(0xFF2A2A2B);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFB0B0B0);
  static const Color _divider = Color(0xFF3A3A3B);

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    final provider = Provider.of<RemindersProvider>(context, listen: false);
    provider.initializeNotifications();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showEditModal(BuildContext context,
      {UnifiedTaskModel? task, HabitModel? habit}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final checklistProvider =
    Provider.of<ChecklistProvider>(context, listen: false);
    final healthHabitsProvider =
    Provider.of<HealthHabitsProvider>(context, listen: false);

    if (task != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  // Modal handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: UnifiedTaskInputAdapter(
                        unifiedTask: task,
                        categories: checklistProvider.categories,
                        onSave: (newTask) {
                          checklistProvider.updateTaskFromUnified(
                              authProvider.user!.id, newTask);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (habit != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.8,
            minChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  // Modal handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: HabitInputModal(
                        habit: habit,
                        onSave: (newHabit) {
                          healthHabitsProvider.updateHabit(
                              authProvider.user!.id, newHabit);
                          Navigator.pop(context);
                        },
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

  Widget _buildPremiumAppBar() {
    return Container(
      height: MediaQuery.of(context).padding.top + kToolbarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentPinkDark.withOpacity(0.9),
            _accentPink.withOpacity(0.8),
            _accentPinkLight.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentPink.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Premium back button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title with premium styling
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reminders',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Stay on track with your tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Premium notification indicator
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Handle notification settings
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accentPink.withOpacity(0.2),
                      _accentPinkLight.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: _accentPink.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 60,
                  color: _accentPink.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Active Reminders',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create tasks and habits to see\nyour reminders here',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final remindersProvider = Provider.of<RemindersProvider>(context);

    return Scaffold(
      backgroundColor: _primaryDark,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top + kToolbarHeight),
        child: _buildPremiumAppBar(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A0A0B), // Deep black
              const Color(0xFF50014E), // Dark pink-black blend
              const Color(0xFF38062A), // Rich dark pink-gray
              const Color(0xFF0F0A0B), // Back to deep black
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: StreamBuilder<List<ReminderModel>>(
          stream: remindersProvider.getReminders(authProvider.user!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.shade300,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(_accentPink),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading reminders...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final reminders = snapshot.data!;
            if (reminders.isEmpty) {
              return _buildEmptyState();
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _accentPink.withOpacity(0.2),
                                    _accentPinkLight.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _accentPink.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${reminders.length} Active',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _accentPink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final reminder = reminders[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: FutureBuilder(
                                        future: reminder.type == 'task'
                                            ? remindersProvider.getTask(reminder.referenceId)
                                            : remindersProvider.getHabit(reminder.referenceId),
                                        builder: (context, AsyncSnapshot snapshot) {
                                          final task = reminder.type == 'task'
                                              ? snapshot.data as UnifiedTaskModel?
                                              : null;
                                          final habit = reminder.type == 'habit'
                                              ? snapshot.data as HabitModel?
                                              : null;

                                          return ReminderCard(
                                            reminder: reminder,
                                            task: task,
                                            habit: habit,
                                            onSnooze10Min: () {
                                              remindersProvider.snoozeReminder(
                                                  reminder.id, const Duration(minutes: 10));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${reminder.type} snoozed for 10 minutes',
                                                    style: GoogleFonts.poppins(color: Colors.white),
                                                  ),
                                                  backgroundColor: _accentPink,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                            },
                                            onSnooze1Hour: () {
                                              remindersProvider.snoozeReminder(
                                                  reminder.id, const Duration(hours: 1));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${reminder.type} snoozed for 1 hour',
                                                    style: GoogleFonts.poppins(color: Colors.white),
                                                  ),
                                                  backgroundColor: _accentPink,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                            },
                                            onDismiss: () {
                                              remindersProvider.dismissReminder(reminder.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${reminder.type} dismissed',
                                                    style: GoogleFonts.poppins(color: Colors.white),
                                                  ),
                                                  backgroundColor: _surfaceDark,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                            },
                                            onEdit: () => _showEditModal(
                                              context,
                                              task: task,
                                              habit: habit,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: reminders.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}