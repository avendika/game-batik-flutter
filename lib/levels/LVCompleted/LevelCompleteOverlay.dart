import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final VoidCallback onContinuePressed;
  final VoidCallback onBackPressed;
  final String levelNumber;
  final String batikImagePath;
  final String batikDescription;

  const LevelCompleteOverlay({
    super.key, 
    required this.onContinuePressed,
    required this.onBackPressed,
    required this.levelNumber,
    required this.batikImagePath,
    required this.batikDescription,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    return Material(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          width: isPortrait ? screenSize.width * 0.9 : screenSize.width * 0.85,
          height: isPortrait ? screenSize.height * 0.8 : screenSize.height * 0.80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Extended decorative frame background
              _buildExtendedBackground(context),
              
              // Content container
              Padding(
                padding: EdgeInsets.all(isPortrait ? 20.0 : 30.0),
                child: isPortrait 
                  ? _buildPortraitLayout(context)
                  : _buildLandscapeLayout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtendedBackground(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background/background_LC.png'),
          fit: isPortrait ? BoxFit.fitHeight : BoxFit.fitWidth,
          alignment: Alignment.center,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitleText(),
          SizedBox(height: screenSize.height * 0.02),
          _buildBatikImage(context),
          SizedBox(height: screenSize.height * 0.02),
          _buildDescriptionRow(context),
          SizedBox(height: screenSize.height * 0.03),
          _buildButtonRow(context),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left column with image
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleText(),
              SizedBox(height: screenSize.height * 0.03),
              _buildBatikImage(context),
            ],
          ),
        ),
        
        SizedBox(width: screenSize.width * 0.03),
        
        // Right column with description and buttons
        Expanded(
          flex: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDescriptionRow(context),
              SizedBox(height: screenSize.height * 0.05),
              _buildButtonRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleText() {
    return Text(
      'LEVEL $levelNumber\nCOMPLETED!',
      style: TextStyle(
        fontSize: _responsiveTextSize(32),
        fontWeight: FontWeight.bold,
        fontFamily: 'Folkard',
        color: const Color(0xFF5C3D00),
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBatikImage(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    return Container(
      height: isPortrait 
          ? screenSize.height * 0.25 
          : screenSize.height * 0.45,
      width: isPortrait 
          ? screenSize.width * 0.7 
          : screenSize.width * 0.35,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF7E4E24),
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          batikImagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDescriptionRow(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/topeng.png',
          height: isPortrait 
              ? screenSize.height * 0.1 
              : screenSize.height * 0.18,
        ),
        SizedBox(width: screenSize.width * 0.02),
        
        Expanded(
          child: Text(
            batikDescription,
            style: TextStyle(
              fontSize: _responsiveTextSize(16),
              height: 1.4,
              color: const Color(0xFF5C3D00),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStyledButton(
          onPressed: onBackPressed,
          label: 'BACK',
          width: isPortrait 
              ? screenSize.width * 0.35 
              : screenSize.width * 0.2,
        ),
        
        _buildStyledButton(
          onPressed: onContinuePressed,
          label: 'NEXT LEVEL',
          width: isPortrait 
              ? screenSize.width * 0.35 
              : screenSize.width * 0.2,
        ),
      ],
    );
  }
  
  Widget _buildStyledButton({
    required VoidCallback onPressed,
    required String label,
    required double width,
  }) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/tombol.png'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: _responsiveTextSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _responsiveTextSize(double baseSize) {
    final mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.window);
    final scaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.5);
    final isPortrait = mediaQuery.size.height > mediaQuery.size.width;
    
    if (isPortrait) {
      return baseSize * mediaQuery.size.shortestSide / 400 * scaleFactor;
    } else {
      return baseSize * mediaQuery.size.shortestSide / 450 * scaleFactor;
    }
  }
}