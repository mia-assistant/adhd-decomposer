import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/task_provider.dart';
import '../../core/constants/strings.dart';
import 'execute_screen.dart';
import 'paywall_screen.dart';

class DecomposeScreen extends StatefulWidget {
  const DecomposeScreen({super.key});

  @override
  State<DecomposeScreen> createState() => _DecomposeScreenState();
}

class _DecomposeScreenState extends State<DecomposeScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUsageLimit();
      _focusNode.requestFocus();
    });
  }
  
  void _checkUsageLimit() {
    final provider = context.read<TaskProvider>();
    if (!provider.canDecompose) {
      // Show paywall immediately if limit reached
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaywallScreen(
            showSkip: false,
            onPurchaseComplete: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newTask),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildLoadingState(context);
          }
          return _buildInputState(context, provider);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.decomposing,
            style: Theme.of(context).textTheme.headlineMedium,
          )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: const Duration(seconds: 2)),
          const SizedBox(height: 8),
          Text(
            'Breaking your task into tiny steps...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildInputState(BuildContext context, TaskProvider provider) {
    final remaining = provider.remainingFreeDecompositions;
    final showRemainingBanner = !provider.isPremium && 
                                 !provider.hasCustomApiKey && 
                                 remaining > 0 && 
                                 remaining <= 3;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showRemainingBanner) ...[
            _buildRemainingBanner(context, remaining),
            const SizedBox(height: 16),
          ],
          Text(
            AppStrings.whatNeedsToBeDone,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            "I'll break it down into tiny, doable steps.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: AppStrings.taskPlaceholder,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _decompose(provider),
          ),
          const SizedBox(height: 16),
          _buildSuggestions(context),
          const Spacer(),
          ElevatedButton(
            onPressed: _controller.text.trim().isEmpty 
              ? null 
              : () => _decompose(provider),
            child: const Text(AppStrings.breakItDown),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildRemainingBanner(BuildContext context, int remaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: remaining == 1 
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            remaining == 1 ? Icons.warning_amber_rounded : Icons.info_outline,
            color: remaining == 1 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              remaining == 1
                  ? 'Last free breakdown! Upgrade for unlimited.'
                  : '$remaining free breakdowns left',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showPaywall(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3, end: 0);
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = [
      'Clean the kitchen',
      'Do laundry',
      'Process inbox',
      'Organize desk',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((s) => ActionChip(
        label: Text(s),
        onPressed: () {
          _controller.text = s;
          setState(() {});
        },
      )).toList(),
    );
  }
  
  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(
          onSkip: () => Navigator.of(context).pop(),
          onPurchaseComplete: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _decompose(TaskProvider provider) async {
    if (_controller.text.trim().isEmpty) return;
    
    // Check if can decompose before attempting
    if (!provider.canDecompose) {
      _showPaywall(context);
      return;
    }

    final task = await provider.decomposeTask(_controller.text.trim());
    
    if (task != null && mounted) {
      provider.setActiveTask(task);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ExecuteScreen()),
      );
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
      provider.clearError();
    }
  }
}
