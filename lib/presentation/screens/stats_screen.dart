import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../data/services/stats_service.dart';
import '../../data/services/achievements_service.dart';
import '../../data/services/share_service.dart';
import '../../data/services/siri_service.dart';
import '../widgets/share_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late ConfettiController _confettiController;
  final GlobalKey _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Check for newly unlocked achievements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForCelebration();
      // Donate intent for Siri to learn this pattern
      SiriService().donateStatsViewed();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkForCelebration() {
    final achievements = context.read<AchievementsService>();
    final nextAchievement = achievements.popNewlyUnlocked();
    if (nextAchievement != null) {
      _showAchievementCelebration(nextAchievement);
    }
  }

  void _showAchievementCelebration(Achievement achievement) {
    _confettiController.play();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AchievementUnlockedDialog(
        achievement: achievement,
        onDismiss: () {
          Navigator.of(ctx).pop();
          // Check for more achievements
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _checkForCelebration();
          });
        },
      ),
    );
  }

  void _showShareStatsCard(BuildContext context, StatsService stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Your Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Show off your Tiny Steps journey!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Share card preview
            RepaintBoundary(
              key: _shareCardKey,
              child: StatsShareCard(
                tasksCompleted: stats.totalTasksCompleted,
                currentStreak: stats.currentStreak,
                totalSteps: stats.totalStepsCompleted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await ShareService.captureAndShare(
                  key: _shareCardKey,
                  shareText: 'My Tiny Steps Progress: ${stats.currentStreak} day streak 🔥, ${stats.totalTasksCompleted} tasks completed! #TinySteps #ProductivityWin',
                  subject: 'My Tiny Steps Progress',
                );
                // Track the share
                if (mounted) {
                  stats.recordShare();
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsService>();
    final achievements = context.watch<AchievementsService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Stats',
            onPressed: () => _showShareStatsCard(context, stats),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStreakSection(context, stats),
              const SizedBox(height: 24),
              _buildStatsCards(context, stats),
              const SizedBox(height: 24),
              _buildWeeklyChart(context, stats),
              const SizedBox(height: 24),
              _buildAchievementsSection(context, achievements),
              const SizedBox(height: 32),
            ],
          ),
          // Confetti
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
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, StatsService stats) {
    final streak = stats.currentStreak;
    final message = _getStreakMessage(streak);
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔥',
                style: TextStyle(fontSize: streak > 0 ? 48 : 32),
              ),
              const SizedBox(width: 12),
              Text(
                '$streak',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            streak == 1 ? 'Day Streak' : 'Day Streak',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (stats.longestStreak > stats.currentStreak) ...[
            const SizedBox(height: 8),
            Text(
              'Personal best: ${stats.longestStreak} days',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .scale(begin: const Offset(0.95, 0.95), duration: const Duration(milliseconds: 400));
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) return "Start your streak today!";
    if (streak == 1) return "Great start! Keep it going! 💪";
    if (streak < 3) return "Keep it up! You're building momentum! 🚀";
    if (streak < 7) return "On fire! Don't break the chain! 🔥";
    if (streak < 14) return "Unstoppable! You're crushing it! ⭐";
    if (streak < 30) return "Legendary streak! You're amazing! 🏆";
    return "PHENOMENAL! You're an inspiration! 👑";
  }

  Widget _buildStatsCards(BuildContext context, StatsService stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.task_alt,
                label: 'Tasks Done',
                value: '${stats.totalTasksCompleted}',
                color: const Color(0xFF4ECDC4),
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.checklist,
                label: 'Steps Done',
                value: '${stats.totalStepsCompleted}',
                color: const Color(0xFFFF6B6B),
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                label: 'Pomodoros',
                value: '${stats.totalPomodoros}',
                color: const Color(0xFFFF9500),
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.self_improvement,
                label: 'Focus Time',
                value: _formatMinutes(stats.totalBodyDoubleMinutes),
                color: const Color(0xFF6366F1),
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  Widget _buildWeeklyChart(BuildContext context, StatsService stats) {
    final last7Days = stats.getLast7DaysStats();
    final maxValue = last7Days.map((d) => d.tasksCompleted).fold<int>(0, max);
    final chartMax = maxValue > 0 ? maxValue : 1;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 Days',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: last7Days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final height = day.tasksCompleted > 0 
                      ? (day.tasksCompleted / chartMax) * 80 + 20 
                      : 8.0;
                  final isToday = index == last7Days.length - 1;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (day.tasksCompleted > 0)
                            Text(
                              '${day.tasksCompleted}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          )
                              .animate(delay: Duration(milliseconds: index * 80))
                              .scaleY(begin: 0, end: 1, alignment: Alignment.bottomCenter)
                              .fadeIn(),
                          const SizedBox(height: 8),
                          Text(
                            day.dayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isToday ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildAchievementsSection(BuildContext context, AchievementsService achievements) {
    final achievementsWithStatus = achievements.achievementsWithStatus;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${achievements.unlockedCount}/${achievements.totalCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...achievementsWithStatus.asMap().entries.map((entry) {
          final index = entry.key;
          final (achievement, isUnlocked) = entry.value;
          return _AchievementTile(
            achievement: achievement,
            isUnlocked: isUnlocked,
            delay: index * 50,
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
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final int delay;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnlocked
          ? null
          : Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: ListTile(
        leading: Container(
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
              isUnlocked ? achievement.icon : '🔒',
              style: TextStyle(
                fontSize: 24,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          achievement.description,
          style: TextStyle(
            color: isUnlocked 
                ? Theme.of(context).textTheme.bodyMedium?.color 
                : Colors.grey,
          ),
        ),
        trailing: isUnlocked
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }
}

class _AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const _AchievementUnlockedDialog({
    required this.achievement,
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
            const Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            )
                .animate(onPlay: (c) => c.repeat())
                .shake(hz: 2, duration: const Duration(milliseconds: 500))
                .then()
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
                .then()
                .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
            const SizedBox(height: 16),
            Text(
              'Achievement Unlocked!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 48),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: const Duration(milliseconds: 800),
                      ),
                  const SizedBox(height: 12),
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 200))
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDismiss,
              child: const Text('Awesome!'),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 200))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
