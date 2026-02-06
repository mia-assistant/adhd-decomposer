import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/settings_service.dart';
import 'data/services/stats_service.dart';
import 'data/services/achievements_service.dart';
import 'data/services/widget_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/analytics_service.dart';
import 'data/services/calendar_service.dart';
import 'data/services/routine_service.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/decompose_screen.dart';
import 'presentation/screens/execute_screen.dart';
import 'presentation/screens/stats_screen.dart';
import 'presentation/screens/routines_screen.dart';

// Global navigator key for deep linking
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize settings
  final settings = SettingsService();
  await settings.initialize();
  
  // Initialize stats
  final stats = StatsService();
  await stats.initialize();
  
  // Initialize achievements
  final achievements = AchievementsService();
  await achievements.initialize(stats);
  
  // Initialize widget service
  await WidgetService.initialize();
  
  // Initialize notifications
  final notifications = NotificationService();
  await notifications.initialize();
  
  // Initialize analytics (stub for now)
  final analytics = AnalyticsService();
  await analytics.initialize();
  
  // Initialize calendar service
  final calendar = CalendarService();
  await calendar.initialize();
  
  // Initialize routines service
  final routines = RoutineService();
  await routines.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(ADHDDecomposerApp(
    settings: settings,
    stats: stats,
    achievements: achievements,
    notifications: notifications,
    calendar: calendar,
    routines: routines,
  ));
}

class ADHDDecomposerApp extends StatefulWidget {
  final SettingsService settings;
  final StatsService stats;
  final AchievementsService achievements;
  final NotificationService notifications;
  final CalendarService calendar;
  final RoutineService routines;
  
  const ADHDDecomposerApp({
    super.key,
    required this.settings,
    required this.stats,
    required this.achievements,
    required this.notifications,
    required this.calendar,
    required this.routines,
  });

  @override
  State<ADHDDecomposerApp> createState() => _ADHDDecomposerAppState();
}

class _ADHDDecomposerAppState extends State<ADHDDecomposerApp> {
  late bool _showOnboarding;
  
  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.settings.onboardingComplete;
    _handleWidgetLaunch();
    _listenToWidgetClicks();
    _setupNotificationHandling();
  }
  
  Future<void> _handleWidgetLaunch() async {
    final uri = await WidgetService.getInitialUri();
    if (uri != null) {
      // Navigate after first frame when context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToRoute(uri.host);
      });
    }
  }
  
  void _listenToWidgetClicks() {
    WidgetService.widgetClicked.listen((uri) {
      if (uri != null && mounted) {
        _navigateToRoute(uri.host);
      }
    });
  }
  
  void _setupNotificationHandling() {
    // Set up notification tap callback
    NotificationService.onNotificationTap = (payload) {
      if (payload != null && mounted) {
        // Small delay to ensure navigation context is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          _handleNotificationNavigation(payload);
        });
      }
    };
  }
  
  void _handleNotificationNavigation(String payload) {
    final context = globalNavigatorKey.currentContext;
    if (context == null) return;
    
    switch (payload) {
      case NotificationService.payloadHome:
        // Navigate to home (pop all routes)
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
        
      case NotificationService.payloadExecute:
        // Navigate to execute screen
        _navigateToRoute('execute');
        break;
        
      case NotificationService.payloadStats:
        // Navigate to stats screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        );
        break;
    }
  }
  
  void _navigateToRoute(String route) {
    final context = globalNavigatorKey.currentContext;
    if (context == null) return;
    
    switch (route) {
      case 'decompose':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DecomposeScreen()),
        );
        break;
      case 'execute':
        // Navigate to execute screen if there's an active task
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        if (taskProvider.activeTask != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExecuteScreen()),
          );
        } else if (taskProvider.activeTasks.isNotEmpty) {
          // Set the first active task as active and navigate
          final task = taskProvider.activeTasks.first;
          taskProvider.setActiveTask(task);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExecuteScreen()),
          );
        }
        break;
      case 'stats':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        );
        break;
      case 'routines':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RoutinesScreen()),
        );
        break;
    }
  }
  
  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            settings: widget.settings,
            stats: widget.stats,
            achievements: widget.achievements,
            notifications: widget.notifications,
          )..initialize(),
        ),
        Provider.value(value: widget.settings),
        Provider.value(value: widget.stats),
        ChangeNotifierProvider.value(value: widget.achievements),
        Provider.value(value: widget.notifications),
        Provider.value(value: widget.calendar),
        ChangeNotifierProvider.value(value: widget.routines),
      ],
      child: MaterialApp(
        title: 'Tiny Steps',
        navigatorKey: globalNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: _showOnboarding
            ? OnboardingScreen(onComplete: _completeOnboarding)
            : const HomeScreen(),
      ),
    );
  }
}
