import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_setting.dart';
import 'tutorial_screen.dart';
import 'materi_screen.dart';
import 'settings_screen.dart';
import '../levels/level_selection.dart';

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

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Cloud> _clouds = [];
  bool _areAnimationsInitialized = false;
  
  // Map of button assets
  final Map<String, String> _buttonAssets = {
    'TUTORIAL': 'assets/images/buttons/tutorial_button.png',
    'PLAY': 'assets/images/buttons/play_button.png',
    'SEJARAH': 'assets/images/buttons/sejarah_button.png',
    'PENGATURAN': 'assets/images/buttons/pengaturan_button.png',
  };

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    
    // Start the lobby music when this screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameSettings().handleScreenTransition('lobby');
      
      // Initialize animations after a slight delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _initializeCloudAnimations();
          });
        }
      });
    });
  }

  void _initializeCloudAnimations() {
    if (_areAnimationsInitialized) return;
    
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

    // Start animations with a slight delay between each to reduce load
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(_clouds[i].delay, () {
        if (mounted) _controllers[i].repeat();
      });
    }
    
    _areAnimationsInitialized = true;
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding;

    // For landscape, we use different sizing strategies
    // Calculate available height (accounting for safe areas)
    final availableHeight = screenHeight - safeArea.top - safeArea.bottom;
    
    // Panel dimensions optimized for landscape
    final panelWidth = screenWidth * 0.4; // Narrower panel for landscape
    final panelHeight = availableHeight * 0.9;
    
    // Button width will be a percentage of the panel width
    final buttonWidth = panelWidth * 0.85;
    
    // Landscape title sizing
    final titleFontSize = _clamp(screenHeight * 0.08, 24, 40);

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
            if (_areAnimationsInitialized) ..._buildCloudAnimations(screenWidth, screenHeight, true),

            Center(
              child: Container(
                width: panelWidth,
                height: panelHeight,
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
                padding: EdgeInsets.symmetric(
                  vertical: availableHeight * 0.04,
                  horizontal: panelWidth * 0.07,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title area
                    _buildTitle('BATIK', titleFontSize),
                    _buildTitle('JOURNEY', titleFontSize),
                    SizedBox(height: availableHeight * 0.04),
                    
                    // Menu buttons - evenly spaced
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImageButton(
                            context, 
                            'TUTORIAL', 
                            () {
                              GameSettings().playSfx('button_click.mp3');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TutorialScreen(),
                                ),
                              ).then((_) {
                                GameSettings().handleScreenTransition('lobby');
                              });
                            }, 
                            buttonWidth
                          ),
                          _buildImageButton(
                            context, 
                            'PLAY', 
                            () {
                              GameSettings().playSfx('button_click.mp3');
                              showDialog(
                                context: context,
                                builder: (context) => const LevelSelectionDialog(),
                              ).then((_) {
                                GameSettings().handleScreenTransition('lobby');
                              });
                            }, 
                            buttonWidth
                          ),
                          _buildImageButton(
                            context, 
                            'SEJARAH', 
                            () {
                              GameSettings().playSfx('button_click.mp3');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MateriScreen(),
                                ),
                              ).then((_) {
                                GameSettings().handleScreenTransition('lobby');
                              });
                            }, 
                            buttonWidth
                          ),
                          _buildImageButton(
                            context, 
                            'PENGATURAN', 
                            () {
                              GameSettings().playSfx('button_click.mp3');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              ).then((_) {
                                GameSettings().handleScreenTransition('lobby');
                              });
                            }, 
                            buttonWidth
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCloudAnimations(double screenWidth, double screenHeight, bool isLandscape) {
    return List.generate(_clouds.length, (i) {
      final cloud = _clouds[i];
      final animation = _animations[i];

      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final cloudWidth = screenWidth * cloud.sizeFactor * (isLandscape ? 0.7 : 1.0);
          final startPos = cloud.fromLeft ? -cloudWidth : screenWidth + cloudWidth;
          final endPos = cloud.fromLeft ? screenWidth + cloudWidth : -cloudWidth;
          final currentPos = startPos + ((endPos - startPos) * animation.value);

          return Positioned(
            left: currentPos,
            top: screenHeight * cloud.topFactor,
            child: Image.asset(
              'assets/background/cloud.png',
              width: cloudWidth,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    });
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

  Widget _buildImageButton(BuildContext context, String buttonType, VoidCallback onPressed, double width) {
    // Aspect ratio for landscape buttons (roughly 4:1)
    final aspectRatio = 6.0;
    final height = width / aspectRatio;
    
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Button image
              Image.asset(
                _buttonAssets[buttonType]!,
                fit: BoxFit.contain,
              ),
              
              // Add tap effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  splashColor: Colors.white24,
                  highlightColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }
}