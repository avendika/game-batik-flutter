import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_setting.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class Cloud {
  final double sizeFactor;
  final double topFactor;
  final bool fromLeft;
  final Duration delay;

  Cloud({
    required this.sizeFactor,
    required this.topFactor,
    required this.fromLeft,
    required this.delay,
  });
}

class _TutorialScreenState extends State<TutorialScreen> with TickerProviderStateMixin {
  late List<AnimationController> _cloudControllers;
  late List<Animation<double>> _cloudAnimations;
  final List<Cloud> _clouds = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeClouds();
  }

  void _initializeClouds() {
    _clouds.addAll([
      Cloud(sizeFactor: 0.3, topFactor: 0.1, fromLeft: true, delay: const Duration(seconds: 0)),
      Cloud(sizeFactor: 0.25, topFactor: 0.25, fromLeft: false, delay: const Duration(seconds: 5)),
      Cloud(sizeFactor: 0.35, topFactor: 0.45, fromLeft: true, delay: const Duration(seconds: 10)),
      Cloud(sizeFactor: 0.28, topFactor: 0.6, fromLeft: false, delay: const Duration(seconds: 15)),
    ]);

    _cloudControllers = _clouds.map((_) {
      return AnimationController(
        duration: const Duration(seconds: 30),
        vsync: this,
      );
    }).toList();

    _cloudAnimations = _cloudControllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(controller);
    }).toList();

    for (int i = 0; i < _cloudControllers.length; i++) {
      Future.delayed(_clouds[i].delay, () {
        if (mounted) _cloudControllers[i].repeat();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _cloudControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isPortrait = screenSize.height > screenSize.width;
    final GameSettings settings = GameSettings();

    // Responsive calculations
    final double panelWidth = _responsiveValue(
      context,
      mobile: screenSize.width * 0.9,
      tablet: screenSize.width * 0.75,
      desktop: 500,
    ).toDouble().clamp(300, 500);

    final double panelMargin = _responsiveValue(
      context,
      mobile: 15.0,
      tablet: 20.0,
      desktop: 30.0,
    ).toDouble();

    final double titleFontSize = _responsiveValue(
      context,
      mobile: screenSize.shortestSide * 0.08,
      tablet: screenSize.shortestSide * 0.07,
      desktop: 42,
    ).toDouble().clamp(24, 42);

    final double contentFontSize = _responsiveValue(
      context,
      mobile: screenSize.shortestSide * 0.035,
      tablet: screenSize.shortestSide * 0.03,
      desktop: 20,
    ).toDouble().clamp(14, 20);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background/lobby_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Animated Clouds
          ...List.generate(_clouds.length, (i) {
            final cloud = _clouds[i];
            final animation = _cloudAnimations[i];

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final cloudWidth = screenSize.width * cloud.sizeFactor;
                final startPos = cloud.fromLeft ? -cloudWidth : screenSize.width + cloudWidth;
                final endPos = cloud.fromLeft ? screenSize.width + cloudWidth : -cloudWidth;
                final currentPos = startPos + ((endPos - startPos) * animation.value);

                return Positioned(
                  left: currentPos,
                  top: screenSize.height * cloud.topFactor,
                  child: Image.asset(
                    'assets/background/cloud.png',
                    width: cloudWidth,
                    fit: BoxFit.contain,
                  ),
                );
              },
            );
          }),

          // Main content
          Center(
            child: Container(
              width: panelWidth,
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.9,
              ),
              margin: EdgeInsets.all(panelMargin),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2B48C).withOpacity(0.92),
                    border: Border.all(
                      color: const Color(0xFF2D0E00), 
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with TUTORIAL text and back button
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isPortrait ? 15 : 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D0E00).withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFF2D0E00).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          // Back button relocated here
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D0E00)),
                              onPressed: () {
                                // Play sound effect first
                                if (settings.soundEffectsEnabled) {
                                  settings.playSfx('button_click.mp3');
                                }
                                // Then navigate back
                                Navigator.pop(context);
                              },
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'TUTORIAL',
                                style: GoogleFonts.cinzelDecorative(
                                  textStyle: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D0E00),
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
                            ),
                          ],
                        ),
                      ),
                      
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: _responsiveValue(
                              context,
                              mobile: 15.0,
                              tablet: 20.0,
                              desktop: 25.0,
                            ).toDouble(),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Introduction
                              Text(
                                'Selamat datang di Batik Journey! Berikut cara bermain:',
                                style: TextStyle(
                                  fontSize: contentFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: isPortrait ? 30 : 20),
                              
                              // Tutorial steps
                              _buildTutorialStep(
                                context,
                                '1',
                                'Pilih Level',
                                'Pilih level yang ingin dimainkan dari menu Play. Tingkat kesulitan akan meningkat seiring level.',
                                contentFontSize,
                                titleFontSize * 0.6,
                                Icons.star_outlined,
                              ),
                              
                              SizedBox(height: isPortrait ? 25 : 15),
                              
                              _buildTutorialStep(
                                context,
                                '2',
                                'Kenali Pola Batik',
                                'Setiap level memiliki pola batik yang harus Anda hafalkan. Perhatikan dengan seksama!',
                                contentFontSize,
                                titleFontSize * 0.6,
                                Icons.visibility_outlined,
                              ),
                              
                              SizedBox(height: isPortrait ? 25 : 15),
                              
                              _buildTutorialStep(
                                context,
                                '3',
                                'Warnai Pola',
                                'Gunakan warna yang tersedia untuk mewarnai pola sesuai contoh. Sentuh area yang ingin diwarnai.',
                                contentFontSize,
                                titleFontSize * 0.6,
                                Icons.brush_outlined,
                              ),
                              
                              SizedBox(height: isPortrait ? 25 : 15),
                              
                              _buildTutorialStep(
                                context,
                                '4',
                                'Selesaikan Gambar',
                                'Setelah selesai, sistem akan memeriksa hasil karya Anda. Semakin akurat, semakin tinggi skor!',
                                contentFontSize,
                                titleFontSize * 0.6,
                                Icons.done_all_outlined,
                              ),
                              
                              SizedBox(height: isPortrait ? 30 : 20),
                              
                              // Tips section
                              Container(
                                padding: EdgeInsets.all(
                                  _responsiveValue(
                                    context,
                                    mobile: 10.0,
                                    tablet: 12.0,
                                    desktop: 15.0,
                                  ).toDouble(),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D0E00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF2D0E00),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Tips & Trik',
                                      style: TextStyle(
                                        fontSize: titleFontSize * 0.6,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D0E00),
                                      ),
                                    ),
                                    SizedBox(height: isPortrait ? 8 : 5),
                                    Text(
                                      '• Gunakan zoom untuk detail halus\n'
                                      '• Warna batik tradisional biasanya coklat, biru, dan hitam\n'
                                      '• Mulailah dari bagian tengah pola\n'
                                      '• Bandingkan hasil Anda dengan contoh secara berkala',
                                      style: TextStyle(
                                        fontSize: contentFontSize * 0.9,
                                        color: const Color(0xFF2D0E00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: isPortrait ? 20 : 15),
                              
                              // Example image placeholder
                              Container(
                                height: _responsiveValue(
                                  context,
                                  mobile: 120.0,
                                  tablet: 150.0,
                                  desktop: 180.0,
                                ).toDouble(),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF2D0E00).withOpacity(0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: _responsiveValue(
                                      context,
                                      mobile: 40.0,
                                      tablet: 50.0,
                                      desktop: 60.0,
                                    ).toDouble(),
                                    color: const Color(0xFF2D0E00).withOpacity(0.5),
                                  ),
                                ),
                              ),
                              
                              // Extra space at bottom
                              SizedBox(height: isPortrait ? 30 : 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(
    BuildContext context,
    String number,
    String title,
    String description,
    double contentFontSize,
    double titleFontSize,
    IconData icon,
  ) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2D0E00).withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          _responsiveValue(
            context,
            mobile: 10.0,
            tablet: 12.0,
            desktop: 15.0,
          ).toDouble(),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number and icon
            Column(
              children: [
                Container(
                  width: _responsiveValue(
                    context,
                    mobile: 28.0,
                    tablet: 32.0,
                    desktop: 36.0,
                  ).toDouble(),
                  height: _responsiveValue(
                    context,
                    mobile: 28.0,
                    tablet: 32.0,
                    desktop: 36.0,
                  ).toDouble(),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D0E00),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: contentFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isPortrait ? 8 : 5),
                Icon(
                  icon,
                  color: const Color(0xFF2D0E00),
                  size: _responsiveValue(
                    context,
                    mobile: 22.0,
                    tablet: 24.0,
                    desktop: 26.0,
                  ).toDouble(),
                ),
              ],
            ),
            
            SizedBox(width: isPortrait ? 15 : 10),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D0E00),
                    ),
                  ),
                  
                  SizedBox(height: isPortrait ? 8 : 5),
                  
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: contentFontSize,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _responsiveValue(BuildContext context, {required double mobile, double? tablet, double? desktop}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }
}