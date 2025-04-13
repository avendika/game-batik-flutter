import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_setting.dart';

class MateriScreen extends StatelessWidget {
  const MateriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final GameSettings settings = GameSettings();

    return Scaffold(
      body: Stack(
        children: [
          // Background with batik pattern
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/batik_pattern_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
              color: Color(0xFFF5E9D9),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _responsiveValue(screenSize.width, 16, 24, 32),
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
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
                        SizedBox(width: _responsiveValue(screenSize.width, 8, 12, 16)),
                        Expanded(
                          child: Text(
                            'MATERI BATIK NUSANTARA',
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: _responsiveTextSize(screenSize.width, 18, 22, 26),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D0E00),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: _responsiveValue(screenSize.height, 12, 16, 20)),

                    // Introduction card
                    _buildSectionCard(
                      context,
                      'Pengenalan Batik',
                      'Batik adalah warisan budaya Indonesia yang diakui UNESCO sebagai Warisan Kemanusiaan untuk Budaya Lisan dan Nonbendawi sejak 2009. Batik bukan sekadar kain bercorak, tetapi memiliki makna filosofis mendalam dan teknik pembuatan yang unik.',
                      'assets/materi/batik_intro.jpg',
                      screenSize,
                    ),

                    SizedBox(height: _responsiveValue(screenSize.height, 16, 20, 24)),

                    // Types of Batik
                    _buildSectionTitle(context, 'Jenis-Jenis Batik', screenSize),
                    SizedBox(height: _responsiveValue(screenSize.height, 8, 12, 16)),
                    SingleChildScrollView(
                      scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
                      child: isPortrait
                          ? Column(
                              children: _buildBatikTypes(context, screenSize),
                            )
                          : Row(
                              children: _buildBatikTypes(context, screenSize),
                            ),
                    ),

                    SizedBox(height: _responsiveValue(screenSize.height, 16, 20, 24)),

                    // Batik Making Process
                    _buildSectionTitle(context, 'Proses Pembuatan Batik', screenSize),
                    SizedBox(height: _responsiveValue(screenSize.height, 8, 12, 16)),
                    ..._buildProcessSteps(context, screenSize),

                    SizedBox(height: _responsiveValue(screenSize.height, 16, 20, 24)),

                    // Regional Batik
                    _buildSectionTitle(context, 'Batik Daerah', screenSize),
                    SizedBox(height: _responsiveValue(screenSize.height, 8, 12, 16)),
                    ..._buildRegionBatiks(context, screenSize),

                    SizedBox(height: _responsiveValue(screenSize.height, 16, 20, 24)),

                    // Philosophy
                    _buildSectionTitle(context, 'Filosofi Motif Batik', screenSize),
                    SizedBox(height: _responsiveValue(screenSize.height, 8, 12, 16)),
                    ..._buildPhilosophyItems(context, screenSize),

                    SizedBox(height: _responsiveValue(screenSize.height, 24, 32, 40)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Responsive helper functions
  double _responsiveValue(double size, double small, double medium, double large) {
    if (size < 350) return small;
    if (size < 600) return medium;
    return large;
  }

  double _responsiveTextSize(double size, double small, double medium, double large) {
    if (size < 350) return small;
    if (size < 600) return medium;
    return large;
  }

  Widget _buildSectionCard(
    BuildContext context, 
    String title, 
    String content, 
    String imagePath,
    Size screenSize,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(_responsiveValue(screenSize.width, 12, 16, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzelDecorative(
                fontSize: _responsiveTextSize(screenSize.width, 16, 18, 20),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D0E00),
              ),
            ),
            SizedBox(height: _responsiveValue(screenSize.height, 8, 12, 16)),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: _responsiveValue(screenSize.height, 120, 160, 200),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: _responsiveValue(screenSize.height, 8, 12, 16)),
            Text(
              content,
              style: TextStyle(
                fontSize: _responsiveTextSize(screenSize.width, 14, 15, 16),
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Size screenSize) {
    return Text(
      title,
      style: GoogleFonts.cinzelDecorative(
        fontSize: _responsiveTextSize(screenSize.width, 18, 20, 22),
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D0E00),
      ),
    );
  }

  List<Widget> _buildBatikTypes(BuildContext context, Size screenSize) {
    return [
      _buildBatikTypeCard(
        context,
        'Batik Tulis',
        'Dibuat manual dengan canting, setiap goresan unik',
        'assets/materi/batik_tulis.jpg',
        screenSize,
      ),
      _buildBatikTypeCard(
        context,
        'Batik Cap',
        'Menggunakan cap tembaga, lebih cepat produksinya',
        'assets/materi/batik_cap.jpg',
        screenSize,
      ),
      _buildBatikTypeCard(
        context,
        'Batik Printing',
        'Dicetak modern, harga lebih terjangkau',
        'assets/materi/batik_print.jpg',
        screenSize,
      ),
      _buildBatikTypeCard(
        context,
        'Batik Kombinasi',
        'Gabungan tulis dan cap, nilai seni tinggi',
        'assets/materi/batik_kombinasi.jpg',
        screenSize,
      ),
    ];
  }

  Widget _buildBatikTypeCard(
    BuildContext context, 
    String title, 
    String desc, 
    String imagePath,
    Size screenSize,
  ) {
    return Container(
      width: isPortrait(screenSize) 
          ? double.infinity 
          : _responsiveValue(screenSize.width, 180, 220, 250),
      margin: EdgeInsets.only(
        right: isPortrait(screenSize) ? 0 : 12,
        bottom: 12,
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: _responsiveValue(screenSize.height, 100, 120, 140),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_responsiveValue(screenSize.width, 8, 12, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: _responsiveTextSize(screenSize.width, 14, 16, 18),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D0E00),
                    ),
                  ),
                  SizedBox(height: _responsiveValue(screenSize.height, 4, 6, 8)),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: _responsiveTextSize(screenSize.width, 12, 14, 15),
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

  List<Widget> _buildProcessSteps(BuildContext context, Size screenSize) {
    return [
      _buildProcessStep(
        context,
        '1. Nyoret',
        'Membuat pola di atas kain dengan pensil',
        'assets/materi/nyoret.jpg',
        screenSize,
      ),
      _buildProcessStep(
        context,
        '2. Malam',
        'Menggunakan canting untuk menutupi pola dengan malam (lilin batik)',
        'assets/materi/malam.jpg',
        screenSize,
      ),
      _buildProcessStep(
        context,
        '3. Mewarnai',
        'Memberi warna pada bagian yang tidak tertutup malam',
        'assets/materi/mewarnai.jpg',
        screenSize,
      ),
      _buildProcessStep(
        context,
        '4. Nglorod',
        'Meluruhkan malam dengan air panas',
        'assets/materi/nglorod.jpg',
        screenSize,
      ),
    ];
  }

  Widget _buildProcessStep(
    BuildContext context, 
    String step, 
    String desc, 
    String imagePath,
    Size screenSize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: _responsiveValue(screenSize.height, 12, 16, 20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _responsiveValue(screenSize.width, 80, 100, 120),
            height: _responsiveValue(screenSize.width, 80, 100, 120),
            margin: EdgeInsets.only(right: _responsiveValue(screenSize.width, 8, 12, 16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(screenSize.width, 16, 18, 20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D0E00),
                  ),
                ),
                SizedBox(height: _responsiveValue(screenSize.height, 4, 6, 8)),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(screenSize.width, 13, 15, 16),
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

  List<Widget> _buildRegionBatiks(BuildContext context, Size screenSize) {
    return [
      _buildRegionBatik(
        context,
        'Batik Jawa',
        'Batik Solo, Yogyakarta, Pekalongan, dan Cirebon memiliki ciri khas masing-masing. Batik Solo dan Yogya cenderung menggunakan warna sogan (coklat), sedangkan Batik Pekalongan lebih berwarna cerah.',
        'assets/materi/batik_jawa.jpg',
        screenSize,
      ),
      _buildRegionBatik(
        context,
        'Batik Madura',
        'Dikenal dengan warna-warna berani seperti merah, kuning, dan hijau dengan motif yang lebih besar dan tegas.',
        'assets/materi/batik_madura.jpg',
        screenSize,
      ),
      _buildRegionBatik(
        context,
        'Batik Bali',
        'Menggabungkan unsur alam Bali dengan warna-warna cerah dan motif yang lebih bebas.',
        'assets/materi/batik_bali.jpg',
        screenSize,
      ),
    ];
  }

  Widget _buildRegionBatik(
    BuildContext context, 
    String region, 
    String desc, 
    String imagePath,
    Size screenSize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: _responsiveValue(screenSize.height, 16, 20, 24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: _responsiveValue(screenSize.height, 140, 180, 220),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_responsiveValue(screenSize.width, 12, 16, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(screenSize.width, 16, 18, 20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D0E00),
                  ),
                ),
                SizedBox(height: _responsiveValue(screenSize.height, 6, 8, 12)),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(screenSize.width, 13, 15, 16),
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPhilosophyItems(BuildContext context, Size screenSize) {
    return [
      _buildPhilosophyItem(
        context,
        'Parang',
        'Melambangkan kekuatan, keteguhan, dan kesinambungan',
        screenSize,
      ),
      _buildPhilosophyItem(
        context,
        'Kawung',
        'Melambangkan kesempurnaan, kemurnian, dan keabadian',
        screenSize,
      ),
      _buildPhilosophyItem(
        context,
        'Truntum',
        'Melambangkan cinta yang tumbuh dan berkembang',
        screenSize,
      ),
      _buildPhilosophyItem(
        context,
        'Sido Mukti',
        'Melambangkan harapan untuk mencapai kebahagiaan lahir batin',
        screenSize,
      ),
    ];
  }

  Widget _buildPhilosophyItem(
    BuildContext context, 
    String motif, 
    String meaning,
    Size screenSize,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: _responsiveValue(screenSize.height, 8, 12, 16)),
      padding: EdgeInsets.all(_responsiveValue(screenSize.width, 8, 12, 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF0E6D2),
        border: Border.all(color: const Color(0xFFC49B5D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite, 
            color: const Color(0xFF8B4513), 
            size: _responsiveValue(screenSize.width, 16, 20, 24)),
          SizedBox(width: _responsiveValue(screenSize.width, 8, 12, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motif,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(screenSize.width, 14, 16, 18),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D0E00),
                  ),
                ),
                SizedBox(height: _responsiveValue(screenSize.height, 2, 4, 6)),
                Text(
                  meaning,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(screenSize.width, 12, 14, 15),
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

  bool isPortrait(Size screenSize) => screenSize.height > screenSize.width;
}