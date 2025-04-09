import 'package:flutter/material.dart';
import '../levels/level_selection.dart';
import 'package:google_fonts/google_fonts.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class Cloud {
  final double sizeFactor; // Ukuran relatif terhadap lebar layar
  final double topFactor;  // Posisi relatif terhadap tinggi layar
  final bool fromLeft;
  final Duration delay;

  Cloud({
    required this.sizeFactor,
    required this.topFactor,
    required this.fromLeft,
    required this.delay,
  });
}

class _LobbyScreenState extends State<LobbyScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Cloud> _clouds = [];

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeClouds(double screenWidth) {
    if (_clouds.isNotEmpty) return;

    _clouds.addAll([
      Cloud(sizeFactor: 0.3, topFactor: 0.1, fromLeft: true, delay: const Duration(seconds: 0)),
      Cloud(sizeFactor: 0.25, topFactor: 0.25, fromLeft: false, delay: const Duration(seconds: 5)),
      Cloud(sizeFactor: 0.35, topFactor: 0.45, fromLeft: true, delay: const Duration(seconds: 10)),
      Cloud(sizeFactor: 0.28, topFactor: 0.6, fromLeft: false, delay: const Duration(seconds: 15)),
    ]);

    _controllers = _clouds.map((_) {
      return AnimationController(
        duration: const Duration(seconds: 30),
        vsync: this,
      );
    }).toList();

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(controller);
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(_clouds[i].delay, () {
        if (mounted) _controllers[i].repeat();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;
    final safeArea = MediaQuery.of(context).padding;

    _initializeClouds(screenWidth);

    // Adjusted panel dimensions
    final panelWidth = _clamp(screenWidth * 0.85, 280, 400);
    
    // Dynamically calculate available height
    final availableHeight = screenHeight - safeArea.top - safeArea.bottom;
    
    // Calculate dynamic min and max heights ensuring min < max
    final maxPanelHeight = min(availableHeight * 0.85, 500);
    final minPanelHeight = min(maxPanelHeight - 1, 250); // Ensure min < max
    
    // Button dimensions adjusted for available space
    final verticalSpacing = _clamp(availableHeight * 0.02, 8, 20);
    final buttonWidth = _clamp(panelWidth * 0.75, 180, 300);
    final buttonHeight = _clamp(availableHeight * 0.06, 36, 50);
    
    // Font sizes adjusted for screen size
    final subtitleFontSize = _clamp(min(screenWidth, screenHeight) * 0.06, 20, 34);
    final buttonFontSize = _clamp(min(screenWidth, screenHeight) * 0.035, 13, 20);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/background/lobby_background.png',
              fit: BoxFit.cover,
            ),

            // Animated Clouds
            ...List.generate(_clouds.length, (i) {
              final cloud = _clouds[i];
              final animation = _animations[i];

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final cloudWidth = screenWidth * cloud.sizeFactor;
                  final startPos = cloud.fromLeft ? -cloudWidth : screenWidth + cloudWidth;
                  final endPos = cloud.fromLeft ? screenWidth + cloudWidth : -cloudWidth;
                  final currentPos = startPos + ((endPos - startPos) * animation.value);

                  return Positioned(
                    left: currentPos,
                    top: screenHeight * cloud.topFactor * (isLandscape ? 0.7 : 1.0),
                    child: Image.asset(
                      'assets/background/cloud.png',
                      width: cloudWidth,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              );
            }),

            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: panelWidth,
                  constraints: BoxConstraints(
                    maxHeight: maxPanelHeight,
                    minHeight: minPanelHeight,
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: _clamp(availableHeight * 0.04, 15, 30),
                    horizontal: _clamp(screenWidth * 0.03, 10, 20),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: _clamp(availableHeight * 0.04, 15, 30),
                    horizontal: _clamp(screenWidth * 0.03, 15, 25),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2B48C).withOpacity(0.85),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate spacing based on available height
                      final contentHeight = constraints.maxHeight;
                      final titleSpacing = _clamp(contentHeight * 0.06, 15, 40);
                      final buttonSpacing = _clamp(contentHeight * 0.03, 8, 20);
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTitle('BATIK', subtitleFontSize),
                          _buildTitle('JOURNEY', subtitleFontSize),
                          SizedBox(height: titleSpacing),

                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMenuButton(context, 'TUTORIAL', () {}, buttonWidth, buttonHeight, buttonFontSize),
                                SizedBox(height: buttonSpacing),
                                _buildMenuButton(context, 'PLAY', () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const LevelSelectionDialog(),
                                  );
                                }, buttonWidth, buttonHeight, buttonFontSize),
                                SizedBox(height: buttonSpacing),
                                _buildMenuButton(context, 'PENGATURAN', () {}, buttonWidth, buttonHeight, buttonFontSize),
                              ],
                            ),
                          ),
                          
                          // Add a spacer at the bottom for better scrolling experience
                          SizedBox(height: _clamp(contentHeight * 0.02, 5, 15)),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, double fontSize) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: GoogleFonts.cinzelDecorative(
          textStyle: TextStyle(
            fontSize: fontSize,
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
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, VoidCallback onPressed, double width, double height, double fontSize) {
    return Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(minWidth: 180, minHeight: 36),
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
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }
  
  // Helper function to get minimum of two values
  double min(double a, double b) {
    return a < b ? a : b;
  }
}