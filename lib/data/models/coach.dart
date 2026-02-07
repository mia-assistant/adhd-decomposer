/// AI Coach personality types for different moods/preferences
enum CoachType {
  zen,        // Calm, mindful
  cheerleader, // High energy, enthusiastic
  drill,      // No-nonsense, direct
  friend,     // Warm, casual
  default_,   // Standard balanced
}

/// Represents an AI Coach personality with unique messages and style
class Coach {
  final CoachType type;
  final String name;
  final String avatar;  // Emoji
  final String tagline;
  final List<String> completionMessages;
  final List<String> stuckMessages;
  final List<String> greetings;
  final String promptStyle; // For AI decomposition tone

  const Coach({
    required this.type,
    required this.name,
    required this.avatar,
    required this.tagline,
    required this.completionMessages,
    required this.stuckMessages,
    required this.greetings,
    required this.promptStyle,
  });
  
  /// Get a random completion message
  String getRandomCompletionMessage() {
    return completionMessages[DateTime.now().millisecondsSinceEpoch % completionMessages.length];
  }
  
  /// Get a random stuck message
  String getRandomStuckMessage() {
    return stuckMessages[DateTime.now().millisecondsSinceEpoch % stuckMessages.length];
  }
  
  /// Get a random greeting
  String getRandomGreeting() {
    return greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];
  }
}
