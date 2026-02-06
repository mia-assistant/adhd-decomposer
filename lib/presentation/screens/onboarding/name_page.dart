import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NamePage extends StatefulWidget {
  final ValueChanged<String?> onSubmit;
  
  const NamePage({super.key, required this.onSubmit});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          Text(
            'What should we\ncall you?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn()
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Optional, but it makes things friendlier',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 40),
          
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Your name or nickname',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            onSubmitted: (_) => _submit(),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
          
          const Spacer(),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onSubmit(null),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.5, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  void _submit() {
    final name = _controller.text.trim();
    widget.onSubmit(name.isEmpty ? null : name);
  }
}
