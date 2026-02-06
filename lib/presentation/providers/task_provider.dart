import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/settings_service.dart';

class TaskProvider extends ChangeNotifier {
  final AIService _aiService;
  final SettingsService? _settings;
  List<Task> _tasks = [];
  Task? _activeTask;
  bool _isLoading = false;
  String? _error;
  
  TaskProvider({AIService? aiService, SettingsService? settings}) 
    : _aiService = aiService ?? AIService(),
      _settings = settings;
  
  List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  Task? get activeTask => _activeTask;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Settings getters for UI
  bool get soundEnabled => _settings?.soundEnabled ?? true;
  bool get hapticEnabled => _settings?.hapticEnabled ?? true;
  bool get confettiEnabled => _settings?.confettiEnabled ?? true;
  bool get canDecompose => _settings?.canDecompose ?? true;
  int get remainingFreeDecompositions => _settings?.remainingFreeDecompositions ?? -1;
  bool get isPremium => _settings?.isPremium ?? false;
  bool get hasCustomApiKey => _settings?.hasCustomApiKey ?? false;
  
  // Settings setters
  void setSoundEnabled(bool value) {
    _settings?.soundEnabled = value;
    notifyListeners();
  }
  
  void setHapticEnabled(bool value) {
    _settings?.hapticEnabled = value;
    notifyListeners();
  }
  
  void setConfettiEnabled(bool value) {
    _settings?.confettiEnabled = value;
    notifyListeners();
  }
  
  void setOpenAIApiKey(String? key) {
    _settings?.openAIApiKey = key;
    notifyListeners();
  }
  
  String? get openAIApiKey => _settings?.openAIApiKey;
  
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
      // Use custom API key if available
      final apiKey = _settings?.openAIApiKey;
      final task = await _aiService.decomposeTask(description, apiKey: apiKey);
      _tasks.insert(0, task);
      await _saveTasks();
      
      // Track decomposition count
      _settings?.incrementDecompositionCount();
      
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
    final apiKey = _settings?.openAIApiKey;
    return await _aiService.getSubSteps(stepAction, apiKey);
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
