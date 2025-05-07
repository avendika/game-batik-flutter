import 'package:flutter/material.dart';
import '../services/game_setting.dart';
// import 'lobby_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Ensure game settings are initialized
    try {
      await GameSettings().ensureInitialized();
    } catch (e) {
      print('Error during splash screen initialization: $e');
    }
    
    // Navigate to LobbyScreen after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2B48C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or loading indicator
            const CircularProgressIndicator(color: Color(0xFFC49B5D)),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF2D0E00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}