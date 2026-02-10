import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../../data/models/task.dart';
import '../../data/coaches.dart';
import 'execute_screen.dart';

/// Shows a summary of all steps before starting task execution.
/// Helps users understand what they're about to do and reduces anxiety.
class TaskSummaryScreen extends StatelessWidget {
  const TaskSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final task = provider.activeTask;
        if (task == null) {
          return const Scaffold(
            body: Center(child: Text('No task selected')),
          );
        }

        final coach = Coaches.getByType(provider.selectedCoachType);
        final totalMinutes = task.steps.fold<int>(
          0,
          (sum, step) => sum + step.estimatedMinutes,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                provider.setActiveTask(null);
                Navigator.of(context).pop();
              },
            ),
            title: const Text('Your Plan'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Task title card
                      _buildHeaderCard(context, task, totalMinutes, coach),
                      const SizedBox(height: 24),
                      
                      // Steps list
                      Text(
                        '${task.steps.length} steps to complete',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ...task.steps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return _buildStepCard(context, index, step)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 50 * index))
                            .slideX(begin: 0.1, end: 0);
                      }),
                      
                      const SizedBox(height: 80), // Space for button
                    ],
                  ),
                ),
              ),
              
              // Start button
              _buildStartButton(context, coach),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, Task task, int totalMinutes, coach) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeString = hours > 0
        ? '${hours}h ${minutes}min'
        : '${minutes} min';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  coach.icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  Icons.format_list_numbered,
                  '${task.steps.length} steps',
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  context,
                  Icons.schedule,
                  '~$timeString',
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, int index, TaskStep step) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.action,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '~${step.estimatedMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, coach) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              coach.getRandomGreeting(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ExecuteScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("Let's Start!"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
