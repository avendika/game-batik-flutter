import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_setting.dart';
import '../services/user_service.dart';
import 'register_screen.dart';
import 'lobby_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    // Start the login music when this screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameSettings().handleScreenTransition('login');
    });
    
    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();

    // Check if user is already logged in
    _checkLoggedInStatus();
  }

  void _checkLoggedInStatus() async {
    if (UserService().isLoggedIn) {
      // If user is already logged in, redirect to lobby
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LobbyScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

void _login() async {
  // Hide keyboard
  FocusScope.of(context).unfocus();
  
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });
  
  // Play sound effect
  GameSettings().playSfx('button_click.mp3');
  
  // Basic validation
  if (_usernameController.text.trim().isEmpty || 
      _passwordController.text.trim().isEmpty) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Harap isi semua field';
    });
    return;
  }
  
  try {
    // Login with API
    final success = await UserService().login(
      _usernameController.text.trim(), 
      _passwordController.text.trim()
    );
    
    if (success) {
      // Navigate to lobby screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LobbyScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Username atau password salah';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
    });
  }
}

  void _register() {
    // Play sound effect
    GameSettings().playSfx('button_click.mp3');
    
    showDialog(
      context: context,
      builder: (context) => RegisterDialog(
        onRegisterSuccess: () {
          setState(() {
            _errorMessage = 'Registrasi berhasil! Silakan login';
          });
        },
      ),
    );
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
    final panelWidth = screenWidth * 0.4;
    final panelHeight = availableHeight * 0.9; // Reduced panel height
    
    // Text fields width will be a percentage of the panel width
    final inputWidth = panelWidth * 0.85;
    
    // Reduced title sizing
    final titleFontSize = _clamp(screenHeight * 0.07, 19, 32); // Smaller font size

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Image.asset(
              'assets/background/bg_login.png',
              fit: BoxFit.cover,
            ),
            
            // Login panel
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: panelWidth,
                  height: panelHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2B48C).withOpacity(0.9),
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
                    vertical: availableHeight * 0.03,
                    horizontal: panelWidth * 0.07,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title with reduced size and spacing
                      _buildTitle('BATIK', titleFontSize),
                      const SizedBox(height: 4), // Reduced space between titles
                      _buildTitle('JOURNEY', titleFontSize),
                      SizedBox(height: availableHeight * 0.02), // Reduced spacing after title
                      
                      // Login Form with reduced spacing
                      _buildTextField(
                        controller: _usernameController, 
                        hintText: 'Username',
                        icon: Icons.person,
                        width: inputWidth,
                      ),
                      const SizedBox(height: 10), // Reduced spacing
                      _buildTextField(
                        controller: _passwordController, 
                        hintText: 'Password',
                        icon: Icons.lock,
                        width: inputWidth,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onToggleObscure: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      
                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12, // Smaller font size for error
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      const SizedBox(height: 16), // Reduced spacing
                      
                      // Login button with smaller size
                      _buildButton(
                        'MASUK',
                        onPressed: _isLoading ? null : _login,
                        width: inputWidth * 0.7, // Smaller button width
                        height: 40, // Smaller button height
                        isPrimary: true,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 10), // Reduced spacing
                      
                      // Register option with smaller text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(
                              color: Color(0xFF2D0E00),
                              fontSize: 12, // Smaller font size
                            ),
                          ),
                          TextButton(
                            onPressed: _register,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8), // Smaller padding
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: Color(0xFF8B4513),
                                fontWeight: FontWeight.bold,
                                fontSize: 12, // Smaller font size
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double width,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      width: width,
      height: 35, // Reduced height
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D0E00), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscureText,
        style: const TextStyle(
          color: Color(0xFF2D0E00),
          fontSize: 14, // Smaller font size
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF2D0E00).withOpacity(0.6),
            fontSize: 14, // Smaller font size
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF8B4513),
            size: 18, // Smaller icon
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF8B4513),
                    size: 18, // Smaller icon
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12, // Reduced padding
            horizontal: 12, // Reduced padding
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    VoidCallback? onPressed,
    required double width,
    double height = 48,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: 120,
      height: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF8B4513)
              : Colors.white.withOpacity(0.9),
          foregroundColor: isPrimary
              ? Colors.white
              : const Color(0xFF8B4513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: const Color(0xFF2D0E00),
              width: isPrimary ? 1 : 1.5,
            ),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
        ),
        child: isLoading
            ? const SizedBox(
                width: 20, // Smaller spinner
                height: 20, // Smaller spinner
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 14, // Smaller font size
                  fontWeight: FontWeight.bold,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xFF8B4513),
                ),
              ),
      ),
    );
  }
  
  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }
}