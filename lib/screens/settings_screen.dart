import 'package:flutter/material.dart';
import '../services/game_setting.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GameSettings settings = GameSettings();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final min = screenWidth < screenHeight ? screenWidth : screenHeight;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/lobby_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: _clamp(screenWidth * 0.85, 280, 450),
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD2B48C).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF2D0E00), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D0E00)),
                          onPressed: () {
                            if (settings.soundEffectsEnabled) {
                              settings.playSfx('button_click.mp3');
                            }
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'PENGATURAN',
                          style: GoogleFonts.cinzelDecorative(
                            textStyle: TextStyle(
                              fontSize: _clamp(min * 0.06, 20, 32),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFC49B5D),
                              shadows: const [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black38,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the layout
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Audio Settings Section
                    _buildSectionTitle('Audio'),
                    _buildSwitchOption(
                      'Musik Latar',
                      settings.backgroundMusicEnabled,
                      (value) {
                        setState(() {
                          settings.toggleBackgroundMusic();
                        });
                      },
                    ),
                    _buildSliderOption(
                      'Volume Musik',
                      settings.musicVolume,
                      (value) {
                        setState(() {
                          settings.setMusicVolume(value);
                        });
                      },
                      isEnabled: settings.backgroundMusicEnabled,
                    ),
                    _buildSwitchOption(
                      'Efek Suara',
                      settings.soundEffectsEnabled,
                      (value) {
                        setState(() {
                          settings.toggleSoundEffects();
                        });
                        
                        // Play a test sound if enabling
                        if (value) {
                          settings.playSfx('button_click.mp3');
                        }
                      },
                    ),
                    _buildSliderOption(
                      'Volume Efek Suara',
                      settings.sfxVolume,
                      (value) {
                        setState(() {
                          settings.setSfxVolume(value);
                        });
                        
                        // Play a test sound when adjusting
                        if (settings.soundEffectsEnabled) {
                          settings.playSfx('button_click.mp3');
                        }
                      },
                      isEnabled: settings.soundEffectsEnabled,
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Game Settings Section
                    _buildSectionTitle('Permainan'),
                    _buildDifficultySelector(),
                    _buildSwitchOption(
                      'Tampilkan Joystick',
                      settings.showJoystick,
                      (value) {
                        setState(() {
                          settings.toggleJoystick();
                        });
                      },
                    ),
                    _buildSwitchOption(
                      'Getaran',
                      settings.vibrationEnabled,
                      (value) {
                        setState(() {
                          settings.toggleVibration();
                        });
                      },
                    ),
                    
                    // Add movement speed info text
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2D0E00), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kecepatan Karakter: ${_getSpeedText()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D0E00),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSpeedDescription(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Reset Button
                    Container(
                      width: _clamp(screenWidth * 0.6, 180, 300),
                      height: _clamp(screenHeight * 0.06, 36, 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reset Pengaturan'),
                              content: const Text('Apakah Anda yakin ingin mengembalikan pengaturan ke default?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await settings.resetToDefaults();
                                    setState(() {}); // Force UI update
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Reset'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'RESET PENGATURAN',
                          style: TextStyle(
                            fontSize: _clamp(min * 0.035, 13, 18),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSpeedText() {
    switch (settings.difficulty) {
      case 'easy':
        return 'Cepat (500)';
      case 'normal':
        return 'Normal (300)';
      case 'hard':
        return 'Lambat (100)';
      default:
        return 'Normal (300)';
    }
  }

  String _getSpeedDescription() {
    switch (settings.difficulty) {
      case 'easy':
        return 'Karakter bergerak lebih cepat, cocok untuk pemain pemula.';
      case 'normal':
        return 'Kecepatan karakter seimbang untuk pengalaman bermain yang standar.';
      case 'hard':
        return 'Karakter bergerak lebih lambat, menambah tantangan bagi pemain mahir.';
      default:
        return 'Kecepatan karakter seimbang untuk pengalaman bermain yang standar.';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D0E00),
            ),
          ),
          const Divider(
            color: Color(0xFF2D0E00),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D0E00), width: 1),
      ),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFC49B5D),
      ),
    );
  }

  Widget _buildSliderOption(
    String title, 
    double value, 
    Function(double) onChanged, 
    {bool isEnabled = true}
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D0E00), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isEnabled ? Colors.black87 : Colors.black38,
            ),
          ),
          Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(value * 100).round()}%',
            onChanged: isEnabled ? onChanged : null,
            activeColor: const Color(0xFFC49B5D),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D0E00), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tingkat Kesulitan'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDifficultyButton('Mudah', 'easy'),
              _buildDifficultyButton('Normal', 'normal'),
              _buildDifficultyButton('Sulit', 'hard'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String label, String value) {
  final isSelected = settings.difficulty == value;
  
  return ElevatedButton(
    onPressed: () {
      setState(() {
        settings.setDifficulty(value);
      });
      // Play sound effect when button is pressed
      if (settings.soundEffectsEnabled) {
        settings.playSfx('button_click.mp3');
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: isSelected ? const Color(0xFFC49B5D) : Colors.grey.shade300,
      foregroundColor: isSelected ? Colors.white : Colors.black87,
    ),
      child: Text(label),
    );
  }
  
  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }
}