import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task.dart';
import '../../data/services/ai_service.dart';

class TaskProvider extends ChangeNotifier {
  final AIService _aiService;
  List<Task> _tasks = [];
  Task? _activeTask;
  bool _isLoading = false;
  String? _error;
  
  TaskProvider({AIService? aiService}) 
    : _aiService = aiService ?? AIService();
  
  List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  Task? get activeTask => _activeTask;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> initialize() async {
    try {
      final box = await Hive.openBox<String>('tasks');
      final tasksJson = box.get('tasksList');
      if (tasksJson != null && tasksJson.isNotEmpty) {
        final List<Task> decoded = [];
        for (final s in tasksJson.split('|||')) {
          if (s.isNotEmpty) {
            try {
              decoded.add(Task.fromJson(jsonDecode(s)));
            } catch (e) {
              debugPrint('Error parsing task: $e');
            }
          }
        }
        _tasks = decoded;
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasks = [];
    }
    notifyListeners();
  }
  
  Future<void> _saveTasks() async {
    try {
      final box = await Hive.openBox<String>('tasks');
      final encoded = _tasks.map((t) => jsonEncode(t.toJson())).join('|||');
      await box.put('tasksList', encoded);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }
  
  Future<Task?> decomposeTask(String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final task = await _aiService.decomposeTask(description);
      _tasks.insert(0, task);
      await _saveTasks();
      _isLoading = false;
      notifyListeners();
      return task;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  void setActiveTask(Task? task) {
    _activeTask = task;
    notifyListeners();
  }
  
  void completeCurrentStep() {
    if (_activeTask != null) {
      _activeTask!.completeCurrentStep();
      _saveTasks();
      notifyListeners();
    }
  }
  
  void skipCurrentStep() {
    if (_activeTask != null) {
      _activeTask!.skipCurrentStep();
      _saveTasks();
      notifyListeners();
    }
  }
  
  Future<List<TaskStep>> getSubSteps(String stepAction) async {
    return await _aiService.getSubSteps(stepAction, null);
  }
  
  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_activeTask?.id == taskId) {
      _activeTask = null;
    }
    _saveTasks();
    notifyListeners();
  }
  
  void clearAllTasks() {
    _tasks.clear();
    _activeTask = null;
    _saveTasks();
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
