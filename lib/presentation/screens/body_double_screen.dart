import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/task_provider.dart';

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
  final AudioPlayer _ambientPlayer = AudioPlayer();
  AmbientSound _currentSound = AmbientSound.none;
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
    
    // Pulse animation for avatar
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
    
    // Cycle encouragement messages
    _messageTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _encouragements.length;
        });
      }
    });
    
    // Set audio to loop
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Load default ambient sound from settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultAmbientSound();
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
    _timer?.cancel();
    _messageTimer?.cancel();
    _pulseController.dispose();
    _particleController.dispose();
    _ambientPlayer.stop();
    _ambientPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1a1a2e) 
          : const Color(0xFFf5f5f7),
      body: SafeArea(
        child: Stack(
          children: [
            // Floating particles background
            _buildParticles(context),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  
                  const SizedBox(height: 32),
                  
                  // Avatar with pulse
                  _buildAvatar(context),
                  
                  const SizedBox(height: 24),
                  
                  // Encouragement message
                  _buildEncouragementMessage(context),
                  
                  const SizedBox(height: 32),
                  
                  // Current step (if active)
                  _buildCurrentStep(context),
                  
                  const Spacer(),
                  
                  // Timer
                  _buildTimer(context),
                  
                  const SizedBox(height: 24),
                  
                  // Audio controls
                  _buildAudioControls(context),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Break prompt overlay
            if (_showBreakPrompt) _buildBreakPrompt(context),
          ],
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
            icon: const Icon(Icons.close),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                hours > 0 
                    ? '${hours}h ${minutes}m' 
                    : '${minutes}m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark 
        ? const Color(0xFF6366f1) 
        : Theme.of(context).colorScheme.primary;
    
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Current Focus',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.action,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  : Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sessionLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isBreak 
                    ? Colors.green 
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Timer display
          Text(
            timeString,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w200,
              letterSpacing: 4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Timer controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset button
              Semantics(
                label: 'Reset timer',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
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
                    ),
                    child: Icon(
                      _timerRunning ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Skip button (to break or back to work)
              Semantics(
                label: _isWorkSession ? 'Skip to break' : 'Skip to work session',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.skip_next),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Sound selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AmbientSound.values.map((sound) {
              final isSelected = _currentSound == sound;
              return Semantics(
                label: '${_getSoundLabel(sound)} sound${isSelected ? ', selected' : ''}',
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () => _selectSound(sound),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected 
                          ? Border.all(color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSoundIcon(sound),
                          size: 24,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSoundLabel(sound),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Volume slider (only show if sound is selected)
          if (_currentSound != AmbientSound.none) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Semantics(
                  label: _isMuted ? 'Unmute' : 'Mute',
                  button: true,
                  child: IconButton(
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                    onPressed: _toggleMute,
                    iconSize: 20,
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: 'Volume: ${(_volume * 100).round()} percent',
                    slider: true,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _isMuted ? 0 : _volume,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                            _isMuted = false;
                          });
                          _ambientPlayer.setVolume(_volume);
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
            color: Theme.of(context).colorScheme.primary,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildBreakPrompt(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Semantics(
          label: 'Break time! Would you like to continue with another focus session?',
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.coffee,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _isWorkSession ? 'Time for a break!' : 'Ready to focus again?',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isWorkSession 
                      ? 'You earned it. Take 5 minutes.' 
                      : 'One more pomodoro?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                            }
                            _isWorkSession = !_isWorkSession;
                            _secondsRemaining = _isWorkSession ? 25 * 60 : 5 * 60;
                            _timerRunning = true;
                          });
                          _startTimerTick();
                        },
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
        // Skip to break
        _isWorkSession = false;
        _secondsRemaining = 5 * 60;
        _completedPomodoros++;
      } else {
        // Skip back to work
        _isWorkSession = true;
        _secondsRemaining = 25 * 60;
      }
      _timerRunning = false;
    });
  }

  void _selectSound(AmbientSound sound) async {
    setState(() {
      _currentSound = sound;
    });
    
    if (sound == AmbientSound.none) {
      await _ambientPlayer.stop();
    } else {
      try {
        // TODO: Replace placeholder paths with real audio files
        // For MVP, these are placeholder assets
        final assetPath = _getSoundAsset(sound);
        await _ambientPlayer.setVolume(_isMuted ? 0 : _volume);
        await _ambientPlayer.play(AssetSource(assetPath));
      } catch (e) {
        debugPrint('Error playing ambient sound: $e');
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _ambientPlayer.setVolume(_isMuted ? 0 : _volume);
  }

  String _getSoundAsset(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.cafe:
        return 'audio/ambient/cafe_ambient.mp3';
      case AmbientSound.rain:
        return 'audio/ambient/rain.mp3';
      case AmbientSound.whiteNoise:
        return 'audio/ambient/white_noise.mp3';
      case AmbientSound.none:
        return '';
    }
  }

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

  String _getSoundLabel(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.none:
        return 'Off';
      case AmbientSound.cafe:
        return 'Café';
      case AmbientSound.rain:
        return 'Rain';
      case AmbientSound.whiteNoise:
        return 'Noise';
    }
  }
}

/// Ambient sound options
enum AmbientSound {
  none,
  cafe,
  rain,
  whiteNoise,
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
