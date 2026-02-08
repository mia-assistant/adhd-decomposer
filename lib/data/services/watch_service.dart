import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for communicating with the Apple Watch companion app.
///
/// Since Flutter doesn't have native watchOS support, this service uses
/// method channels to communicate with native iOS code, which then uses
/// WatchConnectivity to sync with the watch.
///
/// ## Setup Required
///
/// 1. Add method channel handler in iOS AppDelegate.swift:
/// ```swift
/// let watchChannel = FlutterMethodChannel(
///     name: "com.yourcompany.tinysteps/watch",
///     binaryMessenger: controller.binaryMessenger
/// )
/// watchChannel.setMethodCallHandler { call, result in
///     WatchService.handle(call: call, result: result)
/// }
/// ```
///
/// 2. Implement WatchService in Swift using WatchConnectivity
///
/// 3. Create the watchOS app target in Xcode
///
/// See: watchapp/README.md for full setup instructions
class WatchService {
  static const _channel = MethodChannel('com.yourcompany.tinysteps/watch');

  /// Stream controller for watch connectivity status
  static final _connectivityController = StreamController<WatchConnectivity>.broadcast();

  /// Stream of watch connectivity changes
  static Stream<WatchConnectivity> get connectivityStream => _connectivityController.stream;

  /// Initialize the watch service and set up message handlers
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);

    // Check initial connectivity
    await checkConnectivity();
  }

  /// Handle incoming method calls from native code
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onStepCompleted':
        final taskId = call.arguments['taskId'] as String;
        final stepId = call.arguments['stepId'] as String;
        _handleStepCompleted(taskId, stepId);
        break;

      case 'onStepSkipped':
        final taskId = call.arguments['taskId'] as String;
        final stepId = call.arguments['stepId'] as String;
        _handleStepSkipped(taskId, stepId);
        break;

      case 'onConnectivityChanged':
        final isConnected = call.arguments['isConnected'] as bool;
        final isPaired = call.arguments['isPaired'] as bool;
        final isReachable = call.arguments['isReachable'] as bool;
        _connectivityController.add(WatchConnectivity(
          isConnected: isConnected,
          isPaired: isPaired,
          isReachable: isReachable,
        ));
        break;
    }
    return null;
  }

  /// Check current watch connectivity status
  static Future<WatchConnectivity> checkConnectivity() async {
    try {
      final result = await _channel.invokeMethod<Map>('checkConnectivity');
      return WatchConnectivity(
        isConnected: result?['isConnected'] ?? false,
        isPaired: result?['isPaired'] ?? false,
        isReachable: result?['isReachable'] ?? false,
      );
    } on PlatformException {
      return WatchConnectivity.disconnected();
    }
  }

  /// Sync the current active task to the watch
  ///
  /// Call this whenever:
  /// - User starts a new task
  /// - Task steps change
  /// - Current step advances
  static Future<bool> syncTask(WatchTaskData task) async {
    try {
      await _channel.invokeMethod('syncTask', task.toJson());
      return true;
    } on PlatformException catch (e) {
      debugPrint('WatchService: Failed to sync task to watch: ${e.message}');
      return false;
    }
  }

  /// Clear the task from the watch (when task is completed/abandoned)
  static Future<bool> clearTask() async {
    try {
      await _channel.invokeMethod('clearTask');
      return true;
    } on PlatformException catch (e) {
      debugPrint('WatchService: Failed to clear watch task: ${e.message}');
      return false;
    }
  }

  /// Update only the current step (lightweight sync)
  static Future<bool> updateCurrentStep({
    required String taskId,
    required int stepIndex,
  }) async {
    try {
      await _channel.invokeMethod('updateStep', {
        'taskId': taskId,
        'stepIndex': stepIndex,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('WatchService: Failed to update watch step: ${e.message}');
      return false;
    }
  }

  /// Start a timer on the watch
  static Future<bool> startTimer({
    required String taskId,
    required int durationSeconds,
  }) async {
    try {
      await _channel.invokeMethod('startTimer', {
        'taskId': taskId,
        'duration': durationSeconds,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('WatchService: Failed to start watch timer: ${e.message}');
      return false;
    }
  }

  /// Handle step completion from watch
  static void _handleStepCompleted(String taskId, String stepId) {
    // v2: Connect to task repository to mark step complete
    debugPrint('WatchService: Step completed from watch: $stepId in task: $taskId');
  }

  /// Handle step skip from watch
  static void _handleStepSkipped(String taskId, String stepId) {
    // v2: Connect to task repository to mark step skipped
    debugPrint('WatchService: Step skipped from watch: $stepId in task: $taskId');
  }

  /// Dispose resources
  static void dispose() {
    _connectivityController.close();
  }
}

/// Watch connectivity status
class WatchConnectivity {
  final bool isConnected;
  final bool isPaired;
  final bool isReachable;

  WatchConnectivity({
    required this.isConnected,
    required this.isPaired,
    required this.isReachable,
  });

  factory WatchConnectivity.disconnected() => WatchConnectivity(
        isConnected: false,
        isPaired: false,
        isReachable: false,
      );

  /// True if we can send data to watch right now
  bool get canSync => isConnected && isPaired;

  /// True if we can send messages for immediate delivery
  bool get canSendRealtime => canSync && isReachable;

  @override
  String toString() =>
      'WatchConnectivity(connected: $isConnected, paired: $isPaired, reachable: $isReachable)';
}

/// Task data structure for watch sync
class WatchTaskData {
  final String taskId;
  final String taskTitle;
  final List<WatchStepData> steps;
  final int currentStepIndex;
  final int? timerDurationSeconds;

  WatchTaskData({
    required this.taskId,
    required this.taskTitle,
    required this.steps,
    required this.currentStepIndex,
    this.timerDurationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'steps': steps.map((s) => s.toJson()).toList(),
        'currentStepIndex': currentStepIndex,
        'timerDuration': timerDurationSeconds,
      };
}

/// Step data for watch sync
class WatchStepData {
  final String id;
  final String text;
  final bool isCompleted;
  final bool isSkipped;

  WatchStepData({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.isSkipped = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCompleted': isCompleted,
        'isSkipped': isSkipped,
      };
}
