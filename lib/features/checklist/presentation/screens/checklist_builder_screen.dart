import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/checklist/data/models/task_model.dart';
import 'package:timetide/features/checklist/providers/checklist_provider.dart';
import '../widgets/task_input_modal.dart';
import 'package:timetide/core/colors.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ChecklistBuilderScreen extends StatefulWidget {
  const ChecklistBuilderScreen({super.key});

  @override
  State<ChecklistBuilderScreen> createState() => _ChecklistBuilderScreenState();
}

class _ChecklistBuilderScreenState extends State<ChecklistBuilderScreen> {
  void _showTaskInputModal(BuildContext context, String category,
      {TaskModel? task}) {
    final checklistProvider =
        Provider.of<ChecklistProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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

    return DefaultTabController(
      length: checklistProvider.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Checklist Builder',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            tabs: checklistProvider.categories
                .map((category) => Tab(text: category))
                .toList(),
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                final pdfBytes = await checklistProvider
                    .generateChecklistPdf(authProvider.user!.id);
                final path = await savePdf(pdfBytes, 'checklist.pdf');
                await OpenFile.open(path);
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: checklistProvider.categories.map((category) {
              return StreamBuilder<List<TaskModel>>(
                stream:
                    checklistProvider.getTasks(authProvider.user!.id, category),
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
                      checklistProvider.reorderTasks(
                        authProvider.user!.id,
                        category,
                        tasks,
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                      );
                    },
                    children: tasks.map((task) {
                      return Card(
                        key: ValueKey(task.id),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Priority: ${task.priority}${task.time != null ? ' • Time: ${task.time!.toString().substring(11, 16)}' : ''}',
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showTaskInputModal(
                                    context, category,
                                    task: task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  checklistProvider.deleteTask(
                                      authProvider.user?.id ?? '', task.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('${task.title} deleted')),
                                  );
                                },
                              ),
                            ],
                          ),
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
          onPressed: () =>
              _showTaskInputModal(context, checklistProvider.categories.first),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
