import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<List<Map<String, dynamic>>> generateTaskPlan(String prompt) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('Gemini API key is missing');
      }

      // Define a structured prompt for task planning
      final fullPrompt = '''
You are an AI-powered task planner. Based on the user's input, generate a list of actionable tasks to help them achieve their goal. Each task should include:
- title: A concise task name (string)
- category: One of [Work, Health, Errands, Personal] (string)
- priority: One of [Low, Medium, High] (string)
- time: A suggested time in HH:MM format (string, optional)

User input: "$prompt"

Return the response as a JSON array of tasks, e.g.:
[
  {"title": "Complete project report", "category": "Work", "priority": "High", "time": "09:00"},
  {"title": "Go for a 30-min run", "category": "Health", "priority": "Medium", "time": "18:00"}
]
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API request failed: ${response.statusCode} ${response.reasonPhrase}');
      }

      final data = jsonDecode(response.body);
      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception('No valid response from Gemini API');
      }

      // Extract the JSON content from the response
      final content = data['candidates'][0]['content']['parts'][0]['text'];
      // Clean up any markdown or formatting
      final cleanedContent = content.replaceAll(RegExp(r'```json|```'), '').trim();
      final tasks = jsonDecode(cleanedContent) as List<dynamic>;
      return tasks.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to generate task plan: $e');
    }
  }
}