import 'package:flutter/material.dart';
import 'task.dart';

/// Recurrence types for routines
enum RecurrenceType {
  daily,     // Every day
  weekdays,  // Monday-Friday
  weekly,    // Specific days of the week
  monthly,   // Specific day of the month
}

/// Model for recurring routines
class Routine {
  final String id;
  String name;
  List<TaskStep> steps;
  RecurrenceType recurrence;
  TimeOfDay preferredTime;
  List<int> daysOfWeek; // 1-7 (Monday-Sunday) for weekly recurrence
  int? dayOfMonth; // 1-31 for monthly recurrence
  DateTime? lastCompleted;
  int completionStreak;
  DateTime createdAt;
  int totalEstimatedMinutes;

  Routine({
    required this.id,
    required this.name,
    required this.steps,
    required this.recurrence,
    required this.preferredTime,
    this.daysOfWeek = const [],
    this.dayOfMonth,
    this.lastCompleted,
    this.completionStreak = 0,
    DateTime? createdAt,
    int? totalEstimatedMinutes,
  }) : createdAt = createdAt ?? DateTime.now(),
       totalEstimatedMinutes = totalEstimatedMinutes ?? 
           steps.fold(0, (sum, step) => sum + step.estimatedMinutes);

  /// Check if this routine is due today
  bool isDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // If already completed today, not due
    if (lastCompleted != null) {
      final lastCompletedDate = DateTime(
        lastCompleted!.year,
        lastCompleted!.month,
        lastCompleted!.day,
      );
      if (lastCompletedDate == today) {
        return false;
      }
    }
    
    switch (recurrence) {
      case RecurrenceType.daily:
        return true;
        
      case RecurrenceType.weekdays:
        // Monday = 1, Sunday = 7
        return now.weekday >= 1 && now.weekday <= 5;
        
      case RecurrenceType.weekly:
        return daysOfWeek.contains(now.weekday);
        
      case RecurrenceType.monthly:
        if (dayOfMonth == null) return false;
        // Handle months with fewer days
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        final effectiveDay = dayOfMonth! > lastDayOfMonth 
            ? lastDayOfMonth 
            : dayOfMonth!;
        return now.day == effectiveDay;
    }
  }

  /// Check if this routine is completed today
  bool isCompletedToday() {
    if (lastCompleted == null) return false;
    final now = DateTime.now();
    return lastCompleted!.year == now.year &&
           lastCompleted!.month == now.month &&
           lastCompleted!.day == now.day;
  }

  /// Mark routine as complete and update streak
  void markComplete() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastCompleted != null) {
      final lastDate = DateTime(
        lastCompleted!.year,
        lastCompleted!.month,
        lastCompleted!.day,
      );
      
      // Check if this continues the streak (completed yesterday or today)
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastDate == yesterday || _wasScheduledYesterday(lastDate, today)) {
        completionStreak++;
      } else if (lastDate != today) {
        // Streak broken - reset to 1
        completionStreak = 1;
      }
    } else {
      // First completion
      completionStreak = 1;
    }
    
    lastCompleted = now;
  }

  /// Check if this routine was scheduled for the previous day
  bool _wasScheduledYesterday(DateTime lastDate, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    
    switch (recurrence) {
      case RecurrenceType.daily:
        return lastDate == yesterday;
        
      case RecurrenceType.weekdays:
        // If yesterday was a weekday and we completed it
        return yesterday.weekday >= 1 && 
               yesterday.weekday <= 5 && 
               lastDate == yesterday;
        
      case RecurrenceType.weekly:
        return daysOfWeek.contains(yesterday.weekday) && 
               lastDate == yesterday;
        
      case RecurrenceType.monthly:
        // Monthly streaks just check consecutive months
        return true;
    }
  }

  /// Get human-readable recurrence description
  String get recurrenceDescription {
    switch (recurrence) {
      case RecurrenceType.daily:
        return 'Every day';
      case RecurrenceType.weekdays:
        return 'Weekdays';
      case RecurrenceType.weekly:
        if (daysOfWeek.isEmpty) return 'Weekly';
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final days = daysOfWeek.map((d) => dayNames[d - 1]).join(', ');
        return days;
      case RecurrenceType.monthly:
        if (dayOfMonth == null) return 'Monthly';
        final suffix = _getOrdinalSuffix(dayOfMonth!);
        return '${dayOfMonth}$suffix of month';
    }
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  /// Create a Task instance from this routine for execution
  Task toTask() {
    // Create fresh copies of steps (not completed)
    final freshSteps = steps.map((s) => TaskStep(
      id: s.id,
      action: s.action,
      estimatedMinutes: s.estimatedMinutes,
      isCompleted: false,
      isSkipped: false,
      subSteps: s.subSteps?.map((sub) => TaskStep(
        id: sub.id,
        action: sub.action,
        estimatedMinutes: sub.estimatedMinutes,
      )).toList(),
    )).toList();

    return Task(
      id: 'routine_${id}_${DateTime.now().millisecondsSinceEpoch}',
      title: name,
      steps: freshSteps,
      totalEstimatedMinutes: totalEstimatedMinutes,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'steps': steps.map((s) => s.toJson()).toList(),
    'recurrence': recurrence.name,
    'preferredTimeHour': preferredTime.hour,
    'preferredTimeMinute': preferredTime.minute,
    'daysOfWeek': daysOfWeek,
    'dayOfMonth': dayOfMonth,
    'lastCompleted': lastCompleted?.toIso8601String(),
    'completionStreak': completionStreak,
    'createdAt': createdAt.toIso8601String(),
    'totalEstimatedMinutes': totalEstimatedMinutes,
  };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'],
    name: json['name'],
    steps: (json['steps'] as List)
        .map((s) => TaskStep.fromJson(s as Map<String, dynamic>))
        .toList(),
    recurrence: RecurrenceType.values.firstWhere(
      (e) => e.name == json['recurrence'],
      orElse: () => RecurrenceType.daily,
    ),
    preferredTime: TimeOfDay(
      hour: json['preferredTimeHour'] ?? 9,
      minute: json['preferredTimeMinute'] ?? 0,
    ),
    daysOfWeek: (json['daysOfWeek'] as List?)?.cast<int>() ?? [],
    dayOfMonth: json['dayOfMonth'],
    lastCompleted: json['lastCompleted'] != null 
        ? DateTime.parse(json['lastCompleted']) 
        : null,
    completionStreak: json['completionStreak'] ?? 0,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : null,
    totalEstimatedMinutes: json['totalEstimatedMinutes'],
  );

  /// Copy routine with modifications
  Routine copyWith({
    String? id,
    String? name,
    List<TaskStep>? steps,
    RecurrenceType? recurrence,
    TimeOfDay? preferredTime,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? lastCompleted,
    int? completionStreak,
    int? totalEstimatedMinutes,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      recurrence: recurrence ?? this.recurrence,
      preferredTime: preferredTime ?? this.preferredTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      completionStreak: completionStreak ?? this.completionStreak,
      createdAt: createdAt,
      totalEstimatedMinutes: totalEstimatedMinutes ?? this.totalEstimatedMinutes,
    );
  }
}
