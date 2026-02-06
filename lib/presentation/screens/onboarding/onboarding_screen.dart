import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/services/settings_service.dart';
import 'welcome_page.dart';
import 'challenge_page.dart';
import 'name_page.dart';
import 'ready_page.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _selectedChallenge;
  String? _userName;
  
  late final SettingsService _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = SettingsService();
    _initSettings();
  }
  
  Future<void> _initSettings() async {
    await _settings.initialize();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }
  
  void _onChallengeSelected(String challenge) {
    setState(() => _selectedChallenge = challenge);
    _settings.userChallenge = challenge;
    _nextPage();
  }
  
  void _onNameSubmitted(String? name) {
    setState(() => _userName = name);
    if (name != null && name.isNotEmpty) {
      _settings.userName = name;
    }
    _nextPage();
  }
  
  void _completeOnboarding() {
    _settings.onboardingComplete = true;
    widget.onComplete();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: index <= _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ).animate(target: index <= _currentPage ? 1 : 0)
                      .scaleX(begin: 0.5, end: 1, alignment: Alignment.centerLeft)
                      .fadeIn();
                }),
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  WelcomePage(onNext: _nextPage),
                  ChallengePage(
                    selectedChallenge: _selectedChallenge,
                    onChallengeSelected: _onChallengeSelected,
                  ),
                  NamePage(onSubmit: _onNameSubmitted),
                  ReadyPage(
                    userName: _userName,
                    onStart: _completeOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
