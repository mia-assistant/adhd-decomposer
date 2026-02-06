import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'stats_service.dart';

/// Achievement definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool Function(StatsService stats, AchievementsService achievements) checkUnlocked;
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.checkUnlocked,
  });
}

/// Service for tracking and unlocking achievements
class AchievementsService extends ChangeNotifier {
  static const String _boxName = 'achievements';
  static const String keyUnlockedAchievements = 'unlockedAchievements';
  static const String keyNewlyUnlocked = 'newlyUnlocked';
  
  Box<dynamic>? _box;
  StatsService? _statsService;
  
  // List of newly unlocked achievements to celebrate
  List<Achievement> _newlyUnlockedQueue = [];
  
  Future<void> initialize(StatsService statsService) async {
    _box = await Hive.openBox(_boxName);
    _statsService = statsService;
  }
  
  Box<dynamic> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('AchievementsService not initialized. Call initialize() first.');
    }
    return _box!;
  }
  
  StatsService get _stats {
    if (_statsService == null) {
      throw StateError('AchievementsService not initialized. Call initialize() first.');
    }
    return _statsService!;
  }
  
  /// All available achievements
  static List<Achievement> get allAchievements => [
    Achievement(
      id: 'first_step',
      title: 'First Step',
      description: 'Complete your first task',
      icon: '🎯',
      checkUnlocked: (stats, _) => stats.totalTasksCompleted >= 1,
    ),
    Achievement(
      id: 'getting_started',
      title: 'Getting Started',
      description: 'Complete 5 tasks',
      icon: '🚀',
      checkUnlocked: (stats, _) => stats.totalTasksCompleted >= 5,
    ),
    Achievement(
      id: 'task_master',
      title: 'Task Master',
      description: 'Complete 25 tasks',
      icon: '⭐',
      checkUnlocked: (stats, _) => stats.totalTasksCompleted >= 25,
    ),
    Achievement(
      id: 'on_a_roll',
      title: 'On a Roll',
      description: '3-day completion streak',
      icon: '🔥',
      checkUnlocked: (stats, _) => stats.currentStreak >= 3 || stats.longestStreak >= 3,
    ),
    Achievement(
      id: 'unstoppable',
      title: 'Unstoppable',
      description: '7-day completion streak',
      icon: '💪',
      checkUnlocked: (stats, _) => stats.currentStreak >= 7 || stats.longestStreak >= 7,
    ),
    Achievement(
      id: 'century',
      title: 'Century',
      description: 'Complete 100 steps total',
      icon: '💯',
      checkUnlocked: (stats, _) => stats.totalStepsCompleted >= 100,
    ),
    Achievement(
      id: 'time_master',
      title: 'Time Master',
      description: 'Use the timer 10 times',
      icon: '⏱️',
      checkUnlocked: (stats, _) => stats.timerUsageCount >= 10,
    ),
    Achievement(
      id: 'template_pro',
      title: 'Template Pro',
      description: 'Use 5 different templates',
      icon: '📋',
      checkUnlocked: (stats, _) => stats.templatesUsed.length >= 5,
    ),
  ];
  
  /// Get set of unlocked achievement IDs
  Set<String> get unlockedAchievementIds {
    final stored = _safeBox.get(keyUnlockedAchievements);
    if (stored == null) return {};
    try {
      return Set<String>.from(jsonDecode(stored) as List);
    } catch (_) {
      return {};
    }
  }
  
  set unlockedAchievementIds(Set<String> value) {
    _safeBox.put(keyUnlockedAchievements, jsonEncode(value.toList()));
  }
  
  /// Check if specific achievement is unlocked
  bool isUnlocked(String achievementId) {
    return unlockedAchievementIds.contains(achievementId);
  }
  
  /// Get all achievements with their unlock status
  List<(Achievement, bool)> get achievementsWithStatus {
    final unlocked = unlockedAchievementIds;
    return allAchievements.map((a) => (a, unlocked.contains(a.id))).toList();
  }
  
  /// Get count of unlocked achievements
  int get unlockedCount => unlockedAchievementIds.length;
  
  /// Get total achievement count
  int get totalCount => allAchievements.length;
  
  /// Get queue of newly unlocked achievements to celebrate
  List<Achievement> get newlyUnlockedQueue => _newlyUnlockedQueue;
  
  /// Pop the next achievement to celebrate
  Achievement? popNewlyUnlocked() {
    if (_newlyUnlockedQueue.isEmpty) return null;
    final achievement = _newlyUnlockedQueue.removeAt(0);
    notifyListeners();
    return achievement;
  }
  
  /// Clear the newly unlocked queue
  void clearNewlyUnlocked() {
    _newlyUnlockedQueue.clear();
    notifyListeners();
  }
  
  /// Check and unlock any newly earned achievements
  /// Returns list of newly unlocked achievements
  List<Achievement> checkAndUnlockAchievements() {
    final currentlyUnlocked = unlockedAchievementIds;
    final newlyUnlocked = <Achievement>[];
    
    for (final achievement in allAchievements) {
      if (!currentlyUnlocked.contains(achievement.id)) {
        if (achievement.checkUnlocked(_stats, this)) {
          currentlyUnlocked.add(achievement.id);
          newlyUnlocked.add(achievement);
        }
      }
    }
    
    if (newlyUnlocked.isNotEmpty) {
      unlockedAchievementIds = currentlyUnlocked;
      _newlyUnlockedQueue.addAll(newlyUnlocked);
      notifyListeners();
    }
    
    return newlyUnlocked;
  }
}
