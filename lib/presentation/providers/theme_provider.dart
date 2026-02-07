import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Theme mode preference for the app
enum ThemePreference {
  system,
  light,
  dark,
}

/// Provider for managing app theme with persistence
class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyThemePreference = 'themePreference';
  
  Box<dynamic>? _box;
  ThemePreference _preference = ThemePreference.system;
  
  ThemePreference get preference => _preference;
  
  /// Get the actual ThemeMode to use based on preference
  ThemeMode get themeMode {
    switch (_preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }
  
  /// Initialize the provider - must be called before use
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box?.get(_keyThemePreference, defaultValue: 'system') as String;
    _preference = _preferenceFromString(stored);
    notifyListeners();
  }
  
  /// Set the theme preference
  void setPreference(ThemePreference preference) {
    if (_preference != preference) {
      _preference = preference;
      _box?.put(_keyThemePreference, _preferenceToString(preference));
      notifyListeners();
    }
  }
  
  /// Convert preference to string for storage
  String _preferenceToString(ThemePreference pref) {
    switch (pref) {
      case ThemePreference.light:
        return 'light';
      case ThemePreference.dark:
        return 'dark';
      case ThemePreference.system:
        return 'system';
    }
  }
  
  /// Convert string to preference
  ThemePreference _preferenceFromString(String value) {
    switch (value) {
      case 'light':
        return ThemePreference.light;
      case 'dark':
        return ThemePreference.dark;
      default:
        return ThemePreference.system;
    }
  }
  
  /// Get display name for a preference
  static String getDisplayName(ThemePreference pref) {
    switch (pref) {
      case ThemePreference.system:
        return 'System';
      case ThemePreference.light:
        return 'Light';
      case ThemePreference.dark:
        return 'Dark';
    }
  }
  
  /// Get icon for a preference
  static IconData getIcon(ThemePreference pref) {
    switch (pref) {
      case ThemePreference.system:
        return Icons.brightness_auto;
      case ThemePreference.light:
        return Icons.light_mode;
      case ThemePreference.dark:
        return Icons.dark_mode;
    }
  }
}
