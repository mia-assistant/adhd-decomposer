import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/task_provider.dart';
import '../../core/constants/strings.dart';
import '../../data/models/task.dart';
import '../../data/services/sound_service.dart';

class ExecuteScreen extends StatefulWidget {
  const ExecuteScreen({super.key});

  @override
  State<ExecuteScreen> createState() => _ExecuteScreenState();
}

class _ExecuteScreenState extends State<ExecuteScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  final SoundService _soundService = SoundService();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _timerRunning = false;
  int? _selectedMinutes;
  bool _showCelebration = false;
  String? _celebrationMessage;
  
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<TaskProvider>(
            builder: (context, provider, _) {
              final task = provider.activeTask;
              if (task == null) {
                return const Center(child: Text('No active task'));
              }
              
              if (task.isCompleted) {
                return _buildCompletionScreen(context, task);
              }
              
              return _buildExecutionScreen(context, provider, task);
            },
          ),
          // Confetti overlay
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _showExitConfirmation(context),
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress
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
            
            const Spacer(),
            
            // Current step - big and prominent
            Container(
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
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
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
            )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300)),
            
            const SizedBox(height: 24),
            
            // Timer section
            _buildTimerSection(context, step),
            
            const Spacer(),
            
            // Action buttons
            ElevatedButton(
              onPressed: () => _completeStep(provider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                AppStrings.done,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _skipStep(provider),
                    child: const Text(AppStrings.skip),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showStuckDialog(context, step),
                    child: const Text(AppStrings.imStuck),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
    
    return Column(
      children: [
        Text(
          'Optional timer',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: options.map((mins) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActiveTimer(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    
    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _toggleTimer,
          child: Text(_timerRunning ? AppStrings.pause : AppStrings.resume),
        ),
      ],
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
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _timerRunning = !_timerRunning;
    });
  }

  void _completeStep(TaskProvider provider) {
    HapticFeedback.mediumImpact();
    _confettiController.play();
    _soundService.playStepComplete();
    
    final message = Encouragements.stepComplete[
      _random.nextInt(Encouragements.stepComplete.length)
    ];
    
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

  void _skipStep(TaskProvider provider) {
    HapticFeedback.lightImpact();
    provider.skipCurrentStep();
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 0;
      _timerRunning = false;
      _selectedMinutes = null;
    });
  }

  Widget _buildCelebrationOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
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
        )
          .animate()
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: const Duration(milliseconds: 200))
          .then()
          .shake(hz: 3, duration: const Duration(milliseconds: 300)),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, Task task) {
    // Play confetti on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showCelebration) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
        _soundService.playTaskComplete();
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.youDidIt,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              Encouragements.taskComplete[
                _random.nextInt(Encouragements.taskComplete.length)
              ],
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
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
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(AppStrings.backToTasks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
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
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave task?'),
        content: const Text("Your progress is saved. You can continue later."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Leave'),
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
            Text(
              "That's okay!",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Let's break it down even smaller.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildMiniStep(context, '1. Take a deep breath'),
            _buildMiniStep(context, '2. Stand up from your chair'),
            _buildMiniStep(context, '3. Walk to where you need to be'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Got it, I'll try"),
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
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
