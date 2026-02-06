import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/settings_service.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize settings
  final settings = SettingsService();
  await settings.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(ADHDDecomposerApp(settings: settings));
}

class ADHDDecomposerApp extends StatefulWidget {
  final SettingsService settings;
  
  const ADHDDecomposerApp({super.key, required this.settings});

  @override
  State<ADHDDecomposerApp> createState() => _ADHDDecomposerAppState();
}

class _ADHDDecomposerAppState extends State<ADHDDecomposerApp> {
  late bool _showOnboarding;
  
  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.settings.onboardingComplete;
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
          create: (_) => TaskProvider(settings: widget.settings)..initialize(),
        ),
        Provider.value(value: widget.settings),
      ],
      child: MaterialApp(
        title: 'Tiny Steps',
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
