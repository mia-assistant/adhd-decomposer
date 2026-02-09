import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../data/coaches.dart';
import '../../../data/models/coach.dart';
import '../../providers/task_provider.dart';

class CoachPickerPage extends StatefulWidget {
  final VoidCallback onNext;
  
  const CoachPickerPage({super.key, required this.onNext});

  @override
  State<CoachPickerPage> createState() => _CoachPickerPageState();
}

class _CoachPickerPageState extends State<CoachPickerPage> {
  CoachType? _selectedCoach;
  
  final List<Coach> _coaches = [
    Coaches.zen,
    Coaches.cheerleader,
    Coaches.drill,
    Coaches.friend,
  ];

  void _selectCoach(Coach coach) {
    setState(() => _selectedCoach = coach.type);
    
    // Save selection
    final provider = context.read<TaskProvider>();
    provider.setSelectedCoach(coach.type);
    
    // Auto-advance after brief delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          Text(
            'Pick your vibe',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Different coaching styles for different moods',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView.builder(
              itemCount: _coaches.length,
              itemBuilder: (context, index) {
                final coach = _coaches[index];
                final isSelected = _selectedCoach == coach.type;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CoachCard(
                    coach: coach,
                    isSelected: isSelected,
                    onTap: () => _selectCoach(coach),
                  ),
                ).animate()
                    .fadeIn(delay: Duration(milliseconds: 200 + index * 80))
                    .slideX(begin: 0.15, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CoachCard({
    required this.coach,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Coach avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    coach.avatar,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Coach info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coach.tagline,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
