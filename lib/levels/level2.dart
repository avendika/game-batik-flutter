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
import '../models/direction.dart';
import '../player/player_component.dart';

class PointObject extends SpriteComponent with HasGameRef, CollisionCallbacks {
  PointObject({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await game.images.load('point_image.png'));

    add(
      RectangleHitbox(
        size: size,
        position: Vector2.zero(),
        anchor: Anchor.center,
      ),
    );

    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.5,
          reverseDuration: 0.5,
          infinite: true,
          alternate: true,
        ),
      ),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerComponent) {
      removeFromParent();
      (game as Level2Game).pointObjects.remove(this);
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
    return flutter.Material(
      color: flutter.Colors.black.withOpacity(0.5),
      child: flutter.Center(
        child: flutter.Container(
          width: flutter.MediaQuery.of(context).size.width * 0.9,
          padding: const flutter.EdgeInsets.all(20),
          decoration: flutter.BoxDecoration(
            color: flutter.Colors.white,
            borderRadius: flutter.BorderRadius.circular(20),
            boxShadow: [
              flutter.BoxShadow(
                color: flutter.Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: flutter.SingleChildScrollView(
            child: flutter.Column(
              mainAxisSize: flutter.MainAxisSize.min,
              children: [

                const flutter.Text(
                  'LEVEL 3 COMPLETED!',
                  style: flutter.TextStyle(
                    fontSize: 24,
                    fontWeight: flutter.FontWeight.bold,
                    color: flutter.Colors.green,
                  ),
                ),

                // Batik Image
                flutter.Container(
                  height: 200, // Increased height to show more of the image
                  width: double.infinity,
                  margin: const flutter.EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: flutter.BoxDecoration(
                    borderRadius: flutter.BorderRadius.circular(10),
                    image: const flutter.DecorationImage(
                      image: flutter.AssetImage('assets/images/batik_mega_mendung.png'),
                      fit: flutter.BoxFit.contain, // Changed from fitWidth to contain
                    ),
                  ),
                ),
                const flutter.SizedBox(height: 20),
                
                const flutter.SizedBox(height: 20),
                const flutter.Text(
                'Materi Batik: Motif Mega Mendung',                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: 20,
                    fontWeight: flutter.FontWeight.bold,
                    color: flutter.Colors.deepOrange,
                  ),
                ),
                const flutter.SizedBox(height: 15),
                const flutter.Text(
                  'Motif Mega Mendung berasal dari Cirebon dan menggambarkan awan pembawa hujan. '
                  'Batik ini memiliki makna kesabaran dan tidak mudah marah. Warna dominannya '
                  'biru dengan gradasi yang indah, melambangkan langit yang luas.',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: 16,
                  ),
                ),
                const flutter.SizedBox(height: 20),
                const flutter.Text(
                  'Di Level 3, Anda akan diminta pertanyaan seputar batik ini!',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: 16,
                    fontStyle: flutter.FontStyle.italic,
                  ),
                ),
                const flutter.SizedBox(height: 30),
                flutter.Row(
                  mainAxisAlignment: flutter.MainAxisAlignment.center,
                  children: [
                    // Back to Menu Button
                    flutter.ElevatedButton(
                      onPressed: onBackPressed,
                      style: flutter.ElevatedButton.styleFrom(
                        backgroundColor: flutter.Colors.orangeAccent,
                        foregroundColor: flutter.Colors.white,
                        padding: const flutter.EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 15,
                        ),
                      ),
                      child: const flutter.Text('MENU UTAMA'),
                    ),
                    const flutter.SizedBox(width: 20),
                    // Continue to Level 2 Button
                    flutter.ElevatedButton(
                      onPressed: onContinuePressed,
                      style: flutter.ElevatedButton.styleFrom(
                        backgroundColor: flutter.Colors.green,
                        foregroundColor: flutter.Colors.white,
                        padding: const flutter.EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 15,
                        ),
                      ),
                      child: const flutter.Text('LANJUT LEVEL 3'),
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
                'LevelCompleteOverlay': (context, game) => LevelCompleteOverlay(
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
    return flutter.Material(
      color: flutter.Colors.black.withOpacity(0.5),
      child: flutter.Center(
        child: flutter.Container(
          width: flutter.MediaQuery.of(context).size.width * 0.9,
          padding: const flutter.EdgeInsets.all(20),
          decoration: flutter.BoxDecoration(
            color: flutter.Colors.white,
            borderRadius: flutter.BorderRadius.circular(20),
            boxShadow: [
              flutter.BoxShadow(
                color: flutter.Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: flutter.SingleChildScrollView(
            child: flutter.Column(
              mainAxisSize: flutter.MainAxisSize.min,
              children: [
                const flutter.Text(
                  'KUIS BATIK PARANG',
                  style: flutter.TextStyle(
                    fontSize: 24,
                    fontWeight: flutter.FontWeight.bold,
                    color: flutter.Colors.deepOrange,
                  ),
                ),
                const flutter.SizedBox(height: 20),
                
                flutter.Container(
                  height: 180,
                  width: double.infinity,
                  margin: const flutter.EdgeInsets.symmetric(vertical: 10),
                  decoration: flutter.BoxDecoration(
                    borderRadius: flutter.BorderRadius.circular(10),
                    image: const flutter.DecorationImage(
                      image: flutter.AssetImage('assets/images/batik_parang.png'),
                      fit: flutter.BoxFit.contain,
                    ),
                  ),
                ),
                
                const flutter.SizedBox(height: 20),
                const flutter.Text(
                  'Jawab pertanyaan berikut tentang Batik Parang\nuntuk memulai Level 2:',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: 16,
                  ),
                ),
                const flutter.SizedBox(height: 20),
                
                const flutter.Text(
                  'Apa makna filosofi dari motif Batik Parang?',
                  textAlign: flutter.TextAlign.center,
                  style: flutter.TextStyle(
                    fontSize: 18,
                    fontWeight: flutter.FontWeight.bold,
                    color: flutter.Colors.blue,
                  ),
                ),
                const flutter.SizedBox(height: 15),
                
                flutter.TextField(
                  controller: answerController,
                  decoration: const flutter.InputDecoration(
                    border: flutter.OutlineInputBorder(),
                    labelText: 'Jawaban Anda',
                    hintText: 'Masukkan makna filosofi',
                  ),
                ),
                const flutter.SizedBox(height: 10),
                const flutter.Text(
                  'Petunjuk: Berhubungan dengan kesinambungan hidup',
                  style: flutter.TextStyle(
                    fontSize: 14,
                    fontStyle: flutter.FontStyle.italic,
                    color: flutter.Colors.grey,
                  ),
                ),
                
                const flutter.SizedBox(height: 25),
                flutter.Row(
                  mainAxisAlignment: flutter.MainAxisAlignment.center,
                  children: [
                    flutter.ElevatedButton(
                      onPressed: onBackPressed,
                      style: flutter.ElevatedButton.styleFrom(
                        backgroundColor: flutter.Colors.orangeAccent,
                        foregroundColor: flutter.Colors.white,
                      ),
                      child: const flutter.Text('KEMBALI'),
                    ),
                    const flutter.SizedBox(width: 20),
                    flutter.ElevatedButton(
                      onPressed: onContinuePressed,
                      style: flutter.ElevatedButton.styleFrom(
                        backgroundColor: flutter.Colors.green,
                        foregroundColor: flutter.Colors.white,
                      ),
                      child: const flutter.Text('MULAI LEVEL 2'),
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

  @override
  flutter.Widget build(flutter.BuildContext context) {
    final game = Level2Game();
    
    return flutter.Scaffold(
      body: flutter.Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'LevelCompleteOverlay': (flutter.BuildContext context, Level2Game game) {
                return LevelCompleteOverlay(
                  onBackPressed: () {
                    game.overlays.remove('LevelCompleteOverlay');
                    flutter.Navigator.pop(context);
                  },
                  onContinuePressed: () {
                    game.overlays.remove('LevelCompleteOverlay');
                    // Navigate to Level 3
                    // flutter.Navigator.pushReplacement(
                    //   context,
                    //   flutter.MaterialPageRoute(
                    //     builder: (context) => const Level3Screen(),
                    //   ),
                    // );
                  },
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

class Level2Game extends FlameGame with DragCallbacks, HasCollisionDetection {
  late final TiledComponent map;
  PlayerComponent? player;
  Direction playerDirection = Direction.idle;
  late final JoystickComponent joystick;
  final List<RectangleHitbox> collisionBlocks = [];
  final List<PointObject> pointObjects = [];
  int totalPoints = 0;
  int collectedPoints = 0;
  bool _levelCompleted = false;

  static const double tileSize = 64.0;
  late final Vector2 mapDimensions;
  final Vector2 playerStartPosition = Vector2(900, 210);
  final Vector2 playerSize = Vector2(64, 96);

  void collectPoint() {
    collectedPoints++;
    if (collectedPoints >= totalPoints && !_levelCompleted) {
      _levelCompleted = true;
      overlays.add('LevelCompleteOverlay');
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      map = await TiledComponent.load('level2.tmx', Vector2.all(tileSize));
      world.add(map);

      mapDimensions = Vector2(
        map.tileMap.map.width * tileSize,
        map.tileMap.map.height * tileSize,
      );

      await _extractCollisionObjects();
      await _extractPointObjects();

      final spriteSheet = SpriteSheet(
        image: await images.load('character_walk.png'),
        srcSize: Vector2(104, 150),
      );

      player = PlayerComponent(
        spriteSheet: spriteSheet,
        position: playerStartPosition,
        size: playerSize,
      );

      final playerHitbox = RectangleHitbox(
        size: Vector2(playerSize.x * 0.6, playerSize.y * 0.3),
        position: Vector2(playerSize.x * 0.2, playerSize.y * 0.7),
      );
      player!.add(playerHitbox);

      world.add(player!);

      camera.viewfinder.anchor = Anchor.center;
      if (player != null) {
        camera.follow(player!);
      }

      final knobPaint = Paint()..color = flutter.Colors.blue.withOpacity(0.8);
      final backgroundPaint = Paint()..color = flutter.Colors.blueGrey.withOpacity(0.5);

      joystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: knobPaint),
        background: CircleComponent(radius: 60, paint: backgroundPaint),
        position: Vector2(100, size.y - 100),
      );

      camera.viewport.add(joystick);
    } catch (e) {
      print('Error during loading: $e');
    }
  }

  Future<void> _extractCollisionObjects() async {
    try {
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
    } catch (e) {
      print('Error extracting collision objects: $e');
    }
  }

  Future<void> _extractPointObjects() async {
    try {
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
          pointObjects.add(pointObject);
          totalPoints++;
        }
      } else {
        print('Point layer not found in the map');
      }
    } catch (e) {
      print('Error extracting point objects: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

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

    if (player != null && joystick.direction != JoystickDirection.idle) {
      Direction moveDirection;

      if (joystick.delta.x.abs() > joystick.delta.y.abs()) {
        moveDirection = joystick.delta.x > 0 ? Direction.right : Direction.left;
      } else {
        moveDirection = joystick.delta.y > 0 ? Direction.down : Direction.up;
      }

      final previousPosition = player!.position.clone();
      double speed = 100 * dt;
      Vector2 movement = Vector2.zero();

      switch (moveDirection) {
        case Direction.up:
          movement.y = -speed;
          break;
        case Direction.down:
          movement.y = speed;
          break;
        case Direction.left:
          movement.x = -speed;
          break;
        case Direction.right:
          movement.x = speed;
          break;
        case Direction.idle:
          break;
      }

      player!.position.add(movement);

      bool hasCollision = false;
      for (final block in collisionBlocks) {
        for (final hitbox in player!.children.whereType<RectangleHitbox>()) {
          final playerGlobalPosition = player!.position + hitbox.position;
          final blockGlobalPosition = block.position;

          final playerRect = Rect.fromLTWH(
            playerGlobalPosition.x,
            playerGlobalPosition.y,
            hitbox.size.x,
            hitbox.size.y,
          );

          final blockRect = Rect.fromLTWH(
            blockGlobalPosition.x,
            blockGlobalPosition.y,
            block.size.x,
            block.size.y,
          );

          if (playerRect.overlaps(blockRect)) {
            hasCollision = true;
            break;
          }
        }

        if (hasCollision) break;
      }

      if (hasCollision) {
        player!.position = previousPosition;
      }

      player!.position.x = player!.position.x.clamp(0, mapDimensions.x - player!.size.x);
      player!.position.y = player!.position.y.clamp(0, mapDimensions.y - player!.size.y);

      player!.move(moveDirection);
    } else if (player != null) {
      player!.stop();
    }
  }
}