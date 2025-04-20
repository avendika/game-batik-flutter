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

    // Enhanced responsive calculations
    final double panelWidth = _responsiveValue(
      context,
      mobile: screenSize.width * 0.95,
      tablet: screenSize.width * 0.8,
      desktop: 600,
    ).toDouble().clamp(300, 600);

    final double panelMargin = _responsiveValue(
      context,
      mobile: 10.0,
      tablet: 20.0,
      desktop: 30.0,
    ).toDouble();

    final double titleFontSize = _responsiveValue(
      context,
      mobile: screenSize.shortestSide * 0.065,
      tablet: screenSize.shortestSide * 0.055,
      desktop: 36,
    ).toDouble().clamp(20, 36);

    final double contentFontSize = _responsiveValue(
      context,
      mobile: screenSize.shortestSide * 0.032,
      tablet: screenSize.shortestSide * 0.028,
      desktop: 18,
    ).toDouble().clamp(14, 18);

    final double imageHeight = _responsiveValue(
      context,
      mobile: screenSize.height * (isPortrait ? 0.2 : 0.3),
      tablet: screenSize.height * (isPortrait ? 0.25 : 0.35),
      desktop: isPortrait ? 250 : 300,
    ).toDouble();

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
                maxHeight: screenSize.height * (isPortrait ? 0.85 : 0.95),
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
                          vertical: isPortrait ? 12 : 8,
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  if (settings.soundEffectsEnabled) {
                                    settings.playSfx('button_click.mp3');
                                  }
                                  Navigator.pop(context);
                                },
                                child: Image.asset(
                                  'assets/images/back_arrow.png',
                                  width: _responsiveValue(
                                    context,
                                    mobile: 22,
                                    tablet: 24,
                                    desktop: 26,
                                  ),
                                  height: _responsiveValue(
                                    context,
                                    mobile: 22,
                                    tablet: 24,
                                    desktop: 26,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Centered TUTORIAL text
                            Text(
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
                          ],
                        ),
                      ),
                      
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: _responsiveValue(
                              context,
                              mobile: 12.0,
                              tablet: 18.0,
                              desktop: 22.0,
                            ).toDouble(),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Introduction
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _responsiveValue(
                      context,
                      mobile: 8.0,
                      tablet: 12.0,
                      desktop: 16.0,
                    ).toDouble(),
                  ),
                  child: Text(
                    'Selamat datang di Batik Journey! Berikut cara bermain:',
                    style: TextStyle(
                      fontSize: contentFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: isPortrait ? 24 : 16),

                // Tutorial steps                
                _buildTutorialStep(
                  context,
                  '1',
                  'Start',
                  'Mulailah dari Level 1 untuk pengalaman bermain yang lebih seru dan menantang.',
                  contentFontSize,
                  titleFontSize * 0.6,
                  Icons.flag_outlined
                ),
                SizedBox(height: isPortrait ? 20 : 12),

                _buildTutorialStep(
                  context,
                  '2',
                  'Point',
                  'Temukan point tersembunyi sesuai target pada setiap level. Setiap lokasi hanya menyimpan satu point.',
                  contentFontSize,
                  titleFontSize * 0.6,
                  Icons.explore_outlined,
                ),
                SizedBox(height: isPortrait ? 20 : 12),

                _buildTutorialStep(
                  context,
                  '3',
                  'Materi',
                  'Setelah semua point terkumpul, materi tentang batik akan ditampilkan dalam layar pop-up. Baca dengan seksama!',
                  contentFontSize,
                  titleFontSize * 0.6,
                  Icons.menu_book_outlined,
                ),
                SizedBox(height: isPortrait ? 20 : 12),

                _buildTutorialStep(
                  context,
                  '4',
                  'Pertanyaan',
                  'Di level selanjutnya, Anda harus menjawab pertanyaan dari materi sebelumnya untuk bisa bermain. Pastikan Anda mengingatnya!',
                  contentFontSize,
                  titleFontSize * 0.6,
                  Icons.quiz_outlined,
                ),
                SizedBox(height: isPortrait ? 24 : 16),

                // Tips section
                Container(
                  padding: EdgeInsets.all(
                    _responsiveValue(
                      context,
                      mobile: 10.0,
                      tablet: 12.0,
                      desktop: 14.0,
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
                      SizedBox(height: isPortrait ? 6 : 4),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _responsiveValue(
                            context,
                            mobile: 4.0,
                            tablet: 6.0,
                            desktop: 8.0,
                          ).toDouble(),
                        ),
                        child: Text(
                          '• Setiap lokasi hanya menyimpan satu point\n'
                          '• Jangan lupa baca materi dengan teliti\n'
                          '• Jika lupa materi, lihat petunjuk di bawah kolom jawaban\n'
                          '• Jawaban pertanyaan diambil dari materi level sebelumnya',
                          style: TextStyle(
                            fontSize: contentFontSize * 0.9,
                            color: const Color(0xFF2D0E00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                              
                              SizedBox(height: isPortrait ? 20 : 12),
                              
                              // Image sections - all left-aligned
                              _buildImageSection(
                                context,
                                'Menu Utama',
                                'Ini adalah tampilan utama game yang berisi tombol play, tutorial, sejarah, dan pengaturan',
                                'assets/images/tutorial/menu_utama.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),
                              
                              SizedBox(height: isPortrait ? 20 : 12),
                              
                              _buildImageSection(
                                context,
                                'Pilih Level',
                                'Pilih level yang ingin dimainkan dari daftar level yang tersedia. Jika Anda pemain baru, disarankan untuk memulai dari Level 1.',
                                'assets/images/tutorial/pilih_level.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),

                              SizedBox(height: isPortrait ? 20 : 12),
                              
                              _buildImageSection(
                                context,
                                'Joystick',
                                'Gunakan joystick di kiri bawah untuk menggerakkan karakter.',
                                'assets/images/tutorial/joystick.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),

                              SizedBox(height: isPortrait ? 20 : 12),

                              _buildImageSection(
                                context,
                                'Points',
                                'Kumpulkan seluruh poin yang ada di level yang dimainkan untuk menyelesaikan stage.',
                                'assets/images/tutorial/points.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),

                              SizedBox(height: isPortrait ? 20 : 12),

                              _buildImageSection(
                                context,
                                'Tangga',
                                'Ini adalah tampilan tangga yang digunakan untuk naik atau turun di dalam gameplay. Gunakan tangga ini untuk menjelajahi area yang lebih tinggi atau rendah.',
                                'assets/images/tutorial/tangga.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),

                              SizedBox(height: isPortrait ? 20 : 12),

                              _buildImageSection(
                                context,
                                'Level Completed',
                                'Setelah menyelesaikan permainan dengan mengumpulkan semua poin, akan muncul pop-up berisi materi yang menjadi petunjuk (clue) untuk kuis atau pertanyaan di level berikutnya.',
                                'assets/images/tutorial/level_completed.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),

                              SizedBox(height: isPortrait ? 20 : 12),

                              _buildImageSection(
                                context,
                                'Quiz',
                                'Untuk bisa lanjut ke level berikutnya, Anda harus menjawab pertanyaan yang diambil dari materi yang ditampilkan setelah level sebelumnya selesai.',
                                'assets/images/tutorial/quiz.png',
                                contentFontSize,
                                titleFontSize * 0.6,
                                imageHeight,
                              ),
                              
                              SizedBox(height: isPortrait ? 16 : 12),
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
            mobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
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
                    mobile: 26.0,
                    tablet: 30.0,
                    desktop: 34.0,
                  ).toDouble(),
                  height: _responsiveValue(
                    context,
                    mobile: 26.0,
                    tablet: 30.0,
                    desktop: 34.0,
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
                SizedBox(height: isPortrait ? 6 : 4),
                Icon(
                  icon,
                  color: const Color(0xFF2D0E00),
                  size: _responsiveValue(
                    context,
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ).toDouble(),
                ),
              ],
            ),
            
            SizedBox(width: isPortrait ? 12 : 8),
            
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
                  
                  SizedBox(height: isPortrait ? 6 : 4),
                  
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

  Widget _buildImageSection(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    double contentFontSize,
    double titleFontSize,
    double imageHeight,
  ) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: isPortrait ? 8.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2D0E00).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with dynamic constraints
          Container(
            constraints: BoxConstraints(
              maxHeight: imageHeight,
              maxWidth: screenWidth * 0.9,
            ),
            padding: EdgeInsets.all(isPortrait ? 8.0 : 4.0),
            child: Center(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Text section
          Padding(
            padding: EdgeInsets.all(
              isPortrait 
                ? _responsiveValue(context, mobile: 10.0, tablet: 12.0, desktop: 14.0)
                : _responsiveValue(context, mobile: 8.0, tablet: 10.0, desktop: 12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isPortrait ? titleFontSize : titleFontSize * 0.9,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D0E00),
                  ),
                ),
                SizedBox(height: isPortrait ? 6 : 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isPortrait ? contentFontSize : contentFontSize * 0.9,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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