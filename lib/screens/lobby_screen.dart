import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_setting.dart';
import '../services/user_service.dart';
import 'tutorial_screen.dart';
import 'materi_screen.dart';
import 'settings_screen.dart';
import '../levels/level_selection.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
            // Background
            Image.asset(
              'assets/background/lobby_background.png',
              fit: BoxFit.cover,
            ),

            // Animated Clouds
            if (_areAnimationsInitialized) ..._buildCloudAnimations(screenWidth, screenHeight, true),

            // Profile Button in top left corner
            _buildProfileButton(context),

            // Main Menu Panel
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

Widget _buildProfileButton(BuildContext context) {
  final currentUser = UserService().currentUser;
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.width < 400;
  
  if (currentUser == null) {
    return const SizedBox.shrink(); // Don't show if not logged in
  }
  
  return Positioned(
    top: 16.0,
    left: 16.0,
    child: GestureDetector(
      onTap: () {
        GameSettings().playSfx('button_click.mp3');
        _showProfileDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD2B48C).withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D0E00), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        child: Row(
          children: [
            // Profile Avatar - Using safe image display
            _buildAvatarDisplay(currentUser.avatar, isSmallScreen ? 30 : 40),
            SizedBox(width: isSmallScreen ? 4 : 8),
            // Username
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSmallScreen && currentUser.username.length > 8
                      ? '${currentUser.username.substring(0, 8)}...'
                      : currentUser.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D0E00),
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color(0xFFC49B5D),
                      size: isSmallScreen ? 12 : 14,
                    ),
                    SizedBox(width: isSmallScreen ? 1 : 2),
                    Text(
                      'Level ${currentUser.level}',
                      style: TextStyle(
                        color: const Color(0xFF8B4513),
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_drop_down,
              color: const Color(0xFF8B4513),
              size: isSmallScreen ? 20 : 24,
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper method to safely display avatar from any source
Widget _buildAvatarDisplay(String avatarPath, double size) {
  // Check if it's a network URL
  if (avatarPath.startsWith('http')) {
    try {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF8B4513),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            avatarPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading network avatar: $error');
              // Fallback to default avatar on error
              return Image.asset(
                'assets/avatars/default.png',
                fit: BoxFit.cover,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2.0,
                  color: const Color(0xFF8B4513),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Avatar display error: $e');
      // Continue to fallback below
    }
  }
  
  // For local file or asset image (or as fallback)
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFF8B4513),
        width: 2,
      ),
      image: DecorationImage(
        image: _safeImageProvider(avatarPath),
        fit: BoxFit.cover,
      ),
    ),
  );
}

// Helper method to safely get image provider
ImageProvider _safeImageProvider(String path) {
  // Try to avoid "asset://" or other invalid prefixes
  if (path.startsWith('http')) {
    // This already should be handled by the main method, but just in case
    return NetworkImage(path);
  } else if (!kIsWeb && (path.startsWith('/') || path.startsWith('file://'))) {
    try {
      return FileImage(File(path.replaceFirst('file://', '')));
    } catch (e) {
      debugPrint('Error creating FileImage: $e');
    }
  }
  
  // Default to asset image
  try {
    return AssetImage(path);
  } catch (e) {
    debugPrint('Error loading asset: $e');
    return const AssetImage('assets/avatars/default.png');
  }
}

void _showProfileDialog(BuildContext context) {
  final currentUser = UserService().currentUser;
  if (currentUser == null) return;

  // Get screen dimensions
  final screenSize = MediaQuery.of(context).size;
  final dialogWidth = screenSize.width < 600 
      ? screenSize.width * 0.85 
      : 400.0;
  final isSmallScreen = screenSize.width < 400;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: dialogWidth,
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            color: const Color(0xFFD2B48C).withOpacity(0.95),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'PROFIL PEMAIN',
                  style: GoogleFonts.cinzelDecorative(
                    textStyle: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
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
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Avatar (clickable now)
              GestureDetector(
                onTap: () {
                  GameSettings().playSfx('button_click.mp3');
                  _showAvatarSelectionDialog(context);
                },
                child: Container(
                  width: isSmallScreen ? 70 : 80,
                  height: isSmallScreen ? 70 : 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8B4513),
                      width: 3,
                    ),
                    image: DecorationImage(
                      image: AssetImage(currentUser.avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Add a hint for tap
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white.withOpacity(0.8),
                      size: isSmallScreen ? 24 : 30,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Username
              Text(
                currentUser.username,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D0E00),
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              
              // Level and Score
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatItem(
                    icon: Icons.star,
                    label: 'Level',
                    value: '${currentUser.level}',
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  _buildStatItem(
                    icon: Icons.emoji_events,
                    label: 'Skor',
                    value: '${currentUser.score}',
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Logout and Close buttons in one row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logout button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        GameSettings().playSfx('button_click.mp3');
                        await UserService().logout();
                        if (mounted) {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF2D0E00),
                            width: 1,
                          ),
                        ),
                        elevation: 4,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      child: Text(
                        'KELUAR',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Close button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        GameSettings().playSfx('button_click.mp3');
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF2D0E00),
                            width: 1.5,
                          ),
                        ),
                        elevation: 3,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      child: Text(
                        'TUTUP',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildStatItem({
  required IconData icon,
  required String label,
  required String value,
  double fontSize = 14,
}) {
  return Column(
    children: [
      Icon(
        icon,
        color: const Color(0xFFC49B5D),
        size: fontSize * 1.5,
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: const Color(0xFF8B4513),
          fontSize: fontSize,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D0E00),
          fontSize: fontSize + 2,
        ),
      ),
    ],
  );
}

void _showAvatarSelectionDialog(BuildContext context) {
  final currentUser = UserService().currentUser;
  if (currentUser == null) return;
  
  // Get screen dimensions
  final screenSize = MediaQuery.of(context).size;
  final dialogWidth = screenSize.width < 600 
      ? screenSize.width * 0.85 
      : 400.0;
  final isSmallScreen = screenSize.width < 400;
  
  String selectedAvatar = currentUser.avatar;
  bool isLoading = false;
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFD2B48C).withOpacity(0.95),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Avatar',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D0E00),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Avatar Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 3 : 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: UserService().availableAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = UserService().availableAvatars[index];
                    final isSelected = selectedAvatar == avatar;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar;
                        });
                        GameSettings().playSfx('button_click.mp3');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8B4513)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading avatar: $avatar - $error');
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Upload custom avatar button
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      GameSettings().playSfx('button_click.mp3');
                      _showCustomAvatarPickerDialog(context, (newAvatar) {
                        setState(() {
                          selectedAvatar = newAvatar;
                        });
                      });
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("Tambah Kustom"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6D7B9),
                      foregroundColor: const Color(0xFF8B4513),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFF2D0E00),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        GameSettings().playSfx('button_click.mp3');
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF2D0E00),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        'BATAL',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (isLoading) 
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
                      )
                    else
                      ElevatedButton(
                        onPressed: () async {
                          GameSettings().playSfx('button_click.mp3');
                          
                          setState(() {
                            isLoading = true;
                          });
                          
                          // Update avatar
                          final success = await UserService().updateProfile(newAvatar: selectedAvatar);
                          
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                            
                            if (success) {
                              Navigator.pop(context); // Close avatar dialog
                              Navigator.pop(context); // Close profile dialog
                              _showProfileDialog(context); // Reopen profile dialog to show changes
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal memperbarui avatar'),
                                  backgroundColor: Colors.red,
                                )
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF2D0E00),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'SIMPAN',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// Method to display custom avatar picker dialog
void _showCustomAvatarPickerDialog(BuildContext context, Function(String) onAvatarSelected) {
  // final isSmallScreen = MediaQuery.of(context).size.width < 400;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFD2B48C),
      title: const Text(
        'Pilih Sumber Gambar',
        style: TextStyle(
          color: Color(0xFF2D0E00),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF8B4513)),
            title: const Text(
              'Galeri',
              style: TextStyle(color: Color(0xFF2D0E00)),
            ),
            onTap: () async {
              Navigator.pop(context);
              GameSettings().playSfx('button_click.mp3');
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B4513),
                  ),
                ),
              );
              
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                
                // Close loading indicator
                if (context.mounted) Navigator.pop(context);
                
                if (image != null) {
                  if (kIsWeb) {
                    // Handle web platform
                    final bytes = await image.readAsBytes();
                    final base64String = base64Encode(bytes);
                    final dataUri = 'data:image/png;base64,$base64String';
                    onAvatarSelected(dataUri);
                  } else {
                    // Handle mobile platform
                    onAvatarSelected(image.path);
                  }
                }
              } catch (e) {
                // Close loading indicator
                if (context.mounted) Navigator.pop(context);
                
                debugPrint('Error picking image: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memilih gambar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          if (!kIsWeb) // Camera option only for mobile
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF8B4513)),
              title: const Text(
                'Kamera',
                style: TextStyle(color: Color(0xFF2D0E00)),
              ),
              onTap: () async {
                Navigator.pop(context);
                GameSettings().playSfx('button_click.mp3');
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF8B4513),
                    ),
                  ),
                );
                
                try {
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                  );
                  
                  // Close loading indicator
                  if (context.mounted) Navigator.pop(context);
                  
                  if (photo != null) {
                    onAvatarSelected(photo.path);
                  }
                } catch (e) {
                  // Close loading indicator
                  if (context.mounted) Navigator.pop(context);
                  
                  debugPrint('Error taking photo: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengambil foto: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            'Batal',
            style: TextStyle(color: Color(0xFF8B4513)),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
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