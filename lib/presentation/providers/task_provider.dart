import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/settings_service.dart';
import '../../data/services/stats_service.dart';
import '../../data/services/achievements_service.dart';
import '../../data/services/widget_service.dart';
import '../../data/services/notification_service.dart';

// Re-export DecompositionStyle for UI access
export '../../data/services/ai_service.dart' show DecompositionStyle;
// Re-export DefaultAmbientSound for UI access
export '../../data/services/settings_service.dart' show DefaultAmbientSound;

class TaskProvider extends ChangeNotifier {
  final AIService _aiService;
  final SettingsService? _settings;
  final StatsService? _stats;
  final AchievementsService? _achievements;
  final NotificationService? _notifications;
  List<Task> _tasks = [];
  Task? _activeTask;
  bool _isLoading = false;
  String? _error;
  
  TaskProvider({
    AIService? aiService,
    SettingsService? settings,
    StatsService? stats,
    AchievementsService? achievements,
    NotificationService? notifications,
  }) : _aiService = aiService ?? AIService(),
       _settings = settings,
       _stats = stats,
       _achievements = achievements,
       _notifications = notifications;
  
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
  DecompositionStyle get decompositionStyle => _settings?.decompositionStyle ?? DecompositionStyle.standard;
  // Accessibility settings getters
  bool get reduceAnimations => _settings?.reduceAnimations ?? false;
  bool get autoAdvanceEnabled => _settings?.autoAdvanceEnabled ?? true;
  // Body Double settings getters
  DefaultAmbientSound get defaultAmbientSound => _settings?.defaultAmbientSound ?? DefaultAmbientSound.none;
  
  // Notification settings getters for UI
  bool get notificationsEnabled => _notifications?.notificationsEnabled ?? false;
  int get reminderHour => _notifications?.reminderHour ?? 9;
  int get reminderMinute => _notifications?.reminderMinute ?? 0;
  bool get gentleNudgeEnabled => _notifications?.gentleNudgeEnabled ?? true;
  
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
  
  void setReduceAnimations(bool value) {
    _settings?.reduceAnimations = value;
    notifyListeners();
  }
  
  void setAutoAdvanceEnabled(bool value) {
    _settings?.autoAdvanceEnabled = value;
    notifyListeners();
  }
  
  void setDecompositionStyle(DecompositionStyle style) {
    _settings?.decompositionStyle = style;
    notifyListeners();
  }
  
  void setDefaultAmbientSound(DefaultAmbientSound sound) {
    _settings?.defaultAmbientSound = sound;
    notifyListeners();
  }
  
  void setOpenAIApiKey(String? key) {
    _settings?.openAIApiKey = key;
    notifyListeners();
  }
  
  String? get openAIApiKey => _settings?.openAIApiKey;
  
  // Notification settings setters
  Future<bool> enableNotifications() async {
    final enabled = await _notifications?.enableNotifications() ?? false;
    notifyListeners();
    return enabled;
  }
  
  Future<void> disableNotifications() async {
    await _notifications?.disableNotifications();
    notifyListeners();
  }
  
  Future<void> setReminderTime(int hour, int minute) async {
    await _notifications?.setReminderTime(hour, minute);
    notifyListeners();
  }
  
  Future<void> setGentleNudgeEnabled(bool value) async {
    _notifications?.gentleNudgeEnabled = value;
    if (!value) {
      await _notifications?.clearUnfinishedTaskReminder();
    }
    notifyListeners();
  }
  
  Future<void> showTestNotification() async {
    await _notifications?.showTestNotification();
  }
  
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
      final style = _settings?.decompositionStyle ?? DecompositionStyle.standard;
      final task = await _aiService.decomposeTask(
        description,
        apiKey: apiKey,
        style: style,
      );
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
    _updateWidget();
    
    // Schedule unfinished task reminder if task is set
    if (task != null && !task.isCompleted) {
      _notifications?.scheduleUnfinishedTaskReminder(task.id);
    } else {
      _notifications?.clearUnfinishedTaskReminder();
    }
    
    notifyListeners();
  }
  
  void completeCurrentStep() {
    if (_activeTask != null) {
      final wasCompleted = _activeTask!.isCompleted;
      _activeTask!.completeCurrentStep();
      
      // Record step completion
      _stats?.recordStepCompletion();
      
      // Update notification activity (resets 2-hour timer)
      _notifications?.updateTaskActivity();
      
      // If task is now completed, record task completion
      if (!wasCompleted && _activeTask!.isCompleted) {
        _stats?.recordTaskCompletion(
          stepsCompleted: _activeTask!.completedStepsCount,
        );
        // Check for new achievements
        _achievements?.checkAndUnlockAchievements();
        
        // Clear unfinished task reminder and schedule streak reminder
        _notifications?.clearUnfinishedTaskReminder();
        final currentStreak = _stats?.currentStreak ?? 0;
        if (currentStreak >= 2) {
          _notifications?.scheduleStreakReminder(currentStreak);
        }
      }
      
      _saveTasks();
      _updateWidget();
      notifyListeners();
    }
  }
  
  void skipCurrentStep() {
    if (_activeTask != null) {
      _activeTask!.skipCurrentStep();
      
      // Update notification activity (resets 2-hour timer)
      _notifications?.updateTaskActivity();
      
      _saveTasks();
      _updateWidget();
      notifyListeners();
    }
  }
  
  /// Update home screen widget with current task data
  Future<void> _updateWidget() async {
    await WidgetService.updateCurrentTask(_activeTask);
  }
  
  Future<List<TaskStep>> getSubSteps(String stepAction) async {
    final apiKey = _settings?.openAIApiKey;
    return await _aiService.getSubSteps(stepAction, apiKey);
  }
  
  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_activeTask?.id == taskId) {
      _activeTask = null;
      _notifications?.clearUnfinishedTaskReminder();
    }
    _saveTasks();
    notifyListeners();
  }
  
  /// Add a task from a template (no AI decomposition needed)
  void addTask(Task task) {
    _tasks.insert(0, task);
    _saveTasks();
    notifyListeners();
  }
  
  void clearAllTasks() {
    _tasks.clear();
    _activeTask = null;
    _notifications?.clearUnfinishedTaskReminder();
    _saveTasks();
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Record timer usage for stats tracking
  void recordTimerUsage(int minutes) {
    _stats?.recordTimerUsage(minutes);
    _achievements?.checkAndUnlockAchievements();
  }
  
  /// Record template usage for stats tracking
  void recordTemplateUsed(String templateId) {
    _stats?.recordTemplateUsed(templateId);
    _achievements?.checkAndUnlockAchievements();
  }
}
