import 'package:flutter/foundation.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';
import '../models/routine.dart';

/// Service for managing Siri Shortcuts integration
/// 
/// Allows users to trigger app actions via Siri:
/// - "Hey Siri, break down a task with Tiny Steps"
/// - "Hey Siri, continue my task in Tiny Steps"
/// - "Hey Siri, show my Tiny Steps progress"
/// - "Hey Siri, start morning routine in Tiny Steps"
class SiriService {
  static final SiriService _instance = SiriService._internal();
  factory SiriService() => _instance;
  SiriService._internal();

  final FlutterAppIntentsClient _client = FlutterAppIntentsClient.instance;
  bool _initialized = false;

  /// Callback functions for handling intent results
  /// These are set by the app to handle navigation
  Function()? onStartNewTask;
  Function()? onContinueTask;
  Function()? onShowProgress;
  Function(String routineName)? onStartRoutine;

  /// Intent identifiers - must match Swift static intents
  static const String intentStartNewTask = 'start_new_task';
  static const String intentContinueTask = 'continue_task';
  static const String intentShowProgress = 'show_progress';
  static const String intentStartRoutine = 'start_routine';

  /// Initialize Siri Shortcuts integration
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Register intent handlers
      await _registerIntents();
      _initialized = true;
      debugPrint('SiriService: Initialized successfully');
    } catch (e) {
      debugPrint('SiriService: Failed to initialize: $e');
    }
  }

  /// Register all app intents with their handlers
  Future<void> _registerIntents() async {
    // Start New Task intent
    final startNewTaskIntent = AppIntentBuilder()
        .identifier(intentStartNewTask)
        .title('Start a New Task')
        .description('Open the task decomposition screen to break down a new task')
        .build();

    await _client.registerIntent(startNewTaskIntent, (parameters) async {
      debugPrint('SiriService: Start new task intent triggered');
      onStartNewTask?.call();
      return AppIntentResult.successful(
        value: 'Opening task breakdown screen',
        needsToContinueInApp: true,
      );
    });

    // Continue Task intent
    final continueTaskIntent = AppIntentBuilder()
        .identifier(intentContinueTask)
        .title('Continue My Task')
        .description('Resume working on your current task')
        .build();

    await _client.registerIntent(continueTaskIntent, (parameters) async {
      debugPrint('SiriService: Continue task intent triggered');
      onContinueTask?.call();
      return AppIntentResult.successful(
        value: 'Continuing your task',
        needsToContinueInApp: true,
      );
    });

    // Show Progress intent
    final showProgressIntent = AppIntentBuilder()
        .identifier(intentShowProgress)
        .title('Show My Progress')
        .description('View your task completion statistics')
        .build();

    await _client.registerIntent(showProgressIntent, (parameters) async {
      debugPrint('SiriService: Show progress intent triggered');
      onShowProgress?.call();
      return AppIntentResult.successful(
        value: 'Opening your progress stats',
        needsToContinueInApp: true,
      );
    });

    // Start Routine intent
    final startRoutineIntent = AppIntentBuilder()
        .identifier(intentStartRoutine)
        .title('Start Routine')
        .description('Start a specific routine by name')
        .parameter(const AppIntentParameter(
          name: 'routineName',
          title: 'Routine Name',
          type: AppIntentParameterType.string,
          isOptional: true,
          description: 'The name of the routine to start',
        ))
        .build();

    await _client.registerIntent(startRoutineIntent, (parameters) async {
      final routineName = parameters['routineName'] as String? ?? 'morning routine';
      debugPrint('SiriService: Start routine intent triggered: $routineName');
      onStartRoutine?.call(routineName);
      return AppIntentResult.successful(
        value: 'Starting $routineName',
        needsToContinueInApp: true,
      );
    });
  }

  /// Donate an intent when user completes a task
  /// This helps Siri suggest "Start another task" 
  Future<void> donateTaskCompleted() async {
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        intentStartNewTask,
        {},
        relevanceScore: 0.8,
        context: {
          'feature': 'task_completion',
          'userAction': true,
          'suggestion': 'start_another',
        },
      );
      debugPrint('SiriService: Donated task completed intent');
    } catch (e) {
      debugPrint('SiriService: Failed to donate intent: $e');
    }
  }

  /// Donate an intent when user uses a routine
  /// This helps Siri suggest the routine for next time
  Future<void> donateRoutineUsed(Routine routine) async {
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        intentStartRoutine,
        {'routineName': routine.name},
        relevanceScore: 0.9,
        context: {
          'feature': 'routines',
          'userAction': true,
          'routineId': routine.id,
          'routineName': routine.name,
        },
      );
      debugPrint('SiriService: Donated routine used intent: ${routine.name}');
    } catch (e) {
      debugPrint('SiriService: Failed to donate routine intent: $e');
    }
  }

  /// Donate an intent when user views stats
  /// This helps Siri suggest "Check your progress"
  Future<void> donateStatsViewed() async {
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        intentShowProgress,
        {},
        relevanceScore: 0.7,
        context: {
          'feature': 'stats',
          'userAction': true,
        },
      );
      debugPrint('SiriService: Donated stats viewed intent');
    } catch (e) {
      debugPrint('SiriService: Failed to donate stats intent: $e');
    }
  }

  /// Donate an intent when user starts task decomposition
  /// This helps Siri suggest "Break down a task"
  Future<void> donateDecomposeStarted() async {
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        intentStartNewTask,
        {},
        relevanceScore: 0.85,
        context: {
          'feature': 'decomposition',
          'userAction': true,
        },
      );
      debugPrint('SiriService: Donated decompose started intent');
    } catch (e) {
      debugPrint('SiriService: Failed to donate decompose intent: $e');
    }
  }

  /// Donate intent when user continues an active task
  Future<void> donateContinueTask() async {
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        intentContinueTask,
        {},
        relevanceScore: 0.9,
        context: {
          'feature': 'task_execution',
          'userAction': true,
        },
      );
      debugPrint('SiriService: Donated continue task intent');
    } catch (e) {
      debugPrint('SiriService: Failed to donate continue intent: $e');
    }
  }
}
