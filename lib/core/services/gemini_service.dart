import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Service for interacting with the Gemini API to support continuous chatting and task planning.
/// Manages multi-turn conversations and generates structured task plans.
class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);

  // Storage for conversation histories by user ID
  final Map<String, List<Map<String, dynamic>>> _conversationHistories = {};

  /// Sends a chat message, maintaining conversation history for continuous chatting.
  /// Returns a tuple of (response text, list of tasks).
  Future<(String, List<Map<String, dynamic>>)> sendChatMessage({
    required String userId,
    required String message,
    required List<Map<String, dynamic>> conversationHistory,
    bool isNewConversation = false,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('Gemini API key is missing');
      }

      // System instruction for the AI
      const systemInstruction = '''
You are TimeTide, an AI-powered task planner and conversational assistant. Your role is to:
- Engage in natural, helpful conversations with users about their plans and tasks.
- Generate actionable task suggestions when requested, formatted as a JSON array of tasks.
- Each task must include:
  - id: A unique UUID string
  - title: A concise task name (string)
  - category: One of [Work, Health, Errands, Personal] (string)
  - priority: One of [Low, Medium, High] (string)
  - time: A suggested time in HH:MM format (string, optional)
- Respond to follow-up questions or refinements by adjusting tasks or providing clarification.
- If the user asks to refine a task, return an updated JSON array with modified tasks.
- If no tasks are requested, provide a conversational response without JSON.
- Ensure responses are concise, friendly, and contextually relevant.
''';

      // Build the conversation context
      final messages = <Map<String, dynamic>>[
        if (isNewConversation)
          {
            'role': 'system',
            'parts': [
              {'text': systemInstruction}
            ]
          },
        ...conversationHistory.map((msg) => {
              'role': msg['isUser'] ? 'user' : 'model',
              'parts': [
                {
                  'text': msg['tasks'] != null
                      ? '${msg['message']}\n\n```json\n${jsonEncode(msg['tasks'])}\n```'
                      : msg['message']
                }
              ]
            }),
        {
          'role': 'user',
          'parts': [
            {'text': message}
          ]
        },
      ];

      // Make the API request with retry logic
      final response = await _makeApiRequestWithRetry({
        'contents': messages,
      });

      // Parse the response
      final data = jsonDecode(response.body);
      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception('No valid response from Gemini API');
      }

      final content =
          data['candidates'][0]['content']['parts'][0]['text'] as String;
      // Extract text and tasks
      final (responseText, tasks) = _parseResponse(content);

      return (responseText, tasks);
    } catch (e) {
      throw Exception('Failed to send chat message: $e');
    }
  }

  /// Generates a task plan based on a prompt (used for initial task generation).
  Future<List<Map<String, dynamic>>> generateTaskPlan(String prompt) async {
    try {
      // Use sendChatMessage for consistency, simulating a new conversation
      final (responseText, tasks) = await sendChatMessage(
        userId: 'system', // Dummy user ID for task generation
        message: prompt,
        conversationHistory: [],
        isNewConversation: true,
      );

      if (tasks.isEmpty && responseText.isNotEmpty) {
        throw Exception('No tasks generated for prompt: $responseText');
      }

      return tasks;
    } catch (e) {
      throw Exception('Failed to generate task plan: $e');
    }
  }

  /// Clears the conversation history for a specific user.
  void clearConversationHistory(String userId) {
    _conversationHistories[userId] = [];
  }

  /// Makes an API request with retry logic for transient errors.
  Future<http.Response> _makeApiRequestWithRetry(
      Map<String, dynamic> body) async {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode >= 500 && attempt < _maxRetries - 1) {
          // Retry for server errors
          await Future.delayed(_retryDelay * (attempt + 1));
          attempt++;
          continue;
        } else {
          throw Exception(
              'API request failed: ${response.statusCode} ${response.reasonPhrase}');
        }
      } catch (e) {
        if (attempt < _maxRetries - 1 &&
            e.toString().contains('SocketException')) {
          // Retry for network errors
          await Future.delayed(_retryDelay * (attempt + 1));
          attempt++;
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max retries exceeded for API request');
  }

  /// Parses the API response to extract text and tasks.
  (String, List<Map<String, dynamic>>) _parseResponse(String content) {
    // Check for JSON block
    final jsonMatch = RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(content);
    List<Map<String, dynamic>> tasks = [];
    String responseText = content;

    if (jsonMatch != null) {
      try {
        final jsonString = jsonMatch.group(1)!;
        final parsedTasks = jsonDecode(jsonString) as List<dynamic>;
        tasks = parsedTasks.cast<Map<String, dynamic>>();

        // Validate tasks
        for (var task in tasks) {
          if (!_isValidTask(task)) {
            throw Exception('Invalid task format: $task');
          }
          // Ensure each task has an ID
          if (!task.containsKey('id') ||
              task['id'] == null ||
              (task['id'] as String).isEmpty) {
            task['id'] = const Uuid().v4();
          }
        }

        // Remove JSON block from response text
        responseText = content.replaceAll(jsonMatch.group(0)!, '').trim();
      } catch (e) {
        // If JSON parsing fails, treat as text-only response
        responseText = content;
        tasks = [];
      }
    } else {
      // No JSON block, treat as text-only response
      responseText = content.replaceAll(RegExp(r'```json|```'), '').trim();
    }

    return (responseText, tasks);
  }

  /// Validates a task for required fields and formats.
  bool _isValidTask(Map<String, dynamic> task) {
    return task.containsKey('title') &&
        task['title'] is String &&
        task['title'].toString().isNotEmpty &&
        task.containsKey('category') &&
        task['category'] is String &&
        ['Work', 'Health', 'Errands', 'Personal'].contains(task['category']) &&
        task.containsKey('priority') &&
        task['priority'] is String &&
        ['Low', 'Medium', 'High'].contains(task['priority']) &&
        (task['time'] == null ||
            (task['time'] is String &&
                RegExp(r'^\d{2}:\d{2}$').hasMatch(task['time'])));
  }
}
