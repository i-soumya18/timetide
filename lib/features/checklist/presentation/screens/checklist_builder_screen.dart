import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:io';
import '../../authentication/providers/auth_provider.dart';
import '../../home/data/models/task_model.dart';
import '../providers/checklist_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_input_modal.dart';

class ChecklistBuilderScreen extends StatefulWidget {
  const ChecklistBuilderScreen({super.key});

  @override
  State<ChecklistBuilderScreen> createState() => _ChecklistBuilderScreenState();
}

class _ChecklistBuilderScreenState extends State<ChecklistBuilderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final checklistProvider = Provider.of<ChecklistProvider>(context, listen: false);
    _tabController = TabController(length: checklistProvider.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, Color> _categoryColors = {
    'Work': const Color(0xFFFFB703),
    'Health': const Color(0xFFF72585),
    'Errands': const Color(0xFF2A9D8F),
    'Personal': const Color(0xFFFB8500),
  };

  void _showTaskModal(BuildContext context, {TaskModel? task}) {
    final checklistProvider = Provider.of<ChecklistProvider>(context, listen: false);
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
          child: TaskInputModal(
            task: task,
            categories: checklistProvider.categories,
            onSave: (newTask) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (task == null) {
                checklistProvider.addTask(authProvider.user!.id, newTask);
              } else {
                checklistProvider.updateTask(authProvider.user!.id, newTask);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final checklistProvider = Provider.of<ChecklistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checklist Builder',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF219EBC),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          indicatorColor: const Color(0xFFFFB703),
          labelColor: const Color(0xFFFFB703),
          unselectedLabelColor: Colors.white70,
          tabs: checklistProvider.categories
              .map((category) => Tab(text: category))
              .toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () async {
              try {
                final pdfBytes = await checklistProvider.generateChecklistPdf(authProvider.user!.id);
                final dir = await getApplicationDocumentsDirectory();
                final file = File('${dir.path}/checklist_${DateTime.now().toIso8601String()}.pdf');
                await file.write(pdfBytes);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF saved to ${file.path}')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error generating PDF: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8ECAE6), Color(0xFF219EBC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: checklistProvider.categories.map((category) {
            return StreamBuilder<List<TaskModel>>(
              stream: checklistProvider.getTasks(authProvider.user!.id, category),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!;
                return ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final updatedTasks = List<TaskModel>.from(tasks);
                    final task = updatedTasks.removeAt(oldIndex);
                    updatedTasks.insert(newIndex, task);
                    checklistProvider.reorderTasks(authProvider.user!.id, category, updatedTasks);
                  },
                  children: tasks.map((task) {
                    return Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        checklistProvider.deleteTask(task.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${task.title} deleted')),
                        );
                      },
                      child: TaskCard(
                        task: task,
                        categoryColor: _categoryColors[category] ?? const Color(0xFF219EBC),
                        onEdit: () => _showTaskModal(context, task: task),
                        onDelete: () {
                          checklistProvider.deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${task.title} deleted')),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskModal(context),
        backgroundColor: const Color(0xFFFFB703),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}