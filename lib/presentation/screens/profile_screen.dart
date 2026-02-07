import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../data/services/xp_service.dart';
import '../../data/services/settings_service.dart';
import '../../data/models/player_profile.dart';

/// Minimum touch target size for accessibility (48x48dp per WCAG guidelines)
const double kMinTouchTarget = 48.0;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  bool _celebrationShown = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Check for pending level up celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForLevelUp();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkForLevelUp() {
    if (_celebrationShown) return;
    
    final xpService = context.read<XPService>();
    final levelUp = xpService.pendingLevelUp;
    
    if (levelUp != null) {
      _celebrationShown = true;
      _showLevelUpCelebration(levelUp);
    }
  }

  void _showLevelUpCelebration(LevelUpEvent levelUp) {
    _confettiController.play();
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _LevelUpDialog(
        levelUp: levelUp,
        onDismiss: () {
          Navigator.of(ctx).pop();
          context.read<XPService>().clearPendingLevelUp();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Stack(
        children: [
          Consumer<XPService>(
            builder: (context, xpService, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLevelSection(context, xpService),
                  const SizedBox(height: 24),
                  _buildXPStats(context, xpService),
                  const SizedBox(height: 24),
                  _buildTitlesSection(context, xpService),
                  const SizedBox(height: 24),
                  _buildThemesSection(context, xpService),
                  const SizedBox(height: 24),
                  _buildSoundsSection(context, xpService),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF4ECDC4),
                Color(0xFFFF6B6B),
                Color(0xFFFFBE76),
                Color(0xFF7BC47F),
                Color(0xFF9B59B6),
                Color(0xFFFFD700),
              ],
              numberOfParticles: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSection(BuildContext context, XPService xpService) {
    final profile = xpService.profile;
    final titleInfo = PlayerTitle.getTitleForLevel(profile.level);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Level badge
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${profile.level}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'LEVEL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.8, 0.8), duration: const Duration(milliseconds: 400), curve: Curves.elasticOut),
          
          const SizedBox(height: 16),
          
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titleInfo.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                profile.currentTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // XP progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${xpService.profile.totalXP} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${xpService.xpForNextLevel} XP',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: xpService.progressToNextLevel,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${((1 - xpService.progressToNextLevel) * (xpService.xpForNextLevel - xpService.profile.totalXP + xpService.getXPForLevel(xpService.level))).round()} XP to Level ${profile.level + 1}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildXPStats(BuildContext context, XPService xpService) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.today,
            label: 'Today',
            value: '+${xpService.xpEarnedToday} XP',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_view_week,
            label: 'This Week',
            value: '+${xpService.xpEarnedThisWeek} XP',
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildTitlesSection(BuildContext context, XPService xpService) {
    final profile = xpService.profile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Unlock new titles as you level up',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ...PlayerTitle.all.map((title) {
          final isUnlocked = profile.level >= title.requiredLevel;
          final isActive = profile.currentTitle == title.title;
          
          return _UnlockableItem(
            emoji: isUnlocked ? title.emoji : '🔒',
            name: title.title,
            subtitle: 'Level ${title.requiredLevel}',
            isUnlocked: isUnlocked,
            isActive: isActive,
            onTap: null, // Titles are auto-assigned
          );
        }),
      ],
    );
  }

  Widget _buildThemesSection(BuildContext context, XPService xpService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Themes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your app appearance',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ...UnlockableTheme.all.map((theme) {
          final isUnlocked = xpService.isThemeUnlocked(theme.id);
          final isActive = xpService.selectedTheme == theme.id;
          
          return _UnlockableItem(
            emoji: isUnlocked ? theme.emoji : '🔒',
            name: theme.name,
            subtitle: isUnlocked ? 'Tap to select' : 'Level ${theme.requiredLevel}',
            isUnlocked: isUnlocked,
            isActive: isActive,
            onTap: isUnlocked ? () => xpService.selectTheme(theme.id) : null,
          );
        }),
      ],
    );
  }

  Widget _buildSoundsSection(BuildContext context, XPService xpService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Celebration Sounds',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your victory tune',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ...UnlockableSound.all.map((sound) {
          final isUnlocked = xpService.isSoundUnlocked(sound.id);
          final isActive = xpService.selectedSound == sound.id;
          
          return _UnlockableItem(
            emoji: isUnlocked ? sound.emoji : '🔒',
            name: sound.name,
            subtitle: isUnlocked ? 'Tap to select' : 'Level ${sound.requiredLevel}',
            isUnlocked: isUnlocked,
            isActive: isActive,
            onTap: isUnlocked ? () => xpService.selectSound(sound.id) : null,
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideY(begin: 0.2, end: 0);
  }
}

class _UnlockableItem extends StatelessWidget {
  final String emoji;
  final String name;
  final String subtitle;
  final bool isUnlocked;
  final bool isActive;
  final VoidCallback? onTap;

  const _UnlockableItem({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.isUnlocked,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : isUnlocked
              ? null
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnlocked
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelUpDialog extends StatelessWidget {
  final LevelUpEvent levelUp;
  final VoidCallback onDismiss;

  const _LevelUpDialog({
    required this.levelUp,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars animation
            const Text(
              '⭐',
              style: TextStyle(fontSize: 48),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: const Duration(milliseconds: 500)),
            
            const SizedBox(height: 16),
            
            Text(
              'LEVEL UP!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut),
            
            const SizedBox(height: 24),
            
            // Level badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  '${levelUp.newLevel}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                .animate()
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut, duration: const Duration(milliseconds: 800)),
            
            const SizedBox(height: 24),
            
            // Unlocks
            if (levelUp.hasUnlocks) ...[
              Text(
                'New Unlocks!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              // Themes unlocked
              ...levelUp.unlockedThemes.map((themeId) {
                final theme = UnlockableTheme.all.firstWhere((t) => t.id == themeId);
                return _UnlockItem(emoji: theme.emoji, name: theme.name);
              }),
              
              // Sounds unlocked
              ...levelUp.unlockedSounds.map((soundId) {
                final sound = UnlockableSound.all.firstWhere((s) => s.id == soundId);
                return _UnlockItem(emoji: sound.emoji, name: sound.name);
              }),
              
              // New title
              if (levelUp.newTitle != null) ...[
                _UnlockItem(
                  emoji: PlayerTitle.all.firstWhere((t) => t.title == levelUp.newTitle).emoji,
                  name: levelUp.newTitle!,
                ),
              ],
              
              const SizedBox(height: 16),
            ],
            
            SizedBox(
              height: kMinTouchTarget,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                child: const Text('Awesome! 🎉'),
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 600)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 200))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}

class _UnlockItem extends StatelessWidget {
  final String emoji;
  final String name;

  const _UnlockItem({required this.emoji, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400))
        .slideX(begin: -0.2, end: 0);
  }
}
