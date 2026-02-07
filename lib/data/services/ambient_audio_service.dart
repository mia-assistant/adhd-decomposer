import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Ambient sound options for Body Double mode
enum AmbientSound {
  none,
  cafe,
  rain,
  whiteNoise,
}

/// Service for playing ambient background sounds during focus sessions.
/// 
/// Supports looping playback of cafe, rain, and white noise sounds
/// with volume control and mute functionality.
class AmbientAudioService {
  static final AmbientAudioService _instance = AmbientAudioService._internal();
  factory AmbientAudioService() => _instance;
  AmbientAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AmbientSound _currentSound = AmbientSound.none;
  double _volume = 0.5;
  bool _isMuted = false;
  bool _isInitialized = false;

  /// Current ambient sound being played
  AmbientSound get currentSound => _currentSound;
  
  /// Current volume (0.0 - 1.0)
  double get volume => _volume;
  
  /// Whether audio is muted
  bool get isMuted => _isMuted;
  
  /// Whether a sound is currently selected (not none)
  bool get isPlaying => _currentSound != AmbientSound.none;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _player.setReleaseMode(ReleaseMode.loop);
    _isInitialized = true;
  }

  /// Play an ambient sound
  /// 
  /// If the same sound is already playing, this is a no-op.
  /// Pass [AmbientSound.none] to stop playback.
  Future<void> play(AmbientSound sound) async {
    await initialize();
    
    if (sound == _currentSound) return;
    
    _currentSound = sound;
    
    if (sound == AmbientSound.none) {
      await stop();
      return;
    }
    
    try {
      final assetPath = _getAssetPath(sound);
      await _player.setVolume(_isMuted ? 0 : _volume);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing ambient sound: $e');
      // Reset state on error
      _currentSound = AmbientSound.none;
    }
  }

  /// Stop playback
  Future<void> stop() async {
    _currentSound = AmbientSound.none;
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping ambient sound: $e');
    }
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    _isMuted = false;
    try {
      await _player.setVolume(_volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    try {
      await _player.setVolume(_isMuted ? 0 : _volume);
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  /// Set mute state explicitly
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    try {
      await _player.setVolume(_isMuted ? 0 : _volume);
    } catch (e) {
      debugPrint('Error setting mute: $e');
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _player.stop();
    await _player.dispose();
    _isInitialized = false;
  }

  /// Get asset path for a sound
  String _getAssetPath(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.cafe:
        return 'audio/ambient/cafe_ambient.mp3';
      case AmbientSound.rain:
        return 'audio/ambient/rain.mp3';
      case AmbientSound.whiteNoise:
        return 'audio/ambient/white_noise.mp3';
      case AmbientSound.none:
        return '';
    }
  }

  /// Get display label for a sound
  static String getLabel(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.none:
        return 'Off';
      case AmbientSound.cafe:
        return 'Café';
      case AmbientSound.rain:
        return 'Rain';
      case AmbientSound.whiteNoise:
        return 'Noise';
    }
  }

  /// Get icon for a sound
  static String getIconName(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.none:
        return 'volume_off';
      case AmbientSound.cafe:
        return 'coffee';
      case AmbientSound.rain:
        return 'water_drop';
      case AmbientSound.whiteNoise:
        return 'waves';
    }
  }
}
