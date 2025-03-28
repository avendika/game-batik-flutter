import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: MyGame()),
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          ),
        ],
      ),
    );
  }
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    debugPrint("Game dimulai!");
    // Nanti load peta Tiled di sini
  }
}
