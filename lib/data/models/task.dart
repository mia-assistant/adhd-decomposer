class Task {
  final String id;
  String title;
  List<TaskStep> steps;
  int totalEstimatedMinutes;
  DateTime createdAt;
  DateTime? completedAt;
  int currentStepIndex;

  Task({
    required this.id,
    required this.title,
    required this.steps,
    required this.totalEstimatedMinutes,
    required this.createdAt,
    this.completedAt,
    this.currentStepIndex = 0,
  });

  bool get isCompleted => completedAt != null;
  
  int get completedStepsCount => steps.where((s) => s.isCompleted).length;
  
  double get progress => steps.isEmpty ? 0 : completedStepsCount / steps.length;

  TaskStep? get currentStep {
    if (currentStepIndex < steps.length) {
      return steps[currentStepIndex];
    }
    return null;
  }

  void completeCurrentStep() {
    if (currentStepIndex < steps.length) {
      steps[currentStepIndex].isCompleted = true;
      steps[currentStepIndex].completedAt = DateTime.now();
      currentStepIndex++;
      
      if (currentStepIndex >= steps.length) {
        completedAt = DateTime.now();
      }
    }
  }

  void skipCurrentStep() {
    if (currentStepIndex < steps.length) {
      steps[currentStepIndex].isSkipped = true;
      currentStepIndex++;
      
      if (currentStepIndex >= steps.length) {
        completedAt = DateTime.now();
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'steps': steps.map((s) => s.toJson()).toList(),
    'totalEstimatedMinutes': totalEstimatedMinutes,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'currentStepIndex': currentStepIndex,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    steps: (json['steps'] as List).map((s) => TaskStep.fromJson(s as Map<String, dynamic>)).toList(),
    totalEstimatedMinutes: json['totalEstimatedMinutes'],
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    currentStepIndex: json['currentStepIndex'] ?? 0,
  );
}

class TaskStep {
  final String id;
  String action;
  int estimatedMinutes;
  bool isCompleted;
  bool isSkipped;
  DateTime? completedAt;
  List<TaskStep>? subSteps;

  TaskStep({
    required this.id,
    required this.action,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.isSkipped = false,
    this.completedAt,
    this.subSteps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'estimatedMinutes': estimatedMinutes,
    'isCompleted': isCompleted,
    'isSkipped': isSkipped,
    'completedAt': completedAt?.toIso8601String(),
    'subSteps': subSteps?.map((s) => s.toJson()).toList(),
  };

  factory TaskStep.fromJson(Map<String, dynamic> json) => TaskStep(
    id: json['id'] ?? '',
    action: json['action'],
    estimatedMinutes: json['estimatedMinutes'] ?? json['minutes'] ?? 5,
    isCompleted: json['isCompleted'] ?? false,
    isSkipped: json['isSkipped'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    subSteps: json['subSteps'] != null 
      ? (json['subSteps'] as List).map((s) => TaskStep.fromJson(s as Map<String, dynamic>)).toList()
      : null,
  );
}
