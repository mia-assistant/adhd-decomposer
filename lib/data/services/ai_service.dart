import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  final String? defaultApiKey;
  final Uuid _uuid = const Uuid();
  
  AIService({this.defaultApiKey});
  
  Future<Task> decomposeTask(String taskDescription, {String? apiKey}) async {
    final effectiveKey = apiKey ?? defaultApiKey;
    
    if (effectiveKey == null || effectiveKey.isEmpty) {
      // Return mock data for testing without API key
      return _getMockDecomposition(taskDescription);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $effectiveKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': 'Break down this task: "$taskDescription"',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseAIResponse(taskDescription, content);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock on error
      return _getMockDecomposition(taskDescription);
    }
  }
  
  Future<List<TaskStep>> getSubSteps(String stepAction, String? apiKey) async {
    final effectiveKey = apiKey ?? defaultApiKey;
    
    if (effectiveKey == null || effectiveKey.isEmpty) {
      return _getMockSubSteps(stepAction);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $effectiveKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _stuckPrompt,
            },
            {
              'role': 'user',
              'content': 'The user is stuck on: "$stepAction"',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseSubSteps(content);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      return _getMockSubSteps(stepAction);
    }
  }
  
  Task _parseAIResponse(String originalTask, String content) {
    try {
      // Try to parse JSON from the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final json = jsonDecode(jsonMatch.group(0)!);
        
        final steps = (json['steps'] as List).map((step) {
          return TaskStep(
            id: _uuid.v4(),
            action: step['action'] ?? step['step'] ?? '',
            estimatedMinutes: step['minutes'] ?? step['estimatedMinutes'] ?? 5,
          );
        }).toList();
        
        return Task(
          id: _uuid.v4(),
          title: json['task_name'] ?? json['taskName'] ?? originalTask,
          steps: steps,
          totalEstimatedMinutes: json['total_estimated_minutes'] ?? 
                                 json['totalEstimatedMinutes'] ?? 
                                 steps.fold(0, (sum, s) => sum + s.estimatedMinutes),
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      // If parsing fails, return mock
    }
    return _getMockDecomposition(originalTask);
  }
  
  List<TaskStep> _parseSubSteps(String content) {
    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
      if (jsonMatch != null) {
        final json = jsonDecode(jsonMatch.group(0)!) as List;
        return json.map((step) {
          return TaskStep(
            id: _uuid.v4(),
            action: step['action'] ?? step['step'] ?? '',
            estimatedMinutes: step['minutes'] ?? 2,
          );
        }).toList();
      }
    } catch (e) {
      // Fall through to mock
    }
    return [];
  }
  
  Task _getMockDecomposition(String taskDescription) {
    // Intelligent mock based on common tasks
    final lowerTask = taskDescription.toLowerCase();
    
    List<Map<String, dynamic>> mockSteps;
    
    if (lowerTask.contains('clean') && lowerTask.contains('kitchen')) {
      mockSteps = [
        {'action': 'Clear countertops into sink or trash', 'minutes': 3},
        {'action': 'Put away any items that belong elsewhere', 'minutes': 2},
        {'action': 'Load dirty dishes into dishwasher', 'minutes': 5},
        {'action': 'Hand wash any remaining dishes', 'minutes': 5},
        {'action': 'Wipe down countertops', 'minutes': 3},
        {'action': 'Wipe stovetop and appliances', 'minutes': 3},
        {'action': 'Take out trash if needed', 'minutes': 2},
        {'action': 'Sweep or wipe floor', 'minutes': 5},
      ];
    } else if (lowerTask.contains('laundry')) {
      mockSteps = [
        {'action': 'Gather all dirty clothes into basket', 'minutes': 5},
        {'action': 'Sort clothes by color/type', 'minutes': 3},
        {'action': 'Load first batch into washer', 'minutes': 2},
        {'action': 'Add detergent and start cycle', 'minutes': 1},
        {'action': 'Set timer for when cycle ends', 'minutes': 1},
        {'action': 'Transfer to dryer when done', 'minutes': 2},
        {'action': 'Fold clothes when dry', 'minutes': 10},
        {'action': 'Put folded clothes away', 'minutes': 5},
      ];
    } else if (lowerTask.contains('email') || lowerTask.contains('inbox')) {
      mockSteps = [
        {'action': 'Open email app/website', 'minutes': 1},
        {'action': 'Delete obvious spam and junk', 'minutes': 2},
        {'action': 'Flag emails that need action later', 'minutes': 3},
        {'action': 'Reply to quick emails (under 2 min each)', 'minutes': 5},
        {'action': 'Archive handled emails', 'minutes': 2},
        {'action': 'Tackle one flagged email', 'minutes': 5},
      ];
    } else {
      // Generic decomposition
      mockSteps = [
        {'action': 'Get materials/tools needed for task', 'minutes': 3},
        {'action': 'Set up your workspace', 'minutes': 2},
        {'action': 'Start with the easiest part first', 'minutes': 5},
        {'action': 'Continue to the next section', 'minutes': 5},
        {'action': 'Take a quick stretch break', 'minutes': 1},
        {'action': 'Complete the remaining work', 'minutes': 5},
        {'action': 'Clean up and put things away', 'minutes': 3},
      ];
    }
    
    final steps = mockSteps.map((s) => TaskStep(
      id: _uuid.v4(),
      action: s['action'],
      estimatedMinutes: s['minutes'],
    )).toList();
    
    return Task(
      id: _uuid.v4(),
      title: taskDescription,
      steps: steps,
      totalEstimatedMinutes: steps.fold(0, (sum, s) => sum + s.estimatedMinutes),
      createdAt: DateTime.now(),
    );
  }
  
  List<TaskStep> _getMockSubSteps(String stepAction) {
    return [
      TaskStep(
        id: _uuid.v4(),
        action: 'Take a deep breath and stand up',
        estimatedMinutes: 1,
      ),
      TaskStep(
        id: _uuid.v4(),
        action: 'Walk to where you need to be for this step',
        estimatedMinutes: 1,
      ),
      TaskStep(
        id: _uuid.v4(),
        action: 'Do just the first tiny part of: $stepAction',
        estimatedMinutes: 2,
      ),
    ];
  }
  
  static const String _systemPrompt = '''
You are an ADHD-friendly task assistant. Break down the following task into small, actionable steps that take 2-10 minutes each.

Rules:
- Each step should be ONE physical action
- Use simple, direct language
- Start each step with a verb (Put, Open, Grab, Walk, Type, etc.)
- Include time estimates in minutes
- Don't include "think about" or "consider" steps - only actions
- If a step is still complex, break it down further
- Maximum 12 steps, minimum 3
- Be encouraging but not cheesy

Output format (JSON only, no explanation):
{
  "task_name": "Clean the kitchen",
  "total_estimated_minutes": 28,
  "steps": [
    {"action": "Put all dishes in sink", "minutes": 2},
    {"action": "Fill sink with soapy water", "minutes": 1}
  ]
}
''';

  static const String _stuckPrompt = '''
The user is stuck on a task step and needs it broken down even smaller.

Rules:
- Provide 2-3 even tinier steps
- Each should take 1-3 minutes max
- Be warm and encouraging
- Start with something easy (like standing up or walking over)
- Don't make them feel bad for being stuck

Output format (JSON array only):
[
  {"action": "Stand up from your chair", "minutes": 1},
  {"action": "Walk to the kitchen", "minutes": 1}
]
''';
}
