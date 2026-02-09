import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'settings_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  final SettingsService _settings = SettingsService();

  Future<void> playStepComplete() async {
    if (!_settings.soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/step_complete.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playTaskComplete() async {
    if (!_settings.celebrationSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/task_complete.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playTimerEnd() async {
    if (!_settings.soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/timer_end.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  /// Play a gentle nudge sound for time blindness alerts
  Future<void> playTimeWarning() async {
    if (!_settings.soundEnabled) return;
    try {
      // Use step_complete as a gentle nudge (softer than timer_end)
      await _player.play(AssetSource('sounds/step_complete.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
