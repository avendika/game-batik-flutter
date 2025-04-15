import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'dart:ui';
import 'dart:async';
import '../player/player_component.dart';
import '../points/points_display.dart';
import '../services/alert_notification.dart';
import '../points/point_object.dart';
import '../points/point_collector.dart';
import '../services/game_setting.dart';

class LevelCompleteOverlay extends flutter.StatelessWidget {
  final VoidCallback onContinuePressed;
  final VoidCallback onBackPressed;

  const LevelCompleteOverlay({
    super.key, 
    required this.onContinuePressed,
    required this.onBackPressed,
  });

  @override
  flutter.Widget build(flutter.BuildContext context) {
    final screenSize = flutter.MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    
    return flutter.Material(
      color: flutter.Colors.black.withOpacity(0.6),
      child: flutter.Center(
        child: flutter.SingleChildScrollView(
          padding: const flutter.EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: flutter.Container(
            width: screenSize.width > 600 ? 550 : screenSize.width * 0.9,
            padding: flutter.EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: flutter.BoxDecoration(
              color: const flutter.Color(0xFFD6C6A8),
              borderRadius: flutter.BorderRadius.circular(15),
              boxShadow: [
                flutter.BoxShadow(
                  color: flutter.Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: flutter.Column(
              mainAxisSize: flutter.MainAxisSize.min,
              children: [
                flutter.Text(
                  'Level 3 Completed!',
                  style: flutter.TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: flutter.FontWeight.bold,
                    fontFamily: 'Serif',
                    color: flutter.Colors.black,
                  ),
                  textAlign: flutter.TextAlign.center,
                ),
                const flutter.SizedBox(height: 15),
                const flutter.Divider(
                  color: flutter.Color(0xFF8D7B63),
                  thickness: 1.5,
                  height: 10,
                ),
                flutter.Container(
                  height: screenSize.height * 0.15,
                  width: screenSize.width * 0.5,
                  margin: flutter.EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 15),
                  decoration: const flutter.BoxDecoration(
                    image: flutter.DecorationImage(
                      image: flutter.AssetImage('assets/images/batik_mega_mendung.png'),
                      fit: flutter.BoxFit.contain,
                    ),
                  ),
                ),
                const flutter.SizedBox(height: 10),
                flutter.Text(
                  'Motif Mega Mendung berasal dari Cirebon dan menggambarkan awan pembawa hujan. '
                  'Batik ini memiliki makna kesabaran dan tidak mudah marah. Warna dominannya '
                  'biru dengan gradasi yang indah, melambangkan langit yang luas.',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    height: 1.4,
                    color: flutter.Colors.black87,
                  ),
                ),
                flutter.SizedBox(height: isSmallScreen ? 20 : 25),
                flutter.Wrap(
                  alignment: flutter.WrapAlignment.spaceEvenly,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // Back Button
                    flutter.SizedBox(
                      width: isSmallScreen ? screenSize.width * 0.35 : 140,
                      child: flutter.ElevatedButton(
                        onPressed: onBackPressed,
                        style: flutter.ElevatedButton.styleFrom(
                          backgroundColor: const flutter.Color(0xFFCFC5B4),
                          foregroundColor: flutter.Colors.black,
                          padding: flutter.EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 15 : 30, 
                            vertical: 12
                          ),
                          shape: flutter.RoundedRectangleBorder(
                            borderRadius: flutter.BorderRadius.circular(5),
                          ),
                        ),
                        child: flutter.Text(
                          'BACK',
                          style: flutter.TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: flutter.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Next Level Button
                    flutter.SizedBox(
                      width: isSmallScreen ? screenSize.width * 0.35 : 140,
                      child: flutter.ElevatedButton(
                        onPressed: onContinuePressed,
                        style: flutter.ElevatedButton.styleFrom(
                          backgroundColor: const flutter.Color(0xFFCFC5B4),
                          foregroundColor: flutter.Colors.black,
                          padding: flutter.EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 15 : 30, 
                            vertical: 12
                          ),
                          shape: flutter.RoundedRectangleBorder(
                            borderRadius: flutter.BorderRadius.circular(5),
                          ),
                        ),
                        child: flutter.Text(
                          'NEXT LEVEL',
                          style: flutter.TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: flutter.FontWeight.bold,
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
}

class BatikQuestionOverlay extends flutter.StatelessWidget {
  final flutter.TextEditingController answerController;
  final VoidCallback onContinuePressed;
  final VoidCallback onBackPressed;

  const BatikQuestionOverlay({
    super.key,
    required this.answerController,
    required this.onContinuePressed,
    required this.onBackPressed,
  });

  @override
  flutter.Widget build(flutter.BuildContext context) {
    final screenSize = flutter.MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final safePadding = flutter.MediaQuery.of(context).padding;

    return flutter.Material(
      color: const flutter.Color(0xFFD9C9A9),
      child: flutter.Center(
        child: flutter.SingleChildScrollView(
          padding: flutter.EdgeInsets.only(
            top: safePadding.top + 10,
            bottom: safePadding.bottom + 10,
            left: 16,
            right: 16,
          ),
          child: flutter.Container(
            width: screenSize.width > 600 ? 550 : screenSize.width * 0.95,
            padding: flutter.EdgeInsets.symmetric(
              vertical: isSmallScreen ? 16 : 20,
              horizontal: isSmallScreen ? 16 : 20,
            ),
            child: flutter.Column(
              mainAxisAlignment: flutter.MainAxisAlignment.center,
              mainAxisSize: flutter.MainAxisSize.min,
              children: [
                flutter.Text(
                  'QUIZ',
                  style: flutter.TextStyle(
                    fontSize: isSmallScreen ? 28 : 32,
                    fontWeight: flutter.FontWeight.bold,
                    color: flutter.Colors.black,
                  ),
                ),
                flutter.Container(
                  height: 8,
                  width: screenSize.width * (isSmallScreen ? 0.7 : 0.6),
                  decoration: const flutter.BoxDecoration(
                    color: flutter.Colors.black12,
                  ),
                ),
                flutter.SizedBox(height: isSmallScreen ? 15 : 20),

                // Batik Image - Updated to Mega Mendung
                flutter.Container(
                  height: screenSize.height * 0.15,
                  width: screenSize.width * 0.45,
                  decoration: flutter.BoxDecoration(
                    borderRadius: flutter.BorderRadius.circular(12),
                    image: const flutter.DecorationImage(
                      image: flutter.AssetImage('assets/images/batik_mega_mendung.png'),
                      fit: flutter.BoxFit.cover,
                    ),
                  ),
                ),

                flutter.SizedBox(height: isSmallScreen ? 15 : 20),
                flutter.Text(
                  'Jawab pertanyaan berikut untuk memulai Level 3',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),

                flutter.SizedBox(height: isSmallScreen ? 12 : 15),
                flutter.Text(
                  'Apa makna filosofi dari motif Batik Mega Mendung?',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: flutter.FontWeight.bold,
                    color: flutter.Colors.blue,
                  ),
                ),

                flutter.SizedBox(height: isSmallScreen ? 12 : 15),
                flutter.Container(
                  padding: const flutter.EdgeInsets.symmetric(horizontal: 5),
                  decoration: flutter.BoxDecoration(
                    color: flutter.Colors.white,
                    border: flutter.Border.all(color: flutter.Colors.grey.shade300),
                    borderRadius: flutter.BorderRadius.circular(5),
                  ),
                  child: flutter.TextField(
                    controller: answerController,
                    decoration: const flutter.InputDecoration(
                      hintText: 'Jawaban anda',
                      border: flutter.InputBorder.none,
                    ),
                  ),
                ),

                const flutter.SizedBox(height: 10),
                flutter.Row(
                  mainAxisAlignment: flutter.MainAxisAlignment.end,
                  children: [
                    flutter.Flexible(
                      child: flutter.Text(
                        'Petunjuk: Berhubungan dengan emosi dan pengendalian diri',
                        style: flutter.TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontStyle: flutter.FontStyle.italic,
                        ),
                        textAlign: flutter.TextAlign.end,
                      ),
                    ),
                  ],
                ),

                flutter.SizedBox(height: isSmallScreen ? 20 : 25),
                flutter.LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 350;

                    if (isNarrow) {
                      // Kalau layar sempit, tombol ditumpuk ke bawah
                      return flutter.Column(
                        children: [
                          flutter.SizedBox(
                            width: double.infinity,
                            child: flutter.ElevatedButton(
                              onPressed: onBackPressed,
                              style: flutter.ElevatedButton.styleFrom(
                                backgroundColor: flutter.Colors.grey.shade300,
                                foregroundColor: flutter.Colors.black,
                                minimumSize: const flutter.Size(120, 45),
                              ),
                              child: const flutter.Text(
                                'BACK',
                                style: flutter.TextStyle(fontWeight: flutter.FontWeight.bold),
                              ),
                            ),
                          ),
                          const flutter.SizedBox(height: 10),
                          flutter.SizedBox(
                            width: double.infinity,
                            child: flutter.ElevatedButton(
                              onPressed: onContinuePressed,
                              style: flutter.ElevatedButton.styleFrom(
                                backgroundColor: flutter.Colors.white,
                                foregroundColor: flutter.Colors.black,
                                minimumSize: const flutter.Size(120, 45),
                              ),
                              child: const flutter.Text(
                                'START',
                                style: flutter.TextStyle(fontWeight: flutter.FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Kalau lebar cukup, tombol berjejer
                      return flutter.Row(
                        mainAxisAlignment: flutter.MainAxisAlignment.spaceEvenly,
                        children: [
                          flutter.SizedBox(
                            width: 120,
                            child: flutter.ElevatedButton(
                              onPressed: onBackPressed,
                              style: flutter.ElevatedButton.styleFrom(
                                backgroundColor: flutter.Colors.grey.shade300,
                                foregroundColor: flutter.Colors.black,
                                minimumSize: const flutter.Size(120, 45),
                              ),
                              child: const flutter.Text(
                                'BACK',
                                style: flutter.TextStyle(fontWeight: flutter.FontWeight.bold),
                              ),
                            ),
                          ),
                          flutter.SizedBox(
                            width: 120,
                            child: flutter.ElevatedButton(
                              onPressed: onContinuePressed,
                              style: flutter.ElevatedButton.styleFrom(
                                backgroundColor: flutter.Colors.white,
                                foregroundColor: flutter.Colors.black,
                                minimumSize: const flutter.Size(120, 45),
                              ),
                              child: const flutter.Text(
                                'START',
                                style: flutter.TextStyle(fontWeight: flutter.FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Level3Screen extends flutter.StatefulWidget {
  const Level3Screen({super.key});

  @override
  flutter.State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends flutter.State<Level3Screen> {
  late final Level3Game game;
  late final flutter.TextEditingController _answerController;
  bool _showQuestion = true;

  @override
  void initState() {
    super.initState();
    game = Level3Game();
    _answerController = flutter.TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showQuestion = false;
    });
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      body: flutter.Stack(
        children: [
          if (!_showQuestion)
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'Leve3CompleteOverlay': (context, game) => LevelCompleteOverlay(
                  onBackPressed: () => flutter.Navigator.pop(context),
                  onContinuePressed: () {}, // Handle level completion
                ),
              'PointsDisplay': (flutter.BuildContext context, Level3Game game) {
                return flutter.Positioned(
                  top: 20,
                  right: 20,
                  child: PointsDisplay(
                    collected: game.collectedPoints,
                    total: game.totalPoints,
                  ),
                );
              },
              'AlertMessage': (flutter.BuildContext context, Level3Game game) {
                return flutter.Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: flutter.Center(
                    child: AlertNotification(
                      message: '! Carilah puzzle tersembunyi untuk menyelesaikan level ini',
                    ),
                  ),
                );
              },
              },
            ),
          
          if (_showQuestion)
            BatikQuestionOverlay(
              answerController: _answerController,
              onBackPressed: () => flutter.Navigator.pop(context),
              onContinuePressed: () {
                final answer = _answerController.text.trim().toLowerCase();
                if (answer.contains('kesabaran') || 
                    answer.contains('sabar') ||
                    answer.contains('tidak mudah marah')) {
                  _startGame();
                } else {
                  flutter.ScaffoldMessenger.of(context).showSnackBar(
                    const flutter.SnackBar(
                      content: flutter.Text('Jawaban salah! Coba lagi.'),
                      backgroundColor: flutter.Colors.red,
                    ),
                  );
                }
              },
            ),
          
          if (!_showQuestion)
            flutter.Positioned(
              top: 20,
              left: 20,
              child: flutter.ElevatedButton(
                onPressed: () => flutter.Navigator.pop(context),
                style: flutter.ElevatedButton.styleFrom(
                  backgroundColor: flutter.Colors.orangeAccent,
                  foregroundColor: flutter.Colors.white,
                ),
                child: const flutter.Text('Kembali'),
              ),
            ),
        ],
      ),
    );
  }
}

class Level3Game extends FlameGame with DragCallbacks, HasCollisionDetection implements PointCollector{
  late final TiledComponent map;
  PlayerComponent? player;
  late final JoystickComponent joystick;
  final List<RectangleHitbox> collisionBlocks = [];
  int totalPoints = 0;
  int collectedPoints = 0;
  bool _levelCompleted = false;

  final GameSettings settings = GameSettings();

  static const double tileSize = 64.0;
  late final Vector2 mapDimensions;
  final Vector2 playerStartPosition = Vector2(2700, 100);
  final Vector2 playerSize = Vector2(64, 96);

  void collectPoint() {
    collectedPoints++;
    // Play sound effect using settings
    settings.playSfx('claim.mp3');
    // Update the points display
    overlays.remove('PointsDisplay');
    overlays.add('PointsDisplay');

    if (collectedPoints >= totalPoints && !_levelCompleted) {
      _levelCompleted = true;
      settings.playSfx('level_complete.mp3');
      overlays.add('Leve3CompleteOverlay');
    }
  }
@override
  void onRemove() {
    // Stop background music when level is removed
    settings.stopBackgroundMusic();
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Ganti musik latar ketika level dimulai
      settings.stopBackgroundMusic(); // Hentikan musik lobby
      settings.playBackgroundMusic('background_music.mp3'); // Mainkan musik gameplay
      
      // Load map and initialize game components
      await _loadMap();
      await _extractCollisionObjects();
      await _extractPointObjects();
      await _createPlayer();
      _setupCamera();
      _setupJoystick();
      // Add overlays for points display and alert message
      overlays.add('PointsDisplay');
      overlays.add('AlertMessage');

    } catch (e) {
      print('Error during loading: $e');
    }
  }

  Future<void> _loadMap() async {
    map = await TiledComponent.load('level3.tmx', Vector2.all(tileSize));
    world.add(map);

    mapDimensions = Vector2(
      map.tileMap.map.width * tileSize,
      map.tileMap.map.height * tileSize,
    );
  }

  Future<void> _createPlayer() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('Pokemon.png'),
      srcSize: Vector2(64, 64),
    );

    player = PlayerComponent(
      spriteSheet: spriteSheet,
      position: playerStartPosition,
      size: playerSize,
    );

    // Set collision blocks and map dimensions
    player!.setCollisionBlocks(collisionBlocks);
    player!.setMapDimensions(mapDimensions);

    world.add(player!);
  }

  void _setupCamera() {
    camera.viewfinder.anchor = Anchor.center;
    if (player != null) {
      camera.follow(player!);
    }
  }

  void _setupJoystick() {
    final knobPaint = Paint()..color = flutter.Colors.blue.withOpacity(0.8);
    final backgroundPaint = Paint()..color = flutter.Colors.blueGrey.withOpacity(0.5);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      position: Vector2(100, size.y - 100),
    );

    camera.viewport.add(joystick);
  }

  Future<void> _extractCollisionObjects() async {
    final collisionLayer = map.tileMap.getLayer<ObjectGroup>('Collision');

    if (collisionLayer != null) {
      final scaleFactor = tileSize / map.tileMap.map.tileWidth;

      for (final obj in collisionLayer.objects) {
        final position = Vector2(obj.x, obj.y) * scaleFactor;
        final size = Vector2(obj.width, obj.height) * scaleFactor;

        final collisionBlock = RectangleHitbox(
          position: position,
          size: size,
        );

        world.add(
          PositionComponent(
            position: Vector2.zero(),
            size: Vector2.zero(),
            children: [collisionBlock],
          ),
        );

        collisionBlocks.add(collisionBlock);
      }
    }
  }

  Future<void> _extractPointObjects() async {
    final pointLayer = map.tileMap.getLayer<ObjectGroup>('Point');

    if (pointLayer != null) {
      final scaleFactor = tileSize / map.tileMap.map.tileWidth;

      for (final obj in pointLayer.objects) {
        final position = Vector2(obj.x, obj.y) * scaleFactor;
        final size = Vector2(obj.width, obj.height) * scaleFactor;

        final spriteName = obj.name; // <-- Ambil nama dari Tiled

        final pointObject = PointObject(
          spriteName: spriteName,
          position: position,
          size: size,
        );

        world.add(pointObject);
        totalPoints++;
      }
    } else {
      print('Point layer not found in the map');
    }
  }


  @override
  void update(double dt) {
    super.update(dt);

    _updateCamera();
    _updatePlayerMovement(dt);
  }

  void _updateCamera() {
    if (player != null) {
      final halfWidth = camera.viewport.size.x / 2;
      final halfHeight = camera.viewport.size.y / 2;

      final minCameraX = halfWidth;
      final minCameraY = halfHeight;
      final maxCameraX = mapDimensions.x - halfWidth;
      final maxCameraY = mapDimensions.y - halfHeight;

      Vector2 targetPosition = player!.position.clone();

      if (mapDimensions.x > camera.viewport.size.x) {
        targetPosition.x = targetPosition.x.clamp(minCameraX, maxCameraX);
      } else {
        targetPosition.x = mapDimensions.x / 2;
      }

      if (mapDimensions.y > camera.viewport.size.y) {
        targetPosition.y = targetPosition.y.clamp(minCameraY, maxCameraY);
      } else {
        targetPosition.y = mapDimensions.y / 2;
      }

      camera.moveTo(targetPosition);
    }
  }

  void _updatePlayerMovement(double dt) {
    if (player != null) {
      player!.updateMovement(dt, joystick.direction, joystick.delta);
    }
  }
}