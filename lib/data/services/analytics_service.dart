/// Analytics service for tracking user events
/// Currently a stub implementation - prints to console for debugging
/// Replace with real analytics (Firebase, Mixpanel, etc.) later
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  bool _initialized = false;
  
  /// Initialize analytics service
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _log('Analytics initialized');
  }
  
  /// Track a custom event
  void trackEvent(String eventName, [Map<String, dynamic>? parameters]) {
    _log('EVENT: $eventName${parameters != null ? ' $parameters' : ''}');
  }
  
  /// Track screen view
  void trackScreen(String screenName) {
    _log('SCREEN: $screenName');
  }
  
  /// Set a user property
  void setUserProperty(String name, String value) {
    _log('USER_PROPERTY: $name = $value');
  }
  
  // Convenience methods for common events
  
  /// Track task completion
  void trackTaskCompleted({required int stepsCompleted, required int stepsSkipped}) {
    trackEvent('task_completed', {
      'steps_completed': stepsCompleted,
      'steps_skipped': stepsSkipped,
    });
  }
  
  /// Track step completion
  void trackStepCompleted({bool skipped = false}) {
    trackEvent('step_completed', {'skipped': skipped});
  }
  
  /// Track template usage
  void trackTemplateUsed(String templateId) {
    trackEvent('template_used', {'template_id': templateId});
  }
  
  /// Track feedback submission
  void trackFeedbackSubmitted({required bool hasEmail}) {
    trackEvent('feedback_submitted', {'has_email': hasEmail});
  }
  
  /// Track rate app prompt response
  void trackRateAppResponse(String response) {
    trackEvent('rate_app_response', {'response': response});
  }
  
  /// Track share action
  void trackShare(String contentType) {
    trackEvent('share', {'content_type': contentType});
  }
  
  void _log(String message) {
    // ignore: avoid_print
    print('[Analytics] $message');
  }
}
