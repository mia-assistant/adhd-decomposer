import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'paywall_screen.dart';

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
              // Premium status
              if (!provider.isPremium)
                _buildUpgradeBanner(context, provider),
                
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
              _buildSectionHeader(context, 'Power User'),
              _buildApiKeyTile(context, provider),
              
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
              _buildUsageStats(context, provider),
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
  
  Widget _buildUpgradeBanner(BuildContext context, TaskProvider provider) {
    final remaining = provider.remainingFreeDecompositions;
    
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Pro',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      remaining == -1 
                          ? 'Unlimited breakdowns with your API key'
                          : '$remaining free breakdowns remaining',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
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
  
  Widget _buildApiKeyTile(BuildContext context, TaskProvider provider) {
    final hasKey = provider.hasCustomApiKey;
    
    return ListTile(
      leading: Icon(
        hasKey ? Icons.key : Icons.key_outlined,
        color: hasKey ? Colors.green : null,
      ),
      title: const Text('OpenAI API Key'),
      subtitle: Text(
        hasKey 
            ? 'Custom key configured (unlimited use)'
            : 'Add your own key for unlimited breakdowns',
      ),
      trailing: hasKey 
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showRemoveApiKeyDialog(context, provider),
            )
          : const Icon(Icons.chevron_right),
      onTap: () => _showApiKeyDialog(context, provider),
    );
  }
  
  Widget _buildUsageStats(BuildContext context, TaskProvider provider) {
    final isPremium = provider.isPremium;
    final hasKey = provider.hasCustomApiKey;
    
    String statusText;
    IconData statusIcon;
    Color statusColor;
    
    if (isPremium) {
      statusText = 'Pro (Unlimited)';
      statusIcon = Icons.workspace_premium;
      statusColor = Colors.amber;
    } else if (hasKey) {
      statusText = 'Custom API Key (Unlimited)';
      statusIcon = Icons.key;
      statusColor = Colors.green;
    } else {
      final remaining = provider.remainingFreeDecompositions;
      statusText = remaining > 0 
          ? 'Free ($remaining breakdowns left)'
          : 'Free (limit reached)';
      statusIcon = Icons.person_outline;
      statusColor = Theme.of(context).colorScheme.primary;
    }
    
    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: const Text('Account Status'),
      subtitle: Text(statusText),
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
  
  void _showApiKeyDialog(BuildContext context, TaskProvider provider) {
    final controller = TextEditingController(text: provider.openAIApiKey ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OpenAI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your OpenAI API key to unlock unlimited task decompositions. '
              'Your key is stored locally and never shared.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'sk-...',
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              autocorrect: false,
            ),
            const SizedBox(height: 8),
            Text(
              'Get your key at platform.openai.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final key = controller.text.trim();
              if (key.isEmpty) {
                provider.setOpenAIApiKey(null);
              } else {
                provider.setOpenAIApiKey(key);
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(key.isEmpty ? 'API key removed' : 'API key saved'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showRemoveApiKeyDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove API Key?'),
        content: const Text(
          'This will remove your custom OpenAI API key. You\'ll be limited to free tier usage unless you upgrade to Pro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.setOpenAIApiKey(null);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('API key removed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
