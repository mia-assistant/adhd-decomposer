/// Screenshot automation tests for App Store listing.
/// 
/// Run with:
/// ```bash
/// flutter drive \
///   --driver=test_driver/integration_test.dart \
///   --target=integration_test/screenshot_test.dart \
///   --dart-define=SCREENSHOT_MODE=true
/// ```
/// 
/// Screenshots are saved to `screenshots/raw/` with naming:
/// - 01_onboarding_en.png
/// - 02_decompose_en.png
/// - etc.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:adhd_decomposer/main.dart';
import 'package:adhd_decomposer/core/theme/app_theme.dart';
import 'package:adhd_decomposer/data/services/settings_service.dart';
import 'package:adhd_decomposer/data/services/stats_service.dart';
import 'package:adhd_decomposer/data/services/achievements_service.dart';
import 'package:adhd_decomposer/data/services/notification_service.dart';
import 'package:adhd_decomposer/data/services/calendar_service.dart';
import 'package:adhd_decomposer/data/services/routine_service.dart';
import 'package:adhd_decomposer/presentation/providers/task_provider.dart';
import 'package:adhd_decomposer/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:adhd_decomposer/presentation/screens/onboarding/welcome_page.dart';
import 'package:adhd_decomposer/presentation/screens/decompose_screen.dart';
import 'package:adhd_decomposer/presentation/screens/execute_screen.dart';
import 'package:adhd_decomposer/presentation/screens/stats_screen.dart';
import 'package:adhd_decomposer/presentation/screens/templates_screen.dart';
import 'package:adhd_decomposer/presentation/screens/home_screen.dart';
import 'package:adhd_decomposer/data/models/task.dart';

