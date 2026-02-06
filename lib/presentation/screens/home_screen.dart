import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../../core/constants/strings.dart';
import '../../data/models/task.dart';
import 'decompose_screen.dart';
import 'execute_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.tasks.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildTaskList(context, provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToDecompose(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newTask),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noTasksYet,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.startByAdding,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, TaskProvider provider) {
    final activeTasks = provider.activeTasks;
    final completedTasks = provider.completedTasks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (activeTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'In Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...activeTasks.map((task) => _TaskCard(
            task: task,
            onTap: () => _startTask(context, task),
            onDelete: () => provider.deleteTask(task.id),
          )),
        ],
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Completed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...completedTasks.map((task) => _TaskCard(
            task: task,
            onTap: null,
            onDelete: () => provider.deleteTask(task.id),
          )),
        ],
      ],
    );
  }

  void _navigateToDecompose(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DecomposeScreen()),
    );
  }

  void _startTask(BuildContext context, Task task) {
    context.read<TaskProvider>().setActiveTask(task);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExecuteScreen()),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted 
                          ? Theme.of(context).textTheme.bodyMedium?.color 
                          : null,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      iconSize: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.totalEstimatedMinutes} min',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.checklist,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.completedStepsCount}/${task.steps.length} steps',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (!isCompleted && task.progress > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
