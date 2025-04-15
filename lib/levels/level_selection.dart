import 'package:flutter/material.dart';
import '../levels/level1.dart';
import '../levels/level2.dart';
import '../levels/level3.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelSelectionDialog extends StatelessWidget {
  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  const LevelSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Skala ukuran teks & tombol
          final titleFontSize = screenWidth * 0.045;
          final buttonFontSize = screenWidth * 0.035;
          final buttonWidth = screenWidth * 0.15;
          final buttonHeight = screenHeight * 0.07;

          return Stack(
            children: [
              // Background full screen
              SizedBox.expand(
                child: Image.asset(
                  'assets/background/bg_lv.gif',
                  fit: BoxFit.cover,
                ),
              ),

              // Wrap the entire content in SingleChildScrollView
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        // Tombol back di kiri atas
                        Positioned(
                          top: screenHeight * 0.04,
                          left: screenWidth * 0.05,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFD6C29F),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0xFF2D0E00), width: 2),
                              ),
                              shadowColor: Colors.black.withOpacity(0.25),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'KEMBALI',
                              style: GoogleFonts.cinzelDecorative(
                                textStyle: TextStyle(
                                  fontSize: _clamp(screenWidth * 0.045, 16, 22),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: Colors.black,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 1.5,
                                      color: Colors.white30,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Center content with proper padding to avoid overflow
                        Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.15, // Add more top padding to avoid overlap with back button
                            bottom: screenHeight * 0.05,
                          ),
                          child: Center(
                            child: Container(
                              width: screenWidth * 0.7,
                              // Remove fixed height to make it adapt to content
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6C29F),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF2D0E00), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Make column wrap its content
                                children: [
                                  Text(
                                    'PILIH LEVEL',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cinzelDecorative(
                                      textStyle: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF723A10),
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 2.0,
                                            color: Colors.white,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Use Wrap for better adaptability on smaller screens
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _buildLevelButton(context, '1', buttonFontSize, buttonWidth, buttonHeight),
                                      _buildLevelButton(context, '2', buttonFontSize, buttonWidth, buttonHeight),
                                      _buildLevelButton(context, '3', buttonFontSize, buttonWidth, buttonHeight),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String level, double fontSize, double width, double height) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD6C29F),
        foregroundColor: const Color(0xFF723A10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        minimumSize: Size(width, height),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        elevation: 4,
      ),
      onPressed: () {
        Navigator.pop(context);
        if (level == '1') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Level1Screen()),
          );
        }
        if (level == '2') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Level2Screen()),
          );
        }
        if (level == '3') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Level3Screen()),
          );
        }
      },
      child: Text(
        level,
        style: TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              blurRadius: 1.5,
              color: Colors.white30,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}