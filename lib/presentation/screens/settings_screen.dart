import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildSectionHeader(context, 'Feedback'),
              _buildSwitchTile(
                context,
                icon: Icons.volume_up_outlined,
                title: 'Sound Effects',
                subtitle: 'Play sounds on task completion',
                value: provider.soundEnabled,
                onChanged: (value) => provider.setSoundEnabled(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.vibration_outlined,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                value: provider.hapticEnabled,
                onChanged: (value) => provider.setHapticEnabled(value),
              ),
              _buildSwitchTile(
                context,
                icon: Icons.celebration_outlined,
                title: 'Celebration Animation',
                subtitle: 'Show confetti on task completion',
                value: provider.confettiEnabled,
                onChanged: (value) => provider.setConfettiEnabled(value),
              ),
              const Divider(height: 32),
              _buildSectionHeader(context, 'Data'),
              ListTile(
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Clear All Tasks'),
                subtitle: const Text('Delete all tasks and progress'),
                onTap: () => _showClearConfirmation(context),
              ),
              const Divider(height: 32),
              _buildSectionHeader(context, 'About'),
              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('Tiny Steps'),
                subtitle: const Text('Version 1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Made for ADHD minds'),
                subtitle: const Text('One tiny step at a time'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks?'),
        content: const Text(
          'This will permanently delete all your tasks and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().clearAllTasks();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All tasks cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
