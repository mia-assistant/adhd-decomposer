import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/task_provider.dart';
import '../widgets/share_card.dart';
import '../widgets/rate_app_dialog.dart';
import '../../core/constants/strings.dart';
import '../../data/models/task.dart';
import '../../data/services/sound_service.dart';
import '../../data/services/share_service.dart';
import '../../data/services/stats_service.dart';
import '../../data/services/settings_service.dart';
import '../../data/services/analytics_service.dart';

/// Minimum touch target size for accessibility (48x48dp per WCAG guidelines)
const double kMinTouchTarget = 48.0;

class ExecuteScreen extends StatefulWidget {
  const ExecuteScreen({super.key});

  @override
  State<ExecuteScreen> createState() => _ExecuteScreenState();
}

class _ExecuteScreenState extends State<ExecuteScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  final SoundService _soundService = SoundService();
  final GlobalKey _shareCardKey = GlobalKey();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _timerRunning = false;
  int? _selectedMinutes;
  bool _showCelebration = false;
  String? _celebrationMessage;
  bool _hasTriggeredCompletion = false;
  
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timer?.cancel();
    super.dispose();
  }
  
  /// Check if animations should be reduced based on settings or system preferences
  bool _shouldReduceAnimations(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final mediaQuery = MediaQuery.of(context);
    return provider.reduceAnimations || mediaQuery.disableAnimations;
  }
  
  /// Check if confetti should be shown
  bool _shouldShowConfetti(BuildContext context) {
    final provider = context.read<TaskProvider>();
    return provider.confettiEnabled && !_shouldReduceAnimations(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<TaskProvider>(
            builder: (context, provider, _) {
              final task = provider.activeTask;
              if (task == null) {
                return Center(
                  child: Semantics(
                    label: 'No active task. Please go back and select a task.',
                    child: const Text('No active task'),
                  ),
                );
              }
              
              if (task.isCompleted) {
                return _buildCompletionScreen(context, task);
              }
              
              return _buildExecutionScreen(context, provider, task);
            },
          ),
          // Confetti overlay - only show if enabled and animations not reduced
          if (_shouldShowConfetti(context))
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF4ECDC4),
                  Color(0xFFFF6B6B),
                  Color(0xFFFFBE76),
                  Color(0xFF7BC47F),
                  Color(0xFF9B59B6),
                ],
                numberOfParticles: 30,
              ),
            ),
          // Celebration overlay
          if (_showCelebration)
            _buildCelebrationOverlay(context),
        ],
      ),
    );
  }

  Widget _buildExecutionScreen(BuildContext context, TaskProvider provider, Task task) {
    final step = task.currentStep!;
    final stepNum = task.currentStepIndex + 1;
    final totalSteps = task.steps.length;
    final reduceAnimations = _shouldReduceAnimations(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with proper accessibility
            Row(
              children: [
                Semantics(
                  label: 'Close task and return to home',
                  button: true,
                  child: SizedBox(
                    width: kMinTouchTarget,
                    height: kMinTouchTarget,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _showExitConfirmation(context),
                      tooltip: 'Close task',
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: 'Current task: ${task.title}',
                    header: true,
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: kMinTouchTarget), // Balance the close button
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress with accessibility
            Semantics(
              label: 'Progress: ${(task.progress * 100).round()} percent complete. Step $stepNum of $totalSteps',
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: task.progress,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.step} $stepNum ${AppStrings.of_} $totalSteps',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Current step - big and prominent with semantics
            Semantics(
              label: 'Current step: ${step.action}. Estimated time: ${step.estimatedMinutes} minutes',
              liveRegion: true,
              child: _buildStepCard(context, step, reduceAnimations),
            ),
            
            const SizedBox(height: 24),
            
            // Timer section
            _buildTimerSection(context, step),
            
            const Spacer(),
            
            // Action buttons with proper touch targets and semantics
            _buildActionButtons(context, provider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepCard(BuildContext context, TaskStep step, bool reduceAnimations) {
    final card = Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            step.action,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              height: 1.3, // Improved line spacing for dyslexia
            ),
            textAlign: TextAlign.left, // Left-align for readability
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                semanticLabel: 'Estimated time',
              ),
              const SizedBox(width: 8),
              Text(
                '~${step.estimatedMinutes} min',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
    
    // Skip animations if reduced motion is preferred
    if (reduceAnimations) {
      return card;
    }
    
    return card
      .animate()
      .fadeIn(duration: const Duration(milliseconds: 300))
      .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300));
  }
  
  Widget _buildActionButtons(BuildContext context, TaskProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main "Done" button with proper touch target
        Semantics(
          label: 'Mark step as done',
          button: true,
          hint: 'Double tap to complete this step',
          child: SizedBox(
            height: max(kMinTouchTarget, 56), // Ensure minimum touch target
            child: ElevatedButton(
              onPressed: () => _completeStep(provider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                AppStrings.done,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Skip this step',
                button: true,
                hint: 'Double tap to skip to the next step',
                child: SizedBox(
                  height: kMinTouchTarget,
                  child: OutlinedButton(
                    onPressed: () => _skipStep(provider),
                    child: const Text(AppStrings.skip),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                label: "I'm stuck on this step",
                button: true,
                hint: 'Double tap for help breaking down this step into smaller parts',
                child: SizedBox(
                  height: kMinTouchTarget,
                  child: OutlinedButton(
                    onPressed: () => _showStuckDialog(context, provider.activeTask!.currentStep!),
                    child: const Text(AppStrings.imStuck),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerSection(BuildContext context, TaskStep step) {
    if (_timerRunning || _secondsRemaining > 0) {
      return _buildActiveTimer(context);
    }
    
    return _buildTimerOptions(context, step);
  }

  Widget _buildTimerOptions(BuildContext context, TaskStep step) {
    final options = [5, 10, 15, 25];
    
    return Semantics(
      label: 'Optional timer. Choose a duration to set a focus timer.',
      child: Column(
        children: [
          Text(
            'Optional timer',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: options.map((mins) => Semantics(
              label: '$mins minute timer',
              button: true,
              selected: _selectedMinutes == mins,
              child: SizedBox(
                height: kMinTouchTarget,
                child: ChoiceChip(
                  label: Text('$mins min'),
                  selected: _selectedMinutes == mins,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMinutes = selected ? mins : null;
                    });
                    if (selected) {
                      _startTimer(mins);
                    }
                  },
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return Semantics(
      label: 'Timer: $minutes minutes and $seconds seconds remaining',
      liveRegion: true,
      child: Column(
        children: [
          Text(
            timeString,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: _timerRunning ? 'Pause timer' : 'Resume timer',
            button: true,
            child: SizedBox(
              height: kMinTouchTarget,
              child: TextButton(
                onPressed: _toggleTimer,
                child: Text(_timerRunning ? AppStrings.pause : AppStrings.resume),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer(int minutes) {
    setState(() {
      _secondsRemaining = minutes * 60;
      _timerRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && _timerRunning) {
        setState(() {
          _secondsRemaining--;
        });
      } else if (_secondsRemaining == 0) {
        timer.cancel();
        _timerRunning = false;
        HapticFeedback.heavyImpact();
        _soundService.playTimerEnd();
        // Announce timer completion for screen readers
        SemanticsService.announce('Timer complete', TextDirection.ltr);
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _timerRunning = !_timerRunning;
    });
  }

  void _completeStep(TaskProvider provider) {
    final reduceAnimations = _shouldReduceAnimations(context);
    
    if (provider.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    if (_shouldShowConfetti(context)) {
      _confettiController.play();
    }
    
    if (provider.soundEnabled) {
      _soundService.playStepComplete();
    }
    
    // Record timer usage if a timer was active
    if (_selectedMinutes != null) {
      final minutesUsed = _selectedMinutes! - (_secondsRemaining ~/ 60);
      if (minutesUsed > 0) {
        provider.recordTimerUsage(minutesUsed);
      }
    }
    
    final message = Encouragements.stepComplete[
      _random.nextInt(Encouragements.stepComplete.length)
    ];
    
    // Announce completion for screen readers
    SemanticsService.announce('Step completed! $message', TextDirection.ltr);
    
    // Check if auto-advance is enabled
    final autoAdvance = provider.autoAdvanceEnabled;
    
    if (reduceAnimations || !autoAdvance) {
      // Skip celebration overlay, advance immediately
      provider.completeCurrentStep();
      _timer?.cancel();
      _secondsRemaining = 0;
      _timerRunning = false;
      _selectedMinutes = null;
    } else {
      setState(() {
        _showCelebration = true;
        _celebrationMessage = message;
      });
      
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
          provider.completeCurrentStep();
          _timer?.cancel();
          _secondsRemaining = 0;
          _timerRunning = false;
          _selectedMinutes = null;
        }
      });
    }
  }

  void _skipStep(TaskProvider provider) {
    if (provider.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    // Announce skip for screen readers
    SemanticsService.announce('Step skipped', TextDirection.ltr);
    
    provider.skipCurrentStep();
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 0;
      _timerRunning = false;
      _selectedMinutes = null;
    });
  }

  Widget _buildCelebrationOverlay(BuildContext context) {
    final reduceAnimations = _shouldReduceAnimations(context);
    
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        _celebrationMessage ?? 'Nice!',
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    
    return Semantics(
      label: 'Celebration: ${_celebrationMessage ?? 'Nice!'}',
      liveRegion: true,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: reduceAnimations
              ? content
              : content
                  .animate()
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: const Duration(milliseconds: 200)),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, Task task) {
    // Play confetti on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasTriggeredCompletion) {
        _hasTriggeredCompletion = true;
        final provider = context.read<TaskProvider>();
        
        if (_shouldShowConfetti(context)) {
          _confettiController.play();
        }
        
        if (provider.hapticEnabled) {
          HapticFeedback.heavyImpact();
        }
        
        if (provider.soundEnabled) {
          _soundService.playTaskComplete();
        }
        
        // Track task completion and check for rate prompt
        _onTaskCompleted(context, task);
        
        // Announce completion for screen readers
        SemanticsService.announce(
          'Congratulations! You completed ${task.title}. ${task.completedStepsCount} steps done.',
          TextDirection.ltr,
        );
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Celebration icon',
              child: Icon(
                Icons.celebration,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                AppStrings.youDidIt,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Encouragements.taskComplete[
                _random.nextInt(Encouragements.taskComplete.length)
              ],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5, // Improved line spacing
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Semantics(
              label: 'Task summary: ${task.title}. ${task.completedStepsCount} steps completed, ${task.steps.where((s) => s.isSkipped).length} steps skipped.',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          context,
                          '${task.completedStepsCount}',
                          'Steps Done',
                        ),
                        _buildStatItem(
                          context,
                          '${task.steps.where((s) => s.isSkipped).length}',
                          'Skipped',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Share button with proper touch target
            Semantics(
              label: 'Share your achievement',
              button: true,
              child: SizedBox(
                height: kMinTouchTarget,
                child: OutlinedButton.icon(
                  onPressed: () => _showShareCard(context, task),
                  icon: const Icon(Icons.share),
                  label: const Text('Share Achievement'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Return to task list',
              button: true,
              child: SizedBox(
                height: kMinTouchTarget,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(AppStrings.backToTasks),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _onTaskCompleted(BuildContext context, Task task) {
    final settings = context.read<SettingsService>();
    
    // Track analytics
    AnalyticsService.trackTaskCompleted(task);
    
    // Check for rate prompt
    settings.incrementTasksSinceLastAsk();
    
    // Small delay before showing rate dialog to not interrupt celebration
    if (settings.shouldShowRatePrompt) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          settings.recordRatePromptShown();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => RateAppDialog(settings: settings),
          );
        }
      });
    }
  }
  
  void _showShareCard(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Share Your Achievement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show the world what you accomplished!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Share card preview
            RepaintBoundary(
              key: _shareCardKey,
              child: CompletionShareCard(
                taskName: task.title,
                stepsCompleted: task.completedStepsCount,
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Share to social media',
              button: true,
              child: SizedBox(
                height: kMinTouchTarget,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final statsService = context.read<StatsService>();
                    Navigator.pop(ctx);
                    await ShareService.captureAndShare(
                      key: _shareCardKey,
                      shareText: 'I just completed "${task.title}" using Tiny Steps! 🎉 #TinySteps #ProductivityWin',
                      subject: 'My Tiny Steps Achievement',
                    );
                    // Track the share
                    statsService.recordShare();
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Semantics(
      label: '$value $label',
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Semantics(
          header: true,
          child: const Text('Leave task?'),
        ),
        content: const Text("Your progress is saved. You can continue later."),
        actions: [
          Semantics(
            label: 'Stay and continue working on this task',
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Stay'),
            ),
          ),
          Semantics(
            label: 'Leave and return to home screen',
            button: true,
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Leave'),
            ),
          ),
        ],
      ),
    );
  }

  void _showStuckDialog(BuildContext context, TaskStep step) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                "That's okay!",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's break it down even smaller.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Mini steps to help you get started',
              child: Column(
                children: [
                  _buildMiniStep(context, '1. Take a deep breath'),
                  _buildMiniStep(context, '2. Stand up from your chair'),
                  _buildMiniStep(context, '3. Walk to where you need to be'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Close help dialog and try again',
              button: true,
              child: SizedBox(
                height: kMinTouchTarget,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Got it, I'll try"),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStep(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            child: Icon(
              Icons.arrow_forward,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
              semanticLabel: 'Step indicator',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.4, // Better line spacing
              ),
            ),
          ),
        ],
      ),
    );
  }
}
