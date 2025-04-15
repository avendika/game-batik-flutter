import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/game_setting.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize game settings with error handling
  try {
    await GameSettings().initialize();
  } catch (e) {
    print('Error initializing game settings: $e');
    // Continue anyway to prevent app from hanging
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batik Journey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Use a splash screen first
    );
  }
}