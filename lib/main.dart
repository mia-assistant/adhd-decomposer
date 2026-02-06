import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/settings_service.dart';
import 'data/services/stats_service.dart';
import 'data/services/achievements_service.dart';
import 'data/services/widget_service.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/decompose_screen.dart';
import 'presentation/screens/execute_screen.dart';

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
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(ADHDDecomposerApp(
    settings: settings,
    stats: stats,
    achievements: achievements,
  ));
}

class ADHDDecomposerApp extends StatefulWidget {
  final SettingsService settings;
  final StatsService stats;
  final AchievementsService achievements;
  
  const ADHDDecomposerApp({
    super.key,
    required this.settings,
    required this.stats,
    required this.achievements,
  });

  @override
  State<ADHDDecomposerApp> createState() => _ADHDDecomposerAppState();
}

class _ADHDDecomposerAppState extends State<ADHDDecomposerApp> {
  late bool _showOnboarding;
  String? _initialRoute;
  
  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.settings.onboardingComplete;
    _handleWidgetLaunch();
    _listenToWidgetClicks();
  }
  
  Future<void> _handleWidgetLaunch() async {
    final uri = await WidgetService.getInitialUri();
    if (uri != null) {
      setState(() {
        _initialRoute = uri.host;
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
  
  void _navigateToRoute(String route) {
    final context = navigatorKey.currentContext;
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
            MaterialPageRoute(
              builder: (_) => ExecuteScreen(task: taskProvider.activeTask!),
            ),
          );
        } else if (taskProvider.activeTasks.isNotEmpty) {
          // Set the first active task as active and navigate
          final task = taskProvider.activeTasks.first;
          taskProvider.setActiveTask(task);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ExecuteScreen(task: task)),
          );
        }
        break;
    }
  }
  
  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            settings: widget.settings,
            stats: widget.stats,
            achievements: widget.achievements,
          )..initialize(),
        ),
        Provider.value(value: widget.settings),
        Provider.value(value: widget.stats),
        ChangeNotifierProvider.value(value: widget.achievements),
      ],
      child: MaterialApp(
        title: 'Tiny Steps',
        navigatorKey: navigatorKey,
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
