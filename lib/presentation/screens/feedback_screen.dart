import 'package:flutter/material.dart';
import '../../data/services/analytics_service.dart';

/// Simple feedback form for users who want to share what could be better
/// MVP version just shows success message - no backend submission yet
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  
  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    // Simulate network delay for MVP
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Track the event
    final analytics = AnalyticsService();
    AnalyticsService.trackFeedbackSubmitted(
      hasEmail: _emailController.text.trim().isNotEmpty,
    );
    
    // For MVP: just log and show success
    // ignore: avoid_print
    print('[Feedback] Message: ${_feedbackController.text}');
    if (_emailController.text.isNotEmpty) {
      // ignore: avoid_print
      print('[Feedback] Email: ${_emailController.text}');
    }
    
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
      ),
      body: _isSubmitted
          ? _buildSuccessView(context)
          : _buildFormView(context),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(
              Icons.feedback_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Help us improve',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re building this app for people like you. Your feedback shapes what comes next.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Feedback text field
            TextFormField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'What could be better?',
                hintText: 'Tell us what you\'d like to see improved...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please share your thoughts';
                }
                if (value.trim().length < 10) {
                  return 'A bit more detail would help us';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Optional email field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                hintText: 'If you\'d like us to follow up',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null; // Optional field
                }
                // Basic email validation
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Submit button
            FilledButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Feedback'),
            ),
            const SizedBox(height: 16),
            
            // Privacy note
            Text(
              '💜 Your feedback is private and used only to improve the app.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Thank you!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Your feedback means a lot to us.\nWe\'ll use it to make Tiny Steps even better.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to app'),
          ),
        ],
      ),
    );
  }
}
