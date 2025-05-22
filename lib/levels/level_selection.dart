import 'package:flutter/material.dart';
import '../levels/level1.dart';
import '../levels/level2.dart';
import '../levels/level3.dart';
import '../levels/level4.dart';
import '../levels/level5.dart';
// import '../levels/level6.dart';
// import '../levels/level7.dart';
// import '../levels/level8.dart';
// import '../levels/level9.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelSelectionDialog extends StatelessWidget {
  const LevelSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // Full screen background image
              SizedBox.expand(
                child: Image.asset(
                  'assets/background/bg_lv.gif',
                  fit: BoxFit.cover,
                ),
              ),

              // Main content
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.12), // Space at top
                    
                    // Panel with level selection
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Panel background image
                          Image.asset(
                            'assets/background/level_panel_bg.png',
                            width: screenWidth * 1,
                            height: screenHeight * 0.8,
                            fit: BoxFit.contain,
                          ),
                          
                          // "PILIH LEVEL" text
                          Positioned(
                            top: screenHeight * 0.05,
                            child: Text(
                              "PILIH LEVEL",
                              style: GoogleFonts.merriweather(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 241, 200, 85),
                                shadows: [
                                  // Shadow(
                                  //   blurRadius: 2,
                                  //   color: Colors.amber.withOpacity(0.5),
                                  //   offset: const Offset(1, 1),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Level buttons grid - positioned lower
                          Positioned(
                            top: screenHeight * 0.20, // Moved lower
                            child: SizedBox(
                              width: screenWidth * 0.8,
                              child: _buildLevelGrid(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Back button in the top left
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.05,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Back button background image
                      Image.asset(
                        'assets/images/tombol.png',
                        width: 120,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                      
                      // Back button text
                      Text(
                        'Kembali',
                        style: GoogleFonts.merriweather(
                          color: const Color.fromARGB(230, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            // Shadow(
                            //   blurRadius: 2,
                            //   color: Colors.black.withOpacity(0.6),
                            //   offset: const Offset(1, 1),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Build a fixed 2x5 grid of level buttons
  Widget _buildLevelGrid(BuildContext context) {
    return Column(
      children: [
        // First row of buttons (1-5)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= 4; i++)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: _buildLevelButton(context, i.toString()),
              ),
          ],
        ),
        
        const SizedBox(height: 10), // Space between rows
        
        // Second row of buttons (6-9)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 5; i <= 8; i++)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: _buildLevelButton(context, i.toString()),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelButton(BuildContext context, String level) {
    // Fixed size for level buttons
    const double buttonSize = 80.0;
    
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _navigateToLevel(context, int.parse(level));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Level button background image
          Image.asset(
            'assets/images/buttons/level_button_bg.png',
            width: buttonSize,
            height: buttonSize,
            fit: BoxFit.contain,
          ),
          
          // Level number
          Text(
            level,
            style: GoogleFonts.merriweather(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A2601),
              shadows: [
                Shadow(
                  blurRadius: 1,
                  color: Colors.amber.withOpacity(0.5),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToLevel(BuildContext context, int level) {
    Widget levelScreen;
    
    // Add cases for each level
    switch (level) {
      case 1:
        levelScreen = const Level1Screen();
        break;
      case 2:
        levelScreen = const Level2Screen();
        break;
      case 3:
        levelScreen = const Level3Screen();
        break;
      case 4:
        levelScreen = const Level4Screen();
        break;
      case 5:
        levelScreen = const Level5Screen();
        break;
      // case 6:
      //   levelScreen = const Level6Screen();
      //   break;
      // case 7:
      //   levelScreen = const Level7Screen();
      //   break;
      // case 8:
      //   levelScreen = const Level8Screen();
      //   break;
      // case 9:
      //   levelScreen = const Level9Screen();
      //   break;
      // case 10: // This is the button in the second row that matches the level 5 position
      //   levelScreen = const Level5Screen(); // You might want to change this to the appropriate level
      //   break;
      default:
        // Fallback to level 1 if level doesn't exist
        levelScreen = const Level1Screen();
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => levelScreen),
    );
  }
}