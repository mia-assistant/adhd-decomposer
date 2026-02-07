import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DemoPage extends StatefulWidget {
  final VoidCallback onNext;
  
  const DemoPage({super.key, required this.onNext});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _showInput = true;
  bool _isDecomposing = false;
  bool _showSteps = false;
  int _visibleSteps = 0;
  int _completedSteps = 0;
  bool _showCelebration = false;
  
  final _demoTask = "Clean my room";
  final _demoSteps = [
    "Grab a trash bag from the kitchen",
    "Walk around and pick up obvious trash",
    "Put dirty clothes in the laundry basket",
    "Make your bed (just pull the covers up!)",
    "Clear off your desk surface",
    "Take a breath - you did it! 🎉",
  ];
  
  void _startDemo() async {
    setState(() {
      _showInput = false;
      _isDecomposing = true;
    });
    
    // Simulate AI thinking
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isDecomposing = false;
      _showSteps = true;
    });
    
    // Reveal steps one by one
    for (int i = 0; i < _demoSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() => _visibleSteps = i + 1);
      }
    }
  }
  
  void _completeStep(int index) async {
    if (index != _completedSteps) return;
    
    setState(() => _completedSteps++);
    
    // If all steps completed, show celebration
    if (_completedSteps == _demoSteps.length) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _showCelebration = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          
          // Title
          Text(
            'See it in action',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Watch how Tiny Steps breaks down a task',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 32),
          
          // Demo card
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _showCelebration
                  ? _buildCelebration(context)
                  : _showSteps
                      ? _buildSteps(context)
                      : _isDecomposing
                          ? _buildDecomposing(context)
                          : _buildInput(context),
            ),
          ),
          
          const Spacer(),
          
          // Continue button (shown after celebration)
          if (_showCelebration)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onNext,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('That\'s amazing! Continue'),
              ),
            ).animate().fadeIn().slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildInput(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Fake input field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _demoTask,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
        
        const SizedBox(height: 24),
        
        // Tap to start
        FilledButton.icon(
          onPressed: _startDemo,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Break it down'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),
      ],
    );
  }
  
  Widget _buildDecomposing(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(delay: Duration(milliseconds: index * 200))
                .then()
                .fadeOut(delay: const Duration(milliseconds: 400));
          }),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Breaking down "$_demoTask"...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSteps(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _demoTask,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${_demoSteps.length} tiny steps • ~15 min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Steps list
          ...List.generate(_demoSteps.length, (index) {
            if (index >= _visibleSteps) return const SizedBox.shrink();
            
            final isCompleted = index < _completedSteps;
            final isCurrent = index == _completedSteps;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                    : isCurrent
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: isCurrent ? () => _completeStep(index) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Checkbox
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Step text
                        Expanded(
                          child: Text(
                            _demoSteps[index],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                  : null,
                            ),
                          ),
                        ),
                        
                        // Tap hint for current
                        if (isCurrent)
                          Text(
                            'Tap!',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                              .fadeIn()
                              .then()
                              .fadeOut(delay: 500.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn().slideX(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }
  
  Widget _buildCelebration(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Confetti emoji
        Text(
          '🎉',
          style: const TextStyle(fontSize: 64),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
            .then()
            .shake(),
        
        const SizedBox(height: 16),
        
        Text(
          'Task complete!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ).animate().fadeIn().slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'See how easy that was?\nTiny steps make big tasks feel doable.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),
      ],
    );
  }
}
