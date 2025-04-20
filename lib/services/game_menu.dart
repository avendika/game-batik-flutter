import 'package:flutter/material.dart';
import '../services/game_setting.dart';

class GameMenu {
  final BuildContext context;
  final GameSettings settings;
  final Function() onResume;
  final Function() onRestart;
  final Function() onExit;

  GameMenu({
    required this.context,
    required this.settings,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  // Custom menu button widget for dialog with responsive sizing
  Widget _buildCustomButton({
    required String text,
    required String imagePath,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final buttonWidth = screenSize.width < 400 ? screenSize.width * 0.6 : 250.0;
    final buttonHeight = screenSize.width < 400 ? 60.0 : 70.0;
    final fontSize = screenSize.width < 400 ? 18.0 : 22.0;
    final iconSize = screenSize.width < 400 ? 24.0 : 28.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height < 600 ? 4 : 8,
        horizontal: screenSize.width < 400 ? 12 : 20,
      ),
      child: GestureDetector(
        onTap: () {
          settings.playSfx('button_click.mp3');
          onPressed();
        },
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Button background
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  width: buttonWidth,
                  height: buttonHeight,
                  fit: BoxFit.cover,
                ),
              ),
              // Button content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize.width < 400 ? 12 : 20),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Color(0xFFFEF4D1), // Cream color
                      size: iconSize,
                    ),
                    SizedBox(width: screenSize.width < 400 ? 10 : 15),
                    Text(
                      text,
                      style: TextStyle(
                        color: Color(0xFFFEF4D1), // Cream color
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show the menu dialog
  void showMenuDialog() {
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width < 400 ? screenSize.width * 0.8 : 300.0;
    final dialogPadding = screenSize.height < 600 ? 20.0 : 30.0;
    final titleFontSize = screenSize.width < 400 ? 24.0 : 28.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenSize.width < 400 ? 20 : 40,
          ),
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.symmetric(vertical: dialogPadding),
            decoration: BoxDecoration(
              color: Color(0xFF654321).withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Color(0xFFB8860B),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MENU',
                    style: TextStyle(
                      color: Color(0xFFFEF4D1),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: screenSize.height < 600 ? 15 : 25),
                  _buildCustomButton(
                    text: 'LANJUTKAN',
                    imagePath: 'assets/images/tombol.png',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Set screen context to 'game' before resuming
                      settings.setCurrentScreen('game');
                      onResume();
          
                      // Make sure background music is playing when continuing
                      if (settings.backgroundMusicEnabled) {
                        settings.handleScreenTransition('game');
                      }
                    },
                  ),
                  _buildCustomButton(
                    text: 'PENGATURAN',
                    imagePath: 'assets/images/tombol.png',
                    icon: Icons.settings,
                    onPressed: () {
                      // Close menu dialog
                      Navigator.of(context).pop();
                      
                      // Open settings popup
                      showSettingsPopup();
                    },
                  ),
                  _buildCustomButton(
                    text: 'ULANG',
                    imagePath: 'assets/images/tombol.png',
                    icon: Icons.refresh,
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Set screen context to 'game' before restarting
                      settings.setCurrentScreen('game');
                      onRestart();

                      // Make sure background music is playing when restarting
                      if (settings.backgroundMusicEnabled) {
                        settings.handleScreenTransition('game');
                      }
                    },
                  ),
                  _buildCustomButton(
                    text: 'KEMBALI',
                    imagePath: 'assets/images/tombol.png',
                    icon: Icons.home,
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Set screen context to 'lobby' when exiting
                      settings.setCurrentScreen('lobby');
                      onExit();
                      
                      // Play lobby music when exiting to main menu
                      if (settings.backgroundMusicEnabled) {
                        settings.handleScreenTransition('lobby');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show popup settings dialog with audio settings only
  void showSettingsPopup() {
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width < 400 ? screenSize.width * 0.8 : 300.0;
    final dialogPadding = screenSize.height < 600 ? 20.0 : 30.0;
    final titleFontSize = screenSize.width < 400 ? 20.0 : 24.0;
    final buttonWidth = screenSize.width < 400 ? 180.0 : 200.0;
    final buttonHeight = screenSize.width < 400 ? 45.0 : 50.0;
    final buttonFontSize = screenSize.width < 400 ? 16.0 : 18.0;
    
    // Save current screen context before showing settings
    String previousScreen = settings.currentScreen;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: screenSize.width < 400 ? 20 : 40,
              ),
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.symmetric(vertical: dialogPadding),
                decoration: BoxDecoration(
                  color: Color(0xFF654321).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFFB8860B),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PENGATURAN SUARA',
                        style: TextStyle(
                          color: Color(0xFFFEF4D1),
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: screenSize.height < 600 ? 15 : 25),
                      
                      // Background Music Switch
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4, 
                          horizontal: screenSize.width < 400 ? 12 : 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF2D0E00), width: 1),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Musik Latar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D0E00),
                              fontSize: screenSize.width < 400 ? 14 : 16,
                            ),
                          ),
                          value: settings.backgroundMusicEnabled,
                          onChanged: (value) {
                            setDialogState(() {
                              settings.toggleBackgroundMusic();
                            });
                          },
                          activeColor: Color(0xFFC49B5D),
                        ),
                      ),
                      
                      // Music Volume Slider
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4, 
                          horizontal: screenSize.width < 400 ? 12 : 20,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width < 400 ? 12 : 16, 
                          vertical: screenSize.height < 600 ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF2D0E00), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volume Musik',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenSize.width < 400 ? 14 : 16,
                                color: settings.backgroundMusicEnabled 
                                    ? Color(0xFF2D0E00) 
                                    : Colors.black38,
                              ),
                            ),
                            Slider(
                              value: settings.musicVolume,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: '${(settings.musicVolume * 100).round()}%',
                              onChanged: settings.backgroundMusicEnabled
                                  ? (value) {
                                      setDialogState(() {
                                        settings.setMusicVolume(value);
                                      });
                                    }
                                  : null,
                              activeColor: Color(0xFFC49B5D),
                            ),
                          ],
                        ),
                      ),
                      
                      // Sound Effects Switch
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4, 
                          horizontal: screenSize.width < 400 ? 12 : 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF2D0E00), width: 1),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Efek Suara',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D0E00),
                              fontSize: screenSize.width < 400 ? 14 : 16,
                            ),
                          ),
                          value: settings.soundEffectsEnabled,
                          onChanged: (value) {
                            setDialogState(() {
                              settings.toggleSoundEffects();
                            });
                            
                            // Play test sound if enabling
                            if (value) {
                              settings.playSfx('button_click.mp3');
                            }
                          },
                          activeColor: Color(0xFFC49B5D),
                        ),
                      ),
                      
                      // Sound Effects Volume Slider
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4, 
                          horizontal: screenSize.width < 400 ? 12 : 20,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width < 400 ? 12 : 16, 
                          vertical: screenSize.height < 600 ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF2D0E00), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volume Efek Suara',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenSize.width < 400 ? 14 : 16,
                                color: settings.soundEffectsEnabled 
                                    ? Color(0xFF2D0E00) 
                                    : Colors.black38,
                              ),
                            ),
                            Slider(
                              value: settings.sfxVolume,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: '${(settings.sfxVolume * 100).round()}%',
                              onChanged: settings.soundEffectsEnabled
                                  ? (value) {
                                      setDialogState(() {
                                        settings.setSfxVolume(value);
                                      });
                                      
                                      // Play test sound when adjusting
                                      if (settings.soundEffectsEnabled) {
                                        settings.playSfx('button_click.mp3');
                                      }
                                    }
                                  : null,
                              activeColor: Color(0xFFC49B5D),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: screenSize.height < 600 ? 12 : 20),
                      
                      // Close button
                      GestureDetector(
                        onTap: () {
                          if (settings.soundEffectsEnabled) {
                            settings.playSfx('button_click.mp3');
                          }
                          
                          // Save settings
                          settings.saveSettings();
                          
                          // Restore previous screen context
                          settings.setCurrentScreen(previousScreen);
                          
                          // Close dialog
                          Navigator.of(context).pop();
                          
                          // Return to paused menu
                          showMenuDialog();
                        },
                        child: Container(
                          width: buttonWidth,
                          height: buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/images/tombol.png',
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                'KEMBALI',
                                style: TextStyle(
                                  color: Color(0xFFFEF4D1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFontSize,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
  
  // Custom game menu button that shows on screen - now responsive
  Widget buildMenuButton(Function() onTap) {
    // Get screen size for responsive adjustments
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.width < 400 ? 50.0 : 60.0;
    final iconSize = screenSize.width < 400 ? 24.0 : 30.0;
    
    return Positioned(
      top: screenSize.height < 600 ? 10 : 20,
      left: screenSize.width < 400 ? 10 : 20,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Button background
              ClipRRect( 
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/tombol.png',
                  width: buttonSize,
                  height: buttonSize,
                  fit: BoxFit.cover,
                ),
              ),
              // Menu icon
              Icon(
                Icons.menu,
                color: Colors.white,
                size: iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}