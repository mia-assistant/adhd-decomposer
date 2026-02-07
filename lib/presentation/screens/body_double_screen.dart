import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/task_provider.dart';
import '../../data/services/ambient_audio_service.dart';
import '../../data/services/sound_service.dart';

/// Body Double Mode - Digital presence for focus and accountability
/// 
/// Body doubling is when someone with ADHD works alongside another person.
/// This creates a calming digital companion for focus sessions.
class BodyDoubleScreen extends StatefulWidget {
  const BodyDoubleScreen({super.key});

  @override
  State<BodyDoubleScreen> createState() => _BodyDoubleScreenState();
}

class _BodyDoubleScreenState extends State<BodyDoubleScreen>
    with TickerProviderStateMixin {
  // Audio
  final AmbientAudioService _ambientAudio = AmbientAudioService();
  final SoundService _soundService = SoundService();
  double _volume = 0.5;
  bool _isMuted = false;
  
  // Timer - Pomodoro style
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes default
  bool _isWorkSession = true;
  bool _timerRunning = false;
  bool _showBreakPrompt = false;
  
  // Session tracking
  DateTime? _sessionStart;
  int _completedPomodoros = 0;
  
  // Encouragement messages
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _particleController;
  
  // Particles
  final List<_FloatingParticle> _particles = [];
  final Random _random = Random();
  
  // UI state - controls visibility
  bool _showControls = true;
  Timer? _hideControlsTimer;
  
  static const List<String> _encouragements = [
    "You're doing great. Keep going.",
    "One step at a time.",
    "I'm right here with you.",
    "Just focus on this one thing.",
    "No rush. Steady progress.",
    "You've got this.",
    "Breathe. You're making progress.",
    "Every small step counts.",
  ];

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    
    // Keep screen awake during focus session
    // TODO: Re-enable wakelock when plugin is updated
    
    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Pulse animation for presence indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Initialize particles
    _initParticles();
    
    // Cycle encouragement messages every 30 seconds
    _messageTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _encouragements.length;
        });
      }
    });
    
    // Initialize audio
    _ambientAudio.initialize();
    
    // Load default ambient sound from settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultAmbientSound();
      _startHideControlsTimer();
    });
  }
  
  void _loadDefaultAmbientSound() {
    final provider = context.read<TaskProvider>();
    final defaultSound = provider.defaultAmbientSound;
    
    // Convert DefaultAmbientSound to AmbientSound
    AmbientSound sound;
    switch (defaultSound) {
      case DefaultAmbientSound.cafe:
        sound = AmbientSound.cafe;
        break;
      case DefaultAmbientSound.rain:
        sound = AmbientSound.rain;
        break;
      case DefaultAmbientSound.whiteNoise:
        sound = AmbientSound.whiteNoise;
        break;
      case DefaultAmbientSound.none:
        sound = AmbientSound.none;
        break;
    }
    
    if (sound != AmbientSound.none) {
      _selectSound(sound);
    }
  }

  void _initParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(_FloatingParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speed: _random.nextDouble() * 0.0003 + 0.0001,
        opacity: _random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    // Record session time in stats
    if (_sessionStart != null) {
      final sessionMinutes = DateTime.now().difference(_sessionStart!).inMinutes;
      if (sessionMinutes > 0) {
        final provider = context.read<TaskProvider>();
        provider.recordBodyDoubleMinutes(sessionMinutes);
      }
    }
    
    _timer?.cancel();
    _messageTimer?.cancel();
    _hideControlsTimer?.cancel();
    _pulseController.dispose();
    _particleController.dispose();
    _ambientAudio.stop();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // Allow screen to sleep again
    // Screen can sleep again
    
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_showBreakPrompt) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTapAnywhere() {
    setState(() => _showControls = true);
    _startHideControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Dark/muted color scheme for focus
    final backgroundColor = isDark 
        ? const Color(0xFF1a1a2e) 
        : const Color(0xFF2d2d44);
    
    return GestureDetector(
      onTap: _onTapAnywhere,
      onVerticalDragEnd: (details) {
        // Swipe down to exit
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Floating particles background
              _buildParticles(context),
              
              // Main content - always visible
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header with controls (animated visibility)
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildHeader(context),
                    ),
                    
                    const Spacer(),
                    
                    // Avatar with pulse - always visible
                    _buildAvatar(context),
                    
                    const SizedBox(height: 24),
                    
                    // Encouragement message - always visible
                    _buildEncouragementMessage(context),
                    
                    const SizedBox(height: 32),
                    
                    // Current step (if active) - always visible
                    _buildCurrentStep(context),
                    
                    const Spacer(),
                    
                    // Timer - animated visibility
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 200),
                      child: _buildTimer(context),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Audio controls - animated visibility
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: !_showControls,
                        child: _buildAudioControls(context),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Break prompt overlay
              if (_showBreakPrompt) _buildBreakPrompt(context),
              
              // Swipe hint at bottom
              if (_showControls)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Swipe down to exit',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final sessionDuration = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;
    final hours = sessionDuration.inHours;
    final minutes = sessionDuration.inMinutes % 60;
    
    return Row(
      children: [
        Semantics(
          label: 'Close body double mode',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Exit focus mode',
          ),
        ),
        const Spacer(),
        // Session time
        Semantics(
          label: 'Session time: ${hours > 0 ? '$hours hours and ' : ''}$minutes minutes',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                hours > 0 
                    ? '${hours}h ${minutes}m' 
                    : '${minutes}m',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Completed pomodoros
        if (_completedPomodoros > 0)
          Semantics(
            label: '$_completedPomodoros focus sessions completed',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 2),
                Text(
                  '$_completedPomodoros',
                  style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        const SizedBox(width: 48), // Balance the close button
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    const baseColor = Color(0xFF6366f1);
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.08);
        final glowOpacity = 0.2 + (_pulseController.value * 0.15);
        
        return Semantics(
          label: 'Digital companion presence indicator',
          child: Container(
            width: 120 * scale,
            height: 120 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(glowOpacity),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withOpacity(0.8),
                      baseColor.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 32,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEncouragementMessage(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final reduceAnimations = provider.reduceAnimations;
    
    final message = Text(
      _encouragements[_currentMessageIndex],
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.8),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
    
    return Semantics(
      label: 'Encouragement: ${_encouragements[_currentMessageIndex]}',
      liveRegion: true,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: reduceAnimations ? 0 : 500),
        child: SizedBox(
          key: ValueKey(_currentMessageIndex),
          height: 60,
          child: Center(
            child: reduceAnimations 
                ? message 
                : message.animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final task = provider.activeTask;
        final step = task?.currentStep;
        
        if (step == null) {
          return const SizedBox.shrink();
        }
        
        return Semantics(
          label: 'Current step: ${step.action}',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'CURRENT FOCUS',
                  style: TextStyle(
                    color: const Color(0xFF6366f1).withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.action,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimer(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    final isBreak = !_isWorkSession;
    final sessionLabel = isBreak ? 'Break Time' : 'Focus Time';
    
    // Progress for visual ring
    final totalSeconds = _isWorkSession ? 25 * 60 : 5 * 60;
    final progress = 1 - (_secondsRemaining / totalSeconds);
    
    return Semantics(
      label: '$sessionLabel: $minutes minutes and $seconds seconds remaining',
      child: Column(
        children: [
          // Session type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isBreak 
                  ? Colors.green.withOpacity(0.2) 
                  : const Color(0xFF6366f1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sessionLabel,
              style: TextStyle(
                color: isBreak 
                    ? Colors.green.shade300 
                    : const Color(0xFF818cf8),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Timer display with progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isBreak ? Colors.green.shade400 : const Color(0xFF6366f1),
                  ),
                ),
              ),
              // Time display
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Timer controls (only show when controls visible)
          if (_showControls)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset button
                Semantics(
                  label: 'Reset timer',
                  button: true,
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.6)),
                    onPressed: _resetTimer,
                    tooltip: 'Reset',
                  ),
                ),
                const SizedBox(width: 16),
                
                // Play/Pause button
                Semantics(
                  label: _timerRunning ? 'Pause timer' : 'Start timer',
                  button: true,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _toggleTimer,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFF6366f1),
                        foregroundColor: Colors.white,
                      ),
                      child: Icon(
                        _timerRunning ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Skip button
                Semantics(
                  label: _isWorkSession ? 'Skip to break' : 'Skip to work session',
                  button: true,
                  child: IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white.withOpacity(0.6)),
                    onPressed: _skipSession,
                    tooltip: _isWorkSession ? 'Take break' : 'Back to work',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context) {
    final currentSound = _ambientAudio.currentSound;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Sound selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AmbientSound.values.map((sound) {
              final isSelected = currentSound == sound;
              return Expanded(
                child: Semantics(
                  label: '${AmbientAudioService.getLabel(sound)} sound${isSelected ? ', selected' : ''}',
                  button: true,
                  selected: isSelected,
                  child: GestureDetector(
                    onTap: () => _selectSound(sound),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF6366f1).withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected 
                            ? Border.all(color: const Color(0xFF6366f1))
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSoundIcon(sound),
                            size: 24,
                            color: isSelected 
                                ? const Color(0xFF818cf8)
                                : Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AmbientAudioService.getLabel(sound),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected 
                                  ? const Color(0xFF818cf8)
                                  : Colors.white.withOpacity(0.4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Volume slider (only show if sound is selected)
          if (currentSound != AmbientSound.none) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Semantics(
                  label: _isMuted ? 'Unmute' : 'Mute',
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    onPressed: _toggleMute,
                    iconSize: 20,
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: 'Volume: ${(_volume * 100).round()} percent',
                    slider: true,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        activeTrackColor: const Color(0xFF6366f1),
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _isMuted ? 0 : _volume,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                            _isMuted = false;
                          });
                          _ambientAudio.setVolume(_volume);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticles(BuildContext context) {
    final provider = context.read<TaskProvider>();
    if (provider.reduceAnimations) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            time: _particleController.value,
            color: const Color(0xFF6366f1),
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildBreakPrompt(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Semantics(
          label: 'Break time! Would you like to continue with another focus session?',
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d44),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isWorkSession ? Icons.coffee : Icons.self_improvement,
                  size: 48,
                  color: const Color(0xFF6366f1),
                ),
                const SizedBox(height: 16),
                Text(
                  _isWorkSession ? 'Time for a break!' : 'Ready to focus again?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isWorkSession 
                      ? 'You earned it. Take 5 minutes.' 
                      : 'One more pomodoro?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Semantics(
                      label: 'End session',
                      button: true,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showBreakPrompt = false);
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Text("I'm done"),
                      ),
                    ),
                    Semantics(
                      label: _isWorkSession ? 'Start break' : 'Start another focus session',
                      button: true,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showBreakPrompt = false;
                            if (!_isWorkSession) {
                              _completedPomodoros++;
                              // Record pomodoro in stats
                              final provider = context.read<TaskProvider>();
                              provider.recordPomodoroCompleted();
                            }
                            _isWorkSession = !_isWorkSession;
                            _secondsRemaining = _isWorkSession ? 25 * 60 : 5 * 60;
                            _timerRunning = true;
                          });
                          _startTimerTick();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366f1),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_isWorkSession ? 'Take break' : 'One more!'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData _getSoundIcon(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.none:
        return Icons.volume_off;
      case AmbientSound.cafe:
        return Icons.coffee;
      case AmbientSound.rain:
        return Icons.water_drop;
      case AmbientSound.whiteNoise:
        return Icons.waves;
    }
  }

  void _toggleTimer() {
    setState(() {
      _timerRunning = !_timerRunning;
    });
    
    if (_timerRunning) {
      _startTimerTick();
    } else {
      _timer?.cancel();
    }
  }

  void _startTimerTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && _timerRunning) {
        setState(() {
          _secondsRemaining--;
        });
      } else if (_secondsRemaining == 0) {
        timer.cancel();
        _timerRunning = false;
        HapticFeedback.mediumImpact();
        // Play gentle chime
        _soundService.playTimerEnd();
        setState(() {
          _showBreakPrompt = true;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _secondsRemaining = _isWorkSession ? 25 * 60 : 5 * 60;
    });
  }

  void _skipSession() {
    _timer?.cancel();
    setState(() {
      if (_isWorkSession) {
        // Skip to break - count as completed pomodoro
        _isWorkSession = false;
        _secondsRemaining = 5 * 60;
        _completedPomodoros++;
        // Record pomodoro in stats
        final provider = context.read<TaskProvider>();
        provider.recordPomodoroCompleted();
      } else {
        // Skip back to work
        _isWorkSession = true;
        _secondsRemaining = 25 * 60;
      }
      _timerRunning = false;
    });
  }

  void _selectSound(AmbientSound sound) {
    setState(() {});
    _ambientAudio.play(sound);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _ambientAudio.setMuted(_isMuted);
  }
}

/// Floating particle for calm visual effect
class _FloatingParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Custom painter for floating particles
class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double time;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.time,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Slow, gentle upward drift
      final y = (particle.y - (time * particle.speed * 100)) % 1.0;
      final x = particle.x + sin(time * 2 * pi + particle.y * 10) * 0.02;
      
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
