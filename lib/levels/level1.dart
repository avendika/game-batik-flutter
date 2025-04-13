import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'dart:ui';
import '../player/player_component.dart';
import '../points/points_display.dart';
import '../services/alert_notification.dart';
import '../points/point_object.dart';
import '../points/point_collector.dart';
import '../services/game_setting.dart';
import 'level2.dart';

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
    return flutter.Material(
      color: flutter.Colors.black.withOpacity(0.6),
      child: flutter.Center(
        child: flutter.Container(
          width: flutter.MediaQuery.of(context).size.width * 0.85,
          padding: const flutter.EdgeInsets.all(20),
          decoration: flutter.BoxDecoration(
            color: const flutter.Color(0xFFD6C6A8), // Warna latar kecoklatan
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
              const flutter.Text(
                'Level 1 Completed!',
                style: flutter.TextStyle(
                  fontSize: 28,
                  fontWeight: flutter.FontWeight.bold,
                  fontFamily: 'Serif',
                  color: flutter.Colors.black,
                ),
              ),
              const flutter.SizedBox(height: 15),
              const flutter.Divider(
                color: flutter.Color(0xFF8D7B63),
                thickness: 1.5,
                height: 10,
              ),
              flutter.Container(
                height: 120,
                width: 250,
                margin: const flutter.EdgeInsets.symmetric(vertical: 15),
                decoration: const flutter.BoxDecoration(
                  image: flutter.DecorationImage(
                    image: flutter.AssetImage('assets/images/batik_parang.png'),
                    fit: flutter.BoxFit.contain,
                  ),
                ),
              ),
              const flutter.SizedBox(height: 15),
              const flutter.Text(
                'Batik Parang adalah salah satu motif batik tertua di Indonesia. '
                'Bentuknya seperti huruf "S" yang saling berkaitan, melambangkan '
                'kesinambungan dan kesinambungan hidup. Motif ini berasal dari '
                'Jawa dan memiliki makna filosofis yang dalam.',
                textAlign: flutter.TextAlign.center,
                style: flutter.TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: flutter.Colors.black87,
                ),
              ),
              const flutter.SizedBox(height: 25),
              flutter.Row(
                mainAxisAlignment: flutter.MainAxisAlignment.spaceEvenly,
                children: [
                  // Back Button
                  flutter.ElevatedButton(
                    onPressed: onBackPressed,
                    style: flutter.ElevatedButton.styleFrom(
                      backgroundColor: const flutter.Color(0xFFCFC5B4),
                      foregroundColor: flutter.Colors.black,
                      padding: const flutter.EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: flutter.RoundedRectangleBorder(
                        borderRadius: flutter.BorderRadius.circular(5),
                      ),
                    ),
                    child: const flutter.Text(
                      'BACK',
                      style: flutter.TextStyle(
                        fontSize: 14,
                        fontWeight: flutter.FontWeight.bold,
                      ),
                    ),
                  ),
                  // Next Level Button
                  flutter.ElevatedButton(
                    onPressed: onContinuePressed,
                    style: flutter.ElevatedButton.styleFrom(
                      backgroundColor: const flutter.Color(0xFFCFC5B4),
                      foregroundColor: flutter.Colors.black,
                      padding: const flutter.EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: flutter.RoundedRectangleBorder(
                        borderRadius: flutter.BorderRadius.circular(5),
                      ),
                    ),
                    child: const flutter.Text(
                      'NEXT LEVEL',
                      style: flutter.TextStyle(
                        fontSize: 14,
                        fontWeight: flutter.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Level1Screen extends flutter.StatelessWidget {
  const Level1Screen({super.key});

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      body: flutter.Stack(
        children: [
          GameWidget<Level1Game>(
            game: Level1Game(),
            overlayBuilderMap: {
              'LevelCompleteOverlay': (flutter.BuildContext context, Level1Game game) {
                return LevelCompleteOverlay(
                  onBackPressed: () {
                    game.overlays.remove('LevelCompleteOverlay');
                    flutter.Navigator.pop(context);
                  },
                  onContinuePressed: () {
                    game.overlays.remove('LevelCompleteOverlay');
                    flutter.Navigator.pushReplacement(
                      context,
                      flutter.MaterialPageRoute(
                        builder: (context) => const Level2Screen(),
                      ),
                    );
                  },
                );
              },
              'PointsDisplay': (flutter.BuildContext context, Level1Game game) {
                return flutter.Positioned(
                  top: 20,
                  right: 20,
                  child: PointsDisplay(
                    collected: game.collectedPoints,
                    total: game.totalPoints,
                  ),
                );
              },
              'AlertMessage': (flutter.BuildContext context, Level1Game game) {
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

class Level1Game extends FlameGame with DragCallbacks, HasCollisionDetection implements PointCollector {
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
  final Vector2 playerStartPosition = Vector2(900, 210);
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
      overlays.add('LevelCompleteOverlay');
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
    map = await TiledComponent.load('level1.tmx', Vector2.all(tileSize));
    world.add(map);

    mapDimensions = Vector2(
      map.tileMap.map.width * tileSize,
      map.tileMap.map.height * tileSize,
    );
  }

  Future<void> _createPlayer() async {
    final spriteSheet = SpriteSheet(
      image: await images.load('character_walk.png'),
      srcSize: Vector2(104, 150),
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