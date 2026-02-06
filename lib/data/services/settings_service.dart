import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing app settings persistence
class SettingsService {
  static const String _boxName = 'settings';
  
  // Settings keys
  static const String keyOnboardingComplete = 'onboardingComplete';
  static const String keyUserName = 'userName';
  static const String keyUserChallenge = 'userChallenge';
  static const String keySoundEnabled = 'soundEnabled';
  static const String keyHapticEnabled = 'hapticEnabled';
  static const String keyConfettiEnabled = 'confettiEnabled';
  static const String keyDecompositionCount = 'decompositionCount';
  static const String keyIsPremium = 'isPremium';
  static const String keyOpenAIApiKey = 'openAIApiKey';
  
  static const int freeDecompositionLimit = 3;
  
  Box<dynamic>? _box;
  
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }
  
  Box<dynamic> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('SettingsService not initialized. Call initialize() first.');
    }
    return _box!;
  }
  
  // Onboarding
  bool get onboardingComplete => _safeBox.get(keyOnboardingComplete, defaultValue: false);
  set onboardingComplete(bool value) => _safeBox.put(keyOnboardingComplete, value);
  
  // User info
  String? get userName => _safeBox.get(keyUserName);
  set userName(String? value) => _safeBox.put(keyUserName, value);
  
  String? get userChallenge => _safeBox.get(keyUserChallenge);
  set userChallenge(String? value) => _safeBox.put(keyUserChallenge, value);
  
  // Feedback settings
  bool get soundEnabled => _safeBox.get(keySoundEnabled, defaultValue: true);
  set soundEnabled(bool value) => _safeBox.put(keySoundEnabled, value);
  
  bool get hapticEnabled => _safeBox.get(keyHapticEnabled, defaultValue: true);
  set hapticEnabled(bool value) => _safeBox.put(keyHapticEnabled, value);
  
  bool get confettiEnabled => _safeBox.get(keyConfettiEnabled, defaultValue: true);
  set confettiEnabled(bool value) => _safeBox.put(keyConfettiEnabled, value);
  
  // Usage tracking
  int get decompositionCount => _safeBox.get(keyDecompositionCount, defaultValue: 0);
  set decompositionCount(int value) => _safeBox.put(keyDecompositionCount, value);
  
  void incrementDecompositionCount() {
    decompositionCount = decompositionCount + 1;
  }
  
  bool get hasReachedFreeLimit => !isPremium && decompositionCount >= freeDecompositionLimit;
  
  // Premium status
  bool get isPremium => _safeBox.get(keyIsPremium, defaultValue: false);
  set isPremium(bool value) => _safeBox.put(keyIsPremium, value);
  
  // API key (power user feature)
  String? get openAIApiKey => _safeBox.get(keyOpenAIApiKey);
  set openAIApiKey(String? value) => _safeBox.put(keyOpenAIApiKey, value);
  
  bool get hasCustomApiKey => openAIApiKey != null && openAIApiKey!.isNotEmpty;
  
  // Can decompose (premium, has custom API key, or hasn't hit limit)
  bool get canDecompose => isPremium || hasCustomApiKey || !hasReachedFreeLimit;
  
  int get remainingFreeDecompositions {
    if (isPremium || hasCustomApiKey) return -1; // Unlimited
    return (freeDecompositionLimit - decompositionCount).clamp(0, freeDecompositionLimit);
  }
}
