import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  
  const WelcomePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // App icon/illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),
          
          const SizedBox(height: 48),
          
          Text(
            'Tiny Steps',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            'Big tasks feel overwhelming?\nLet\'s break them into tiny,\nmanageable steps.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, end: 0),
          
          const Spacer(),
          
          // Feature highlights
          _FeatureRow(
            icon: Icons.psychology_outlined,
            text: 'AI breaks down your tasks',
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 12),
          
          _FeatureRow(
            icon: Icons.timer_outlined,
            text: 'Each step takes minutes, not hours',
          ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 12),
          
          _FeatureRow(
            icon: Icons.celebration_outlined,
            text: 'Celebrate every tiny win',
          ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Get Started'),
            ),
          )
              .animate()
              .fadeIn(delay: 1000.ms)
              .slideY(begin: 0.5, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
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
