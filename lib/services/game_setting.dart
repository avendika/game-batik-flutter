import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  // Singleton pattern
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal();

  // Initialization flag
  bool _isInitialized = false;

  // Audio settings
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  bool _isBackgroundMusicPlaying = false;
  String _currentBackgroundTrack = '';
  
  // Game difficulty settings
  String _difficulty = 'normal'; // easy, normal, hard
  
  // UI settings
  bool _showJoystick = true;
  bool _vibrationEnabled = true;

  // Getters
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  String get difficulty => _difficulty;
  bool get showJoystick => _showJoystick;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isInitialized => _isInitialized;
  
  // Player movement speed based on difficulty
  double get playerMoveSpeed {
    switch (_difficulty) {
      case 'easy':
        return 500.0; // Slower movement for easier gameplay
      case 'normal':
        return 300.0; // Default movement speed
      case 'hard':
        return 100.0; // Faster movement for harder gameplay
      default:
        return 400.0;
    }
  }

  // Make sure initialization happens only once
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Initialize settings
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load audio settings
      _backgroundMusicEnabled = prefs.getBool('backgroundMusicEnabled') ?? true;
      _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.7;
      
      // Load game settings
      _difficulty = prefs.getString('difficulty') ?? 'normal';
      _showJoystick = prefs.getBool('showJoystick') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      
      // Preload audio assets
      await _preloadAudio();
      
      // Mark as initialized
      _isInitialized = true;
      
      // Make sure to save the initialized settings
      await saveSettings();
    } catch (e) {
      print('Error initializing settings: $e');
      // Mark as initialized anyway to prevent repeated failures
      _isInitialized = true;
    }
  }

  // Save settings to storage
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save audio settings
      await prefs.setBool('backgroundMusicEnabled', _backgroundMusicEnabled);
      await prefs.setBool('soundEffectsEnabled', _soundEffectsEnabled);
      await prefs.setDouble('musicVolume', _musicVolume);
      await prefs.setDouble('sfxVolume', _sfxVolume);
      
      // Save game settings
      await prefs.setString('difficulty', _difficulty);
      await prefs.setBool('showJoystick', _showJoystick);
      await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Reset settings to default values
  Future<void> resetToDefaults() async {
    // Reset to default values
    _backgroundMusicEnabled = true;
    _soundEffectsEnabled = true;
    _musicVolume = 0.5;
    _sfxVolume = 0.7;
    _difficulty = 'normal';
    _showJoystick = true;
    _vibrationEnabled = true;
    
    // Update audio if necessary
    if (_isBackgroundMusicPlaying) {
      if (_backgroundMusicEnabled) {
        // Adjust volume if music is playing
        FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
      } else {
        // Stop music if it should be off
        stopBackgroundMusic();
      }
    } else if (_backgroundMusicEnabled) {
      // Start music if it should be on but isn't playing
      playBackgroundMusic('lobby_music.mp3');
    }
    
    // Save the default settings
    await saveSettings();
  }

  // Audio methods
  Future<void> _preloadAudio() async {
    try {
      // Load one file at a time to prevent overloading
      final audioFiles = [
        'claim.mp3',
        'lobby_music.mp3',
        'background_music.mp3',
        'level_complete.mp3',
        'button_click.mp3',
      ];
      
      for (final file in audioFiles) {
        try {
          await FlameAudio.audioCache.load(file);
        } catch (e) {
          print('Error loading audio file $file: $e');
          // Continue with other files
        }
      }
    } catch (e) {
      print('Error in audio preloading: $e');
    }
  }

  // Start background music
  void playBackgroundMusic(String track) {
    if (_backgroundMusicEnabled) {
      try {
        // If music is already playing, stop it first
        if (_isBackgroundMusicPlaying) {
          stopBackgroundMusic();
        }
        
        FlameAudio.bgm.play(track, volume: _musicVolume);
        _isBackgroundMusicPlaying = true;
        _currentBackgroundTrack = track;
      } catch (e) {
        print('Error playing background music: $e');
        _isBackgroundMusicPlaying = false;
      }
    }
  }

  // Stop background music
  void stopBackgroundMusic() {
    if (_isBackgroundMusicPlaying) {
      try {
        FlameAudio.bgm.stop();
      } catch (e) {
        print('Error stopping background music: $e');
      } finally {
        _isBackgroundMusicPlaying = false;
        _currentBackgroundTrack = '';
      }
    }
  }

  // Resume background music if it was playing
  void resumeBackgroundMusic() {
    if (_backgroundMusicEnabled && !_isBackgroundMusicPlaying && _currentBackgroundTrack.isNotEmpty) {
      try {
        FlameAudio.bgm.play(_currentBackgroundTrack, volume: _musicVolume);
        _isBackgroundMusicPlaying = true;
      } catch (e) {
        print('Error resuming background music: $e');
      }
    }
  }

  // Play sound effect
  void playSfx(String sound) {
    if (_soundEffectsEnabled) {
      try {
        FlameAudio.play(sound, volume: _sfxVolume);
      } catch (e) {
        print('Error playing sound effect: $e');
      }
    }
  }

  // Toggle background music
  void toggleBackgroundMusic() {
    _backgroundMusicEnabled = !_backgroundMusicEnabled;
    
    if (_backgroundMusicEnabled) {
      // If we're turning music back on and were playing a track
      if (_currentBackgroundTrack.isNotEmpty) {
        playBackgroundMusic(_currentBackgroundTrack);
      } else {
        // Default track
        playBackgroundMusic('lobby_music.mp3');
      }
    } else {
      stopBackgroundMusic();
    }
    
    saveSettings();
  }

  // Toggle sound effects
  void toggleSoundEffects() {
    _soundEffectsEnabled = !_soundEffectsEnabled;
    saveSettings();
  }

  // Set music volume
  void setMusicVolume(double volume) {
    _musicVolume = volume;
    if (_backgroundMusicEnabled && _isBackgroundMusicPlaying) {
      try {
        FlameAudio.bgm.audioPlayer.setVolume(volume);
      } catch (e) {
        print('Error setting music volume: $e');
      }
    }
    saveSettings();
  }

  // Set sound effects volume
  void setSfxVolume(double volume) {
    _sfxVolume = volume;
    saveSettings();
  }

  // Set difficulty
  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
    saveSettings();
  }

  // Toggle joystick visibility
  void toggleJoystick() {
    _showJoystick = !_showJoystick;
    saveSettings();
  }

  // Toggle vibration
  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    saveSettings();
  }
  
  // Handle screen transitions - play appropriate music
  void handleScreenTransition(String screenName) {
    if (!_backgroundMusicEnabled) return;
    
    try {
      switch (screenName) {
        case 'lobby':
          if (_currentBackgroundTrack != 'lobby_music.mp3') {
            playBackgroundMusic('lobby_music.mp3');
          } else if (!_isBackgroundMusicPlaying) {
            resumeBackgroundMusic();
          }
          break;
        case 'game':
          if (_currentBackgroundTrack != 'background_music.mp3') {
            playBackgroundMusic('background_music.mp3');
          }
          break;
        case 'victory':
          if (_currentBackgroundTrack != 'level_complete.mp3') {
            playBackgroundMusic('level_complete.mp3');
          }
          break;
        // Add more cases as needed
      }
    } catch (e) {
      print('Error in handleScreenTransition: $e');
    }
  }
}