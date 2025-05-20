import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';
import 'package:timetide/features/checklist/providers/checklist_provider.dart';
import '../widgets/task_input_modal.dart';
import 'dart:io';
import 'dart:ui';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ChecklistBuilderScreen extends StatefulWidget {
  const ChecklistBuilderScreen({super.key});

  @override
  State<ChecklistBuilderScreen> createState() => _ChecklistBuilderScreenState();
}

class _ChecklistBuilderScreenState extends State<ChecklistBuilderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    final checklistProvider =
        Provider.of<ChecklistProvider>(context, listen: false);
    _tabController = TabController(
      length: checklistProvider.categories.length,
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _showTaskInputModal(BuildContext context, String category,
      {TaskModel? task}) {
    final checklistProvider =
        Provider.of<ChecklistProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Animate FAB out
    _fabAnimationController.reverse();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
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
                // Handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Modal title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    task == null ? 'Add New Task' : 'Edit Task',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Modal content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: TaskInputModal(
                      task: task,
                      categories: checklistProvider.categories,
                      onSave: (newTask) {
                        if (task == null) {
                          checklistProvider.addTask(
                              authProvider.user!.id, newTask);
                        } else {
                          checklistProvider.updateTask(
                              authProvider.user!.id, newTask);
                        }
                        // Animate FAB back in when modal closes
                        _fabAnimationController.forward();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      // Ensure FAB is animated back in when modal is dismissed
      _fabAnimationController.forward();
    });
  }

  Future<String> savePdf(List<int> pdfBytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final checklistProvider = Provider.of<ChecklistProvider>(context);

    // Ensure FAB is shown when screen loads
    _fabAnimationController.forward();

    return Scaffold(
      backgroundColor: const Color(0xFF004643),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Task Planner',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          // Export PDF button with animated tooltip
          Tooltip(
            message: 'Export PDF',
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF613DC1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                onPressed: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFA23B72)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Generating PDF...',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  // Generate PDF
                  final pdfBytes = await checklistProvider
                      .generateChecklistPdf(authProvider.user!.id);
                  final path = await savePdf(pdfBytes, 'checklist.pdf');

                  // Dismiss loading dialog
                  Navigator.pop(context);

                  // Open file
                  await OpenFile.open(path);
                },
              ),
            ),
          ).animate().fade().scale(
                delay: 300.milliseconds,
                duration: 400.milliseconds,
                curve: Curves.easeOutBack,
              ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: const Color(0xFF613DC1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF613DC1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              dividerHeight: 0,
              tabs: checklistProvider.categories
                  .map((category) => Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004643), Color(0xFF183A37)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PatternBackground(
                  color: Colors.white.withOpacity(0.02),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: TabBarView(
                controller: _tabController,
                children: checklistProvider.categories.map((category) {
                  return StreamBuilder<List<TaskModel>>(
                    stream: checklistProvider.getTasks(
                        authProvider.user!.id, category),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }

                      if (!snapshot.hasData) {
                        return _buildLoadingState();
                      }

                      final tasks = snapshot.data!;

                      if (tasks.isEmpty) {
                        return _buildEmptyState(category);
                      }

                      return _buildTaskList(
                          tasks, category, authProvider, checklistProvider);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton.extended(
          onPressed: () => _showTaskInputModal(
            context,
            checklistProvider.categories[_tabController.index],
          ),
          backgroundColor: const Color(0xFFA23B72),
          label: Row(
            children: [
              const Icon(Icons.add),
              const SizedBox(width: 4),
              Text(
                'New Task',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          elevation: 6,
        )
            .animate()
            .fade(
              duration: 400.milliseconds,
            )
            .slideY(
              begin: 1,
              duration: 500.milliseconds,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFA23B72),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh action
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF613DC1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA23B72)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading tasks...',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ).animate().fade(duration: 600.milliseconds),
            const SizedBox(height: 24),
            Text(
              'No tasks in $category yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(delay: 200.milliseconds, duration: 400.milliseconds),
            const SizedBox(height: 16),
            Text(
              'Tap the + button to add your first task',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(delay: 400.milliseconds, duration: 400.milliseconds),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(
    List<TaskModel> tasks,
    String category,
    AuthProvider authProvider,
    ChecklistProvider checklistProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
      child: ReorderableListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            key: ValueKey(task.id),
            task: task,
            onEdit: () => _showTaskInputModal(context, category, task: task),
            onDelete: () {
              // Animate item out before deletion
              final overlayEntry = OverlayEntry(
                builder: (context) => Positioned(
                  left: 16,
                  right: 16,
                  top: MediaQuery.of(context).padding.top + 100 + (index * 90),
                  child: TaskCard(
                    key: ValueKey('${task.id}_overlay'),
                    task: task,
                    onEdit: () {},
                    onDelete: () {},
                  ).animate().slideX(
                        begin: 0,
                        end: 1.5,
                        curve: Curves.easeInBack,
                        duration: 300.milliseconds,
                      ),
                ),
              );

              // Show overlay animation
              Overlay.of(context).insert(overlayEntry);

              // Delete after animation
              Future.delayed(const Duration(milliseconds: 300), () {
                overlayEntry.remove();
                checklistProvider.deleteTask(authProvider.user!.id, task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${task.title} deleted',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF1A1A1A),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: const Color(0xFFA23B72),
                      onPressed: () {
                        // Add undo functionality here
                        checklistProvider.addTask(authProvider.user!.id, task);
                      },
                    ),
                  ),
                );
              });
            },
          );
        },
        onReorder: (oldIndex, newIndex) {
          checklistProvider.reorderTasks(
            authProvider.user!.id,
            category,
            tasks,
            oldIndex: oldIndex,
            newIndex: newIndex,
          );
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final double scale = Tween<double>(begin: 1, end: 1.05)
                  .animate(CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0, 0.5, curve: Curves.easeOut),
                    reverseCurve: const Interval(0.5, 1, curve: Curves.easeIn),
                  ))
                  .value;

              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    required Key key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priorityColors = {
      'High': const Color(0xFFE57373),
      'Medium': const Color(0xFFFFB74D),
      'Low': const Color(0xFF81C784),
    };

    final priorityColor =
        priorityColors[task.priority] ?? const Color(0xFF81C784);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF222222),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            splashColor: priorityColor.withOpacity(0.1),
            highlightColor: priorityColor.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: priorityColor,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Task info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Priority & Time
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                task.priority,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: priorityColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (task.time != null) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.time!.toString().substring(11, 16),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                        visualDensity: VisualDensity.compact,
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white70,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 300.milliseconds).slideX(
        begin: 0.1,
        end: 0,
        duration: 300.milliseconds,
        curve: Curves.easeOutCubic);
  }
}

class PatternBackground extends CustomPainter {
  final Color color;

  PatternBackground({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 30.0;
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

// Note: This implementation assumes you're using the flutter_animate package
// for animations. If not already in your dependencies, you'll need to add:
// flutter_animate: ^[latest_version]
// import 'dart:ui'; // Add this import for ImageFilter
