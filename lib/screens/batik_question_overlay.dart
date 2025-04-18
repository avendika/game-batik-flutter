import 'package:flutter/material.dart';

class BatikQuestionOverlay extends StatelessWidget {
  final TextEditingController answerController;
  final VoidCallback onContinuePressed;
  final VoidCallback onBackPressed;
  
  final String levelNumber;
  final String batikImagePath;
  final String quizQuestion;
  final String quizHint;

  const BatikQuestionOverlay({
    super.key,
    required this.answerController,
    required this.onContinuePressed,
    required this.onBackPressed,
    required this.levelNumber,
    required this.batikImagePath,
    required this.quizQuestion,
    required this.quizHint,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background/BG_question.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12), // Diperkecil
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QUIZ Header
                Text(
                  'QUIZ',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 26 : 32, // ------------------
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF7D35D),
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 2.0, // Diperkecil
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12), // ------------------
                
                // Batik Image
                Container(
                  padding: const EdgeInsets.all(5), // ------------------
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C4B00),
                    borderRadius: BorderRadius.circular(8), // ------------------
                    border: Border.all(
                      color: const Color(0xFFF7D35D),
                      width: 2.5, // ------------------
                    ),
                  ),
                  child: Container(
                    height: screenSize.height * 0.13, // ------------------
                    width: screenSize.width * 0.45, // ------------------
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(batikImagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16), // ------------------
                
                // Level text
                Text(
                  'Jawab pertanyanan berikut\nuntuk memulai Level $levelNumber',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16, // ------------------
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF7D35D),
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 1.5, // Diperkecil
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16), // ------------------
                
                // Quiz question
                Text(
                  quizQuestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18, // ------------------
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3AAFC9),
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 1.5, // Diperkecil
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16), // ------------------
                
                // Answer input field
                Container(
                  width: screenSize.width * 0.45, // ------------------
                  padding: const EdgeInsets.symmetric(horizontal: 3), // ------------------
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6D0),
                    border: Border.all(color: const Color(0xFFBE8A39), width: 1.2), // ------------------
                    borderRadius: BorderRadius.circular(5), // ------------------
                  ),
                  child: TextField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      hintText: 'Jawaban anda',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // ------------------
                    ),
                  ),
                ),

                const SizedBox(height: 8), // ------------------
                
                // Hint text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Petunjuk: $quizHint',
                        style: const TextStyle(
                          fontSize: 12, // ------------------
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFFFF6D0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24), // ------------------
                
                // Custom buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = constraints.maxWidth < 400 
                        ? constraints.maxWidth * 0.3 // ------------------
                        : 110.0; // ------------------
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCustomButton(
                          label: 'BACK',
                          onPressed: onBackPressed,
                          width: buttonWidth,
                          height: 45, // ------------------
                        ),
                        _buildCustomButton(
                          label: 'START',
                          onPressed: onContinuePressed,
                          width: buttonWidth,
                          height: 45, // ------------------
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomButton({
    required String label, 
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tombol.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16, // ------------------
              fontWeight: FontWeight.bold,
              color: Color(0xFFF7D35D),
            ),
          ),
        ),
      ),
    );
  }
}