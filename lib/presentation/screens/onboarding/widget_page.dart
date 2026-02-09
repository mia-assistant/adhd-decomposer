import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/services/widget_service.dart';

class WidgetPage extends StatefulWidget {
  final VoidCallback onNext;
  
  const WidgetPage({super.key, required this.onNext});

  @override
  State<WidgetPage> createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  bool _canPinWidget = false;
  bool _pinRequested = false;

  @override
  void initState() {
    super.initState();
    _checkPinSupport();
  }

  Future<void> _checkPinSupport() async {
    if (Platform.isAndroid) {
      final supported = await WidgetService.isWidgetPinSupported();
      if (mounted) {
        setState(() => _canPinWidget = supported);
      }
    }
  }

  Future<void> _requestPin() async {
    final success = await WidgetService.requestPinWidget();
    if (mounted && success) {
      setState(() => _pinRequested = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          
          // Widget illustration
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mock widget preview
                Container(
                  width: 180,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clean the kitchen',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gather supplies',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Step 1 of 5',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            'Add the Widget',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            'See your current step right on your home screen.\nNo need to open the app.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 32),
          
          // Android: show "Add Widget" button when pin is supported
          if (_canPinWidget) ...[
            FilledButton.icon(
              onPressed: _pinRequested ? null : _requestPin,
              icon: Icon(_pinRequested ? Icons.check_rounded : Icons.add_to_home_screen),
              label: Text(_pinRequested ? 'Widget added!' : 'Add Widget to Home Screen'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),
            // Subtle manual instructions as fallback
            Text(
              'Or add it manually:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 12),
          ],
          
          // Manual instructions (always shown on iOS, shown as secondary on Android)
          _buildInstructionStep(
            context,
            icon: Icons.touch_app,
            text: Platform.isIOS 
                ? 'Long-press your home screen'
                : 'Long-press your home screen',
            delay: _canPinWidget ? 650 : 500,
          ),
          const SizedBox(height: 12),
          _buildInstructionStep(
            context,
            icon: Icons.add_circle_outline,
            text: Platform.isIOS 
                ? 'Tap the + button'
                : 'Tap "Widgets"',
            delay: _canPinWidget ? 700 : 600,
          ),
          const SizedBox(height: 12),
          _buildInstructionStep(
            context,
            icon: Icons.search,
            text: 'Search for "Tiny Steps"',
            delay: _canPinWidget ? 750 : 700,
          ),
          
          const Spacer(),
          
          // Skip / Continue buttons
          Row(
            children: [
              TextButton(
                onPressed: widget.onNext,
                child: const Text('Skip for now'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: widget.onNext,
                  child: Text(_pinRequested ? 'Continue' : 'Got it!'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }
  
  Widget _buildInstructionStep(
    BuildContext context, {
    required IconData icon,
    required String text,
    required int delay,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1, end: 0);
  }
}