import 'screenshot_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Check if we're in screenshot mode
  const isScreenshotMode = bool.fromEnvironment('SCREENSHOT_MODE', defaultValue: false);
  
  group('App Store Screenshots', () {
    late SettingsService settings;
    late StatsService stats;
    late AchievementsService achievements;
    late NotificationService notifications;
    late CalendarService calendar;
    late RoutineService routines;
    
    setUpAll(() async {
      // Initialize Hive for local storage
      await Hive.initFlutter();
    });
    
    setUp(() async {
      // Initialize all services fresh for each test
      settings = SettingsService();
      await settings.initialize();
      
      stats = StatsService();
      await stats.initialize();
      
      achievements = AchievementsService();
      await achievements.initialize(stats);
      
      notifications = NotificationService();
      // Skip notification initialization in tests
      
      calendar = CalendarService();
      // Skip calendar initialization in tests
      
      routines = RoutineService();
      await routines.initialize();
    });

    testWidgets('Screenshot 1: Onboarding Welcome', (tester) async {
      // Build the onboarding welcome page
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: WelcomePage(onNext: () {}),
        ),
      );
      
      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Take screenshot
      await binding.takeScreenshot('01_onboarding_en');
    });

    testWidgets('Screenshot 2: Decompose Screen', (tester) async {
      // Build the decompose screen with pre-filled text
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => TaskProvider(
                  settings: settings,
                  stats: stats,
                  achievements: achievements,
                  notifications: notifications,
                )..initialize(),
              ),
              Provider.value(value: settings),
            ],
            child: const DecomposeScreenForScreenshot(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Enter task text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Prepare presentation for Monday');
      await tester.pumpAndSettle();
      
      await binding.takeScreenshot('02_decompose_en');
    });

    testWidgets('Screenshot 3: Execute Screen', (tester) async {
      // Create a task in progress
      final task = Task(
        id: 'screenshot_task',
        title: 'Clean the kitchen',
        steps: [
          TaskStep(
            id: 'step_1',
            action: 'Clear the countertops',
            estimatedMinutes: 3,
            isCompleted: true,
          ),
          TaskStep(
            id: 'step_2',
            action: 'Load the dishwasher',
            estimatedMinutes: 5,
            isCompleted: true,
          ),
          TaskStep(
            id: 'step_3',
            action: 'Wipe down the stovetop',
            estimatedMinutes: 4,
            isCompleted: false,
          ),
          TaskStep(
            id: 'step_4',
            action: 'Clean the sink',
            estimatedMinutes: 3,
            isCompleted: false,
          ),
          TaskStep(
            id: 'step_5',
            action: 'Take out the trash',
            estimatedMinutes: 2,
            isCompleted: false,
          ),
        ],
        totalEstimatedMinutes: 17,
        createdAt: DateTime.now(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) {
                  final provider = TaskProvider(
                    settings: settings,
                    stats: stats,
                    achievements: achievements,
                    notifications: notifications,
                  );
                  provider.initialize();
                  provider.addTask(task);
                  provider.setActiveTask(task);
                  return provider;
                },
              ),
              Provider.value(value: settings),
              Provider.value(value: stats),
              ChangeNotifierProvider.value(value: achievements),
              Provider.value(value: notifications),
              Provider.value(value: calendar),
            ],
            child: const ExecuteScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      await binding.takeScreenshot('03_execute_en');
    });

    testWidgets('Screenshot 4: Celebration', (tester) async {
      // Create a completed task
      final completedTask = Task(
        id: 'completed_task',
        title: 'Organize my desk',
        steps: [
          TaskStep(
            id: 'step_1',
            action: 'Remove everything from desk',
            estimatedMinutes: 2,
            isCompleted: true,
          ),
          TaskStep(
            id: 'step_2',
            action: 'Wipe down the surface',
            estimatedMinutes: 3,
            isCompleted: true,
          ),
          TaskStep(
            id: 'step_3',
            action: 'Sort papers into piles',
            estimatedMinutes: 5,
            isCompleted: true,
          ),
          TaskStep(
            id: 'step_4',
            action: 'File or discard papers',
            estimatedMinutes: 5,
            isCompleted: true,
          ),
          TaskStep(
            id: 'step_5',
            action: 'Arrange items neatly',
            estimatedMinutes: 3,
            isCompleted: true,
          ),
        ],
        totalEstimatedMinutes: 18,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        completedAt: DateTime.now(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) {
                  final provider = TaskProvider(
                    settings: settings,
                    stats: stats,
                    achievements: achievements,
                    notifications: notifications,
                  );
                  provider.initialize();
                  provider.addTask(completedTask);
                  provider.setActiveTask(completedTask);
                  return provider;
                },
              ),
              Provider.value(value: settings),
              Provider.value(value: stats),
              ChangeNotifierProvider.value(value: achievements),
              Provider.value(value: notifications),
              Provider.value(value: calendar),
            ],
            child: const ExecuteScreen(),
          ),
        ),
      );
      
      // Wait for celebration animation
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await binding.takeScreenshot('04_celebration_en');
    });

    testWidgets('Screenshot 5: Templates Browser', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => TaskProvider(
                  settings: settings,
                  stats: stats,
                  achievements: achievements,
                  notifications: notifications,
                )..initialize(),
              ),
              Provider.value(value: settings),
            ],
            child: const TemplatesScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await binding.takeScreenshot('05_templates_en');
    });

    testWidgets('Screenshot 6: Stats Screen', (tester) async {
      // Pre-populate stats with impressive data
      await _populateStatsForScreenshot(stats);
      await _populateAchievementsForScreenshot(achievements, stats);
      
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: MultiProvider(
            providers: [
              Provider.value(value: stats),
              ChangeNotifierProvider.value(value: achievements),
            ],
            child: const StatsScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      await binding.takeScreenshot('06_stats_en');
    });
  });
}

/// Helper to populate stats with screenshot-friendly data
Future<void> _populateStatsForScreenshot(StatsService stats) async {
  // Record tasks to build up stats
  // The exact implementation depends on StatsService API
  for (var i = 0; i < 47; i++) {
    stats.recordTaskCompleted(stepsCompleted: 5, minutesWorked: 19);
  }
  
  // Build a streak
  for (var i = 0; i < 7; i++) {
    stats.recordDayActive();
  }
}

/// Helper to unlock achievements for screenshot
Future<void> _populateAchievementsForScreenshot(
  AchievementsService achievements,
  StatsService stats,
) async {
  // Achievements auto-unlock based on stats
  // This depends on the achievements system implementation
}

/// A wrapper for DecomposeScreen that allows screenshot customization
class DecomposeScreenForScreenshot extends StatelessWidget {
  const DecomposeScreenForScreenshot({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecomposeScreen();
  }
}
