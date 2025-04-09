import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'dart:ui';
import 'dart:async';
import '../player/player_component.dart';

class PointObject extends SpriteComponent with HasGameRef, CollisionCallbacks {
  PointObject({required Vector2 position, required Vector2 size})
      : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await game.images.load('point_image.png'));
    add(RectangleHitbox(size: size, position: Vector2.zero(), anchor: Anchor.center));
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true, alternate: true),
      ),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      removeFromParent();
      (game as Level2Game).collectPoint();
    }
  }
}

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
                  'Level 2 Completed!',
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

                // Batik Image
                flutter.Container(
                  height: screenSize.height * 0.15,
                  width: screenSize.width * 0.45,
                  decoration: flutter.BoxDecoration(
                    borderRadius: flutter.BorderRadius.circular(12),
                    image: const flutter.DecorationImage(
                      image: flutter.AssetImage('assets/images/batik_parang.png'),
                      fit: flutter.BoxFit.cover,
                    ),
                  ),
                ),

                flutter.SizedBox(height: isSmallScreen ? 15 : 20),
                flutter.Text(
                  'Jawab pertanyaan berikut untuk memulai Level 2',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),

                flutter.SizedBox(height: isSmallScreen ? 12 : 15),
                flutter.Text(
                  'Apa makna filosofi dari motif Batik Parang?',
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
                        'Petunjuk : Berhubungan dengan kesinambungan hidup',
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

class Level2Screen extends flutter.StatefulWidget {
  const Level2Screen({super.key});

  @override
  flutter.State<Level2Screen> createState() => _Level2ScreenState();
}

class _Level2ScreenState extends flutter.State<Level2Screen> {
  late final Level2Game game;
  late final flutter.TextEditingController _answerController;
  bool _showQuestion = true;

  @override
  void initState() {
    super.initState();
    game = Level2Game();
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
                'Leve2CompleteOverlay': (context, game) => LevelCompleteOverlay(
                  onBackPressed: () => flutter.Navigator.pop(context),
                  onContinuePressed: () {}, // Handle level completion
                ),
              },
            ),
          
          if (_showQuestion)
            BatikQuestionOverlay(
              answerController: _answerController,
              onBackPressed: () => flutter.Navigator.pop(context),
              onContinuePressed: () {
                final answer = _answerController.text.trim().toLowerCase();
                if (answer.contains('kesinambungan') || 
                    answer.contains('kontinuitas') ||
                    answer.contains('keberlanjutan')) {
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

class Level2Game extends FlameGame with DragCallbacks, HasCollisionDetection {
  late final TiledComponent map;
  PlayerComponent? player;
  late final JoystickComponent joystick;
  final List<RectangleHitbox> collisionBlocks = [];
  int totalPoints = 0;
  int collectedPoints = 0;
  bool _levelCompleted = false;

  static const double tileSize = 64.0;
  late final Vector2 mapDimensions;
  final Vector2 playerStartPosition = Vector2(1350, 250);
  final Vector2 playerSize = Vector2(64, 96);

  void collectPoint() {
    collectedPoints++;
    if (collectedPoints >= totalPoints && !_levelCompleted) {
      _levelCompleted = true;
      overlays.add('Leve2CompleteOverlay');
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load map and initialize game components
      await _loadMap();
      await _extractCollisionObjects();
      await _extractPointObjects();
      await _createPlayer();
      _setupCamera();
      _setupJoystick();
    } catch (e) {
      print('Error during loading: $e');
    }
  }

  Future<void> _loadMap() async {
    map = await TiledComponent.load('level2.tmx', Vector2.all(tileSize));
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

        final pointObject = PointObject(
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