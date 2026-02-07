/// Player profile for gamification features
class PlayerProfile {
  int level;
  int currentXP;
  int totalXP;
  List<String> unlockedThemes;
  List<String> unlockedSounds;
  List<String> unlockedCoaches;
  String currentTitle;
  String selectedTheme;
  String selectedSound;

  PlayerProfile({
    this.level = 1,
    this.currentXP = 0,
    this.totalXP = 0,
    List<String>? unlockedThemes,
    List<String>? unlockedSounds,
    List<String>? unlockedCoaches,
    this.currentTitle = 'Task Novice',
    this.selectedTheme = 'default',
    this.selectedSound = 'default',
  })  : unlockedThemes = unlockedThemes ?? ['default'],
        unlockedSounds = unlockedSounds ?? ['default'],
        unlockedCoaches = unlockedCoaches ?? [];

  /// Create from JSON map
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      level: json['level'] as int? ?? 1,
      currentXP: json['currentXP'] as int? ?? 0,
      totalXP: json['totalXP'] as int? ?? 0,
      unlockedThemes: (json['unlockedThemes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['default'],
      unlockedSounds: (json['unlockedSounds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['default'],
      unlockedCoaches: (json['unlockedCoaches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      currentTitle: json['currentTitle'] as String? ?? 'Task Novice',
      selectedTheme: json['selectedTheme'] as String? ?? 'default',
      selectedSound: json['selectedSound'] as String? ?? 'default',
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'currentXP': currentXP,
      'totalXP': totalXP,
      'unlockedThemes': unlockedThemes,
      'unlockedSounds': unlockedSounds,
      'unlockedCoaches': unlockedCoaches,
      'currentTitle': currentTitle,
      'selectedTheme': selectedTheme,
      'selectedSound': selectedSound,
    };
  }

  /// Copy with updated values
  PlayerProfile copyWith({
    int? level,
    int? currentXP,
    int? totalXP,
    List<String>? unlockedThemes,
    List<String>? unlockedSounds,
    List<String>? unlockedCoaches,
    String? currentTitle,
    String? selectedTheme,
    String? selectedSound,
  }) {
    return PlayerProfile(
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      totalXP: totalXP ?? this.totalXP,
      unlockedThemes: unlockedThemes ?? List.from(this.unlockedThemes),
      unlockedSounds: unlockedSounds ?? List.from(this.unlockedSounds),
      unlockedCoaches: unlockedCoaches ?? List.from(this.unlockedCoaches),
      currentTitle: currentTitle ?? this.currentTitle,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedSound: selectedSound ?? this.selectedSound,
    );
  }
}

/// Theme definition with level requirement
class UnlockableTheme {
  final String id;
  final String name;
  final String emoji;
  final int requiredLevel;

  const UnlockableTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.requiredLevel,
  });

  static const List<UnlockableTheme> all = [
    UnlockableTheme(id: 'default', name: 'Default', emoji: '🎨', requiredLevel: 1),
    UnlockableTheme(id: 'sunset_coral', name: 'Sunset Coral', emoji: '🌅', requiredLevel: 3),
    UnlockableTheme(id: 'deep_ocean', name: 'Deep Ocean', emoji: '🌊', requiredLevel: 5),
    UnlockableTheme(id: 'forest_calm', name: 'Forest Calm', emoji: '🌲', requiredLevel: 8),
    UnlockableTheme(id: 'midnight', name: 'Midnight', emoji: '🌙', requiredLevel: 12),
  ];
}

/// Celebration sound with level requirement
class UnlockableSound {
  final String id;
  final String name;
  final String emoji;
  final int requiredLevel;

  const UnlockableSound({
    required this.id,
    required this.name,
    required this.emoji,
    required this.requiredLevel,
  });

  static const List<UnlockableSound> all = [
    UnlockableSound(id: 'default', name: 'Default Chime', emoji: '🔔', requiredLevel: 1),
    UnlockableSound(id: 'arcade', name: 'Arcade', emoji: '🎮', requiredLevel: 4),
    UnlockableSound(id: 'nature', name: 'Nature', emoji: '🍃', requiredLevel: 7),
    UnlockableSound(id: 'magic', name: 'Magic', emoji: '✨', requiredLevel: 10),
  ];
}

/// Player title with level requirement
class PlayerTitle {
  final String title;
  final int requiredLevel;
  final String emoji;

  const PlayerTitle({
    required this.title,
    required this.requiredLevel,
    required this.emoji,
  });

  static const List<PlayerTitle> all = [
    PlayerTitle(title: 'Task Novice', requiredLevel: 1, emoji: '🌱'),
    PlayerTitle(title: 'Step Apprentice', requiredLevel: 3, emoji: '🚶'),
    PlayerTitle(title: 'Focus Warrior', requiredLevel: 5, emoji: '⚔️'),
    PlayerTitle(title: 'Productivity Ninja', requiredLevel: 10, emoji: '🥷'),
    PlayerTitle(title: 'Task Master', requiredLevel: 15, emoji: '👑'),
    PlayerTitle(title: 'ADHD Champion', requiredLevel: 20, emoji: '🏆'),
    PlayerTitle(title: 'Legendary Achiever', requiredLevel: 25, emoji: '⭐'),
  ];

  /// Get the title for a given level
  static PlayerTitle getTitleForLevel(int level) {
    PlayerTitle result = all.first;
    for (final title in all) {
      if (level >= title.requiredLevel) {
        result = title;
      }
    }
    return result;
  }
}
