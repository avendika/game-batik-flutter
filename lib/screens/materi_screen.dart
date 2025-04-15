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
                image: AssetImage('assets/images/batiks/batik_bg.jpg'),
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
GestureDetector(
  onTap: () {
    if (settings.soundEffectsEnabled) {
      settings.playSfx('button_click.mp3');
    }
    Navigator.pop(context);
  },
  child: Image.asset(
    'assets/images/back_arrow.png',
    width: 24,
    height: 24,
  ),
),

                        SizedBox(width: _responsiveValue(screenSize.width, 8, 12, 16)),
                        Expanded(
                          child: Text(
                            'SEJARAH BATIK NUSANTARA',
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
                      'Legenda Batik',
                      'Dahulu kala, di tanah Jawa yang subur dan damai, hiduplah para leluhur yang pandai menggambar keindahan alam di atas kain. Mereka tak menggunakan kuas biasa, melainkan sebuah alat kecil bernama canting dan cairan malam panas yang mengalir seperti tinta emas. Dengan tangan yang sabar dan hati yang tenang, mereka menciptakan pola-pola indah: dari gelombang laut yang tenang, hingga kilat petir yang menyambar langit.Namun batik bukan sekadar hiasan. Setiap goresan menyimpan makna. Motif parang melambangkan kekuatan, truntum melambangkan cinta yang tulus, dan sido mukti sebagai harapan hidup yang bahagia.Konon, batik pertama kali lahir di lingkungan para raja dan ratu di istana. Hanya bangsawan yang boleh mengenakannya. Tapi suatu hari, seorang putri kerajaan yang baik hati membawa ilmu membatik keluar dari tembok istana. Ia mengajarkannya pada rakyat jelata, hingga seni ini menyebar ke pelosok desa. Sejak saat itu, setiap daerah mulai menciptakan batiknya sendiri, masing-masing unik dan penuh cerita.Waktu terus berlalu, dunia berubah, tapi batik tetap hidup. Ia menari di kain para penari, menyatu dalam pakaian para petani, bahkan melenggang di panggung mode dunia. Hari ini, setiap kali kamu mengenakan batik, seolah kamu membawa sepotong sejarah dan jiwa nenek moyang kita.',
                      'assets/images/batiks/series_batik.png',
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
                height: _responsiveValue(screenSize.height, 200, 250, 300),
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
        'assets/images/batiks/batik_tulis.jpg',
        screenSize,
      ),
      _buildBatikTypeCard(
        context,
        'Batik Cap',
        'Menggunakan cap tembaga, lebih cepat produksinya',
        'assets/images/batiks/batik_cap.jpg',
        screenSize,
      ),
      _buildBatikTypeCard(
        context,
        'Batik Printing',
        'Dicetak modern, harga lebih terjangkau',
        'assets/images/batiks/batik_printing.jpg',
        screenSize,
      ),
      _buildBatikTypeCard(
        context,
        'Batik Kombinasi',
        'Gabungan tulis dan cap, nilai seni tinggi',
        'assets/images/batiks/batik_kombinasi.jpg',
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
        'assets/images/batiks/nyoret.jpg',
        screenSize,
      ),
      _buildProcessStep(
        context,
        '2. Malam',
        'Menggunakan canting untuk menutupi pola dengan malam (lilin batik)',
        'assets/images/batiks/malam.jpg',
        screenSize,
      ),
      _buildProcessStep(
        context,
        '3. Mewarnai',
        'Memberi warna pada bagian yang tidak tertutup malam',
        'assets/images/batiks/mewarnai.png',
        screenSize,
      ),
      _buildProcessStep(
        context,
        '4. Nglorod',
        'Meluruhkan malam dengan air panas',
        'assets/images/batiks/nglorod.png',
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
        'assets/images/batiks/batik_jawa.png',
        screenSize,
      ),
      _buildRegionBatik(
        context,
        'Batik Madura',
        'Dikenal dengan warna-warna berani seperti merah, kuning, dan hijau dengan motif yang lebih besar dan tegas.',
        'assets/images/batiks/batik_madura.jpg',
        screenSize,
      ),
      _buildRegionBatik(
        context,
        'Batik Bali',
        'Menggabungkan unsur alam Bali dengan warna-warna cerah dan motif yang lebih bebas.',
        'assets/images/batiks/batik_bali.jpg',
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
      Image.asset(
        'assets/images/batiks/parang_icon.png',
        width: 24,
        height: 24,
      ),
      context,
      'Parang',
      'Melambangkan kekuatan, keteguhan, dan kesinambungan',
      screenSize,
    ),
    _buildPhilosophyItem(
      Image.asset(
        'assets/images/batiks/kawung_icon.png',
        width: 24,
        height: 24,
      ),
      context,
      'Kawung',
      'Melambangkan kesempurnaan, kemurnian, dan keabadian',
      screenSize,
    ),
    _buildPhilosophyItem(
      Image.asset(
        'assets/images/batiks/megamendung_icon.png',
        width: 24,
        height: 24,
      ),
      context,
      'Mega Mendung',
      'Melambangkan kesabaran dan ketenangan dalam menghadapi masalah',
      screenSize,
    ),
    _buildPhilosophyItem(
      Image.asset(
        'assets/images/batiks/sidomukti_icon.png',
        width: 24,
        height: 24,
      ),
      context,
      'Sido Mukti',
      'Melambangkan harapan untuk mencapai kebahagiaan lahir batin',
      screenSize,
    ),
  ];
}

Widget _buildPhilosophyItem(
  Widget icon,
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
        icon, // Display the icon passed as parameter
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