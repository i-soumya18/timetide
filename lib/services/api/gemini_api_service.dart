import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timetide/core/config/app_config.dart';
import 'package:timetide/core/services/logging_service.dart';
import 'package:timetide/models/task_model.dart';

class GeminiApiService {
  static final GeminiApiService _instance = GeminiApiService._internal();
  factory GeminiApiService() => _instance;
  GeminiApiService._internal();

  final LoggingService _logger = LoggingService();

  // Base URL for the Gemini API
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  // Generate a daily plan
  Future<List<TaskModel>> generateDailyPlan({
    required String userId,
    required DateTime date,
    required List<String> userGoals,
    required List<TaskModel> existingTasks,
    String? additionalContext,
  }) async {
    try {
      final response = await _sendRequest(
        prompt: _buildDailyPlanPrompt(
          date: date,
          userGoals: userGoals,
          existingTasks: existingTasks,
          additionalContext: additionalContext,
        ),
      );

      return _parseTasks(response, userId, date);
    } catch (e) {
      _logger.error('Error generating daily plan', error: e);
      rethrow;
    }
  }

  // Generate a weekly plan
  Future<Map<DateTime, List<TaskModel>>> generateWeeklyPlan({
    required String userId,
    required DateTime startDate,
    required List<String> userGoals,
    required Map<DateTime, List<TaskModel>> existingTasks,
    String? additionalContext,
  }) async {
    try {
      final response = await _sendRequest(
        prompt: _buildWeeklyPlanPrompt(
          startDate: startDate,
          userGoals: userGoals,
          existingTasks: existingTasks,
          additionalContext: additionalContext,
        ),
      );

      return _parseWeeklyTasks(response, userId, startDate);
    } catch (e) {
      _logger.error('Error generating weekly plan', error: e);
      rethrow;
    }
  }

  // Generate a checklist for a specific task
  Future<List<String>> generateTaskChecklist({
    required String taskTitle,
    required String? taskDescription,
  }) async {
    try {
      final response = await _sendRequest(
        prompt: _buildChecklistPrompt(
          taskTitle: taskTitle,
          taskDescription: taskDescription,
        ),
      );

      return _parseChecklist(response);
    } catch (e) {
      _logger.error('Error generating task checklist', error: e);
      rethrow;
    }
  }

  // Optimize a user's schedule
  Future<List<TaskModel>> optimizeSchedule({
    required String userId,
    required DateTime date,
    required List<TaskModel> tasks,
    required TimeOfDay wakeUpTime,
    required TimeOfDay bedTime,
    String? additionalContext,
  }) async {
    try {
      final response = await _sendRequest(
        prompt: _buildOptimizeSchedulePrompt(
          date: date,
          tasks: tasks,
          wakeUpTime: wakeUpTime,
          bedTime: bedTime,
          additionalContext: additionalContext,
        ),
      );

      return _parseOptimizedTasks(response, userId, date, tasks);
    } catch (e) {
      _logger.error('Error optimizing schedule', error: e);
      rethrow;
    }
  }

  // Helper method to send requests to the Gemini API
  Future<String> _sendRequest({required String prompt}) async {
    try {
      final url = '$_baseUrl?key=${AppConfig.geminiApiKey}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        _logger.error('Gemini API Error: ${response.statusCode}',
            error: response.body);
        throw Exception(
            'Failed to get response from Gemini API: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final candidatesList = data['candidates'] as List;

      if (candidatesList.isEmpty) {
        _logger.error('Gemini API Error: No candidates returned');
        throw Exception('No response content from Gemini API');
      }

      final firstCandidate = candidatesList[0] as Map<String, dynamic>;
      final contentList = firstCandidate['content']['parts'] as List;

      if (contentList.isEmpty) {
        _logger.error('Gemini API Error: No content parts returned');
        throw Exception('Empty response content from Gemini API');
      }

      return contentList[0]['text'] as String;
    } catch (e) {
      _logger.error('Error sending request to Gemini API', error: e);
      rethrow;
    }
  }

  // Helper methods to build prompts for different scenarios
  String _buildDailyPlanPrompt({
    required DateTime date,
    required List<String> userGoals,
    required List<TaskModel> existingTasks,
    String? additionalContext,
  }) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final goalsString = userGoals.join(', ');
    final existingTasksString =
        existingTasks.map((task) => '- ${task.title}').join('\n');

    return '''
    You are an AI assistant that helps users plan their day. Create a well-structured daily plan for $dateString.

    User's goals: $goalsString
    
    ${existingTasks.isNotEmpty ? 'Existing tasks:\n$existingTasksString' : 'The user has no existing tasks for this day.'}
    
    ${additionalContext != null ? 'Additional context: $additionalContext' : ''}
    
    Create a balanced and realistic plan that aligns with the user's goals. Generate 5-8 tasks.
    Format your response as JSON with the following structure for each task:
    
    [
      {
        "title": "Task title",
        "description": "Task description",
        "priority": "high/medium/low",
        "dueTime": "HH:MM", 
        "category": "category name"
      }
    ]
    
    Only respond with the JSON array, nothing else.
    ''';
  }

  String _buildWeeklyPlanPrompt({
    required DateTime startDate,
    required List<String> userGoals,
    required Map<DateTime, List<TaskModel>> existingTasks,
    String? additionalContext,
  }) {
    final goalsString = userGoals.join(', ');

    String existingTasksString = '';
    existingTasks.forEach((date, tasks) {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final tasksString = tasks.map((task) => '- ${task.title}').join('\n');
      existingTasksString += '$dateString:\n$tasksString\n\n';
    });

    return '''
    You are an AI assistant that helps users plan their week. Create a well-structured weekly plan starting from ${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}.

    User's goals: $goalsString
    
    ${existingTasksString.isNotEmpty ? 'Existing tasks by day:\n$existingTasksString' : 'The user has no existing tasks for this week.'}
    
    ${additionalContext != null ? 'Additional context: $additionalContext' : ''}
    
    Create a balanced and realistic weekly plan that aligns with the user's goals. Distribute tasks appropriately throughout the week.
    Format your response as JSON with the following structure:
    
    {
      "2023-05-01": [
        {
          "title": "Task title",
          "description": "Task description",
          "priority": "high/medium/low",
          "dueTime": "HH:MM", 
          "category": "category name"
        }
      ],
      "2023-05-02": [
        // tasks for this day
      ]
      // and so on for each day of the week
    }
    
    Only respond with the JSON object, nothing else.
    ''';
  }

  String _buildChecklistPrompt({
    required String taskTitle,
    required String? taskDescription,
  }) {
    return '''
    You are an AI assistant that helps users break down tasks into actionable steps. Create a detailed checklist for the following task:
    
    Task: $taskTitle
    ${taskDescription != null ? 'Description: $taskDescription' : ''}
    
    Create a comprehensive checklist with 3-7 steps that would help the user complete this task effectively.
    Format your response as a JSON array of strings, where each string is a checklist item:
    
    [
      "Step 1: Do this first",
      "Step 2: Then do this",
      "Step 3: Finally do this"
    ]
    
    Only respond with the JSON array, nothing else.
    ''';
  }

  String _buildOptimizeSchedulePrompt({
    required DateTime date,
    required List<TaskModel> tasks,
    required TimeOfDay wakeUpTime,
    required TimeOfDay bedTime,
    String? additionalContext,
  }) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final tasksString = tasks.map((task) {
      final dueTimeString = task.dueDate != null
          ? '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}'
          : 'Not specified';
      final priorityString = task.priority.toString().split('.').last;
      return '- ${task.title} (Priority: $priorityString, Due time: $dueTimeString)';
    }).join('\n');

    return '''
    You are an AI assistant that helps users optimize their daily schedule. Reorganize and optimize the following tasks for $dateString.
    
    Wake up time: ${wakeUpTime.format24Hour()}
    Bed time: ${bedTime.format24Hour()}
    
    Tasks:
    $tasksString
    
    ${additionalContext != null ? 'Additional context: $additionalContext' : ''}
    
    Create an optimized schedule that:
    1. Respects the user's wake up and bed times
    2. Groups similar tasks together when possible
    3. Places high priority tasks at optimal times
    4. Includes short breaks between tasks
    5. Leaves some buffer time for unexpected events
    
    Format your response as JSON with the following structure:
    
    [
      {
        "title": "Task title",
        "description": "Task description",
        "priority": "high/medium/low",
        "dueTime": "HH:MM", 
        "category": "category name"
      }
    ]
    
    Only respond with the JSON array, nothing else.
    ''';
  }

  // Helper methods to parse responses
  List<TaskModel> _parseTasks(String response, String userId, DateTime date) {
    try {
      final List<dynamic> taskList = json.decode(response) as List<dynamic>;

      return taskList.map((taskData) {
        final task = taskData as Map<String, dynamic>;

        // Parse time string (HH:MM) into DateTime
        DateTime? dueDate;
        if (task.containsKey('dueTime') && task['dueTime'] != null) {
          final timeString = task['dueTime'] as String;
          final timeParts = timeString.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;
            dueDate = DateTime(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
            );
          }
        }

        // Parse priority
        TaskPriority priority;
        final priorityString =
            (task['priority'] as String?)?.toLowerCase() ?? 'medium';
        switch (priorityString) {
          case 'high':
            priority = TaskPriority.high;
            break;
          case 'low':
            priority = TaskPriority.low;
            break;
          case 'medium':
          default:
            priority = TaskPriority.medium;
            break;
        }

        return TaskModel(
          id: '${DateTime.now().millisecondsSinceEpoch}_${task['title']}',
          title: task['title'] as String,
          description: task['description'] as String?,
          createdAt: DateTime.now(),
          dueDate: dueDate,
          userId: userId,
          priority: priority,
          status: TaskStatus.pending,
          category: task['category'] as String?,
          isAiGenerated: true,
        );
      }).toList();
    } catch (e) {
      _logger.error('Error parsing tasks from Gemini response', error: e);
      return [];
    }
  }

  Map<DateTime, List<TaskModel>> _parseWeeklyTasks(
      String response, String userId, DateTime startDate) {
    try {
      final Map<String, dynamic> weekData =
          json.decode(response) as Map<String, dynamic>;
      final result = <DateTime, List<TaskModel>>{};

      weekData.forEach((dateString, tasksData) {
        final dateParts = dateString.split('-');
        if (dateParts.length == 3) {
          final year = int.tryParse(dateParts[0]) ?? startDate.year;
          final month = int.tryParse(dateParts[1]) ?? startDate.month;
          final day = int.tryParse(dateParts[2]) ?? startDate.day;
          final date = DateTime(year, month, day);

          final tasks = _parseTasks(json.encode(tasksData), userId, date);
          result[date] = tasks;
        }
      });

      return result;
    } catch (e) {
      _logger.error('Error parsing weekly tasks from Gemini response',
          error: e);
      return {};
    }
  }

  List<String> _parseChecklist(String response) {
    try {
      final List<dynamic> checklistItems =
          json.decode(response) as List<dynamic>;
      return checklistItems.map((item) => item as String).toList();
    } catch (e) {
      _logger.error('Error parsing checklist from Gemini response', error: e);
      return [];
    }
  }

  List<TaskModel> _parseOptimizedTasks(String response, String userId,
      DateTime date, List<TaskModel> originalTasks) {
    try {
      final List<dynamic> taskList = json.decode(response) as List<dynamic>;
      final Map<String, TaskModel> originalTaskMap = {
        for (var task in originalTasks) task.title: task
      };

      return taskList.map((taskData) {
        final task = taskData as Map<String, dynamic>;
        final title = task['title'] as String;

        // Check if this task already exists in the original tasks
        if (originalTaskMap.containsKey(title)) {
          final originalTask = originalTaskMap[title]!;

          // Parse time string (HH:MM) into DateTime
          DateTime? dueDate;
          if (task.containsKey('dueTime') && task['dueTime'] != null) {
            final timeString = task['dueTime'] as String;
            final timeParts = timeString.split(':');
            if (timeParts.length == 2) {
              final hour = int.tryParse(timeParts[0]) ?? 0;
              final minute = int.tryParse(timeParts[1]) ?? 0;
              dueDate = DateTime(
                date.year,
                date.month,
                date.day,
                hour,
                minute,
              );
            }
          }

          // Update the existing task with the optimized time
          return originalTask.copyWith(
            dueDate: dueDate,
          );
        } else {
          // This is a new task added by the AI
          return _parseTasks(json.encode([task]), userId, date).first;
        }
      }).toList();
    } catch (e) {
      _logger.error('Error parsing optimized tasks from Gemini response',
          error: e);
      return originalTasks;
    }
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({
    required this.hour,
    required this.minute,
  });

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
