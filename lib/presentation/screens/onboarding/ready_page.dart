import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReadyPage extends StatelessWidget {
  final String? userName;
  final VoidCallback onStart;
  
  const ReadyPage({
    super.key,
    required this.userName,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = userName != null && userName!.isNotEmpty
        ? 'Ready, $userName?'
        : 'Ready to start?';
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Celebratory icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              size: 64,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),
          
          const SizedBox(height: 48),
          
          Text(
            greeting,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            'Let\'s break down your first task\ninto tiny, doable steps.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 32),
          
          // Quick tips
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _TipRow(
                  emoji: '💡',
                  text: 'Start with something you\'ve been putting off',
                ),
                const SizedBox(height: 12),
                _TipRow(
                  emoji: '⏱️',
                  text: 'Each step will be 5 minutes or less',
                ),
                const SizedBox(height: 12),
                _TipRow(
                  emoji: '🎉',
                  text: 'Celebrate every completed step!',
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.3, end: 0),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Break Down My First Task'),
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.5, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String emoji;
  final String text;
  
  const _TipRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
