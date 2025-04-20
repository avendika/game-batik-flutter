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
import '../services/game_menu.dart'; // Import file menu baru
import 'level2.dart';
import 'LVCompleted/LevelCompleteOverlay.dart';

class Level1Screen extends flutter.StatefulWidget {
  const Level1Screen({super.key});

  @override
  flutter.State<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends flutter.State<Level1Screen> {
  final Level1Game _game = Level1Game();
  bool _showMenuButton = true;
  bool _isPaused = false;
  late GameMenu _gameMenu; // Tambahkan instance GameMenu

  @override
  void initState() {
    super.initState();
    _game.onLevelCompleted = () {
      setState(() {
        _showMenuButton = false;
      });
    };
    
    // Initialize GameMenu
    _gameMenu = GameMenu(
      context: context,
      settings: _game.settings,
      onResume: () {
        _game.paused = false;
        setState(() {
          _isPaused = false;
        });
      },
      onRestart: () {
        // Restart the level by replacing it with a new instance
        flutter.Navigator.pushReplacement(
          context,
          flutter.MaterialPageRoute(
            builder: (context) => const Level1Screen(),
          ),
        );
      },
      onExit: () {
        _game.settings.handleScreenTransition('lobby');
        flutter.Navigator.pop(context); // Return to main menu
      },
    );
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      body: flutter.Stack(
        children: [
          GameWidget<Level1Game>(
            game: _game,
            overlayBuilderMap: {
              'LevelCompleteOverlay': (context, game) => LevelCompleteOverlay(
                    onBackPressed: () {
                      game.overlays.remove('LevelCompleteOverlay');
                      game.settings.handleScreenTransition('lobby');
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
                    levelNumber: '1',
                    batikImagePath: 'assets/images/batik_parang.png',
                    batikDescription:
                        'Batik Parang adalah salah satu motif batik tertua di Indonesia. '
                        'Bentuknya seperti huruf "S" yang saling berkaitan, melambangkan '
                        'kesinambungan dan kesinambungan hidup. Motif ini berasal dari '
                        'Jawa dan memiliki makna filosofis yang dalam.',
                  ),
              'PointsDisplay': (context, game) => flutter.Positioned(
                    top: 20,
                    right: 20,
                    child: PointsDisplay(
                      collected: game.collectedPoints,
                      total: game.totalPoints,
                    ),
                  ),
              'AlertMessage': (context, game) => flutter.Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: flutter.Center(
                      child: AlertNotification(
                        message: '! Carilah puzzle tersembunyi untuk menyelesaikan level ini',
                      ),
                    ),
                  ),
            },
          ),
          if (_showMenuButton) 
            _gameMenu.buildMenuButton(() {
              // Pause the game
              _game.paused = true;
              setState(() {
                _isPaused = true;
              });
              
              // Play button click sound
              _game.settings.playSfx('button_click.mp3');
              
              // Show the menu dialog
              _gameMenu.showMenuDialog();
            }),
          if (_isPaused)
            flutter.Positioned.fill(
              child: flutter.Container(
                color: flutter.Colors.black.withOpacity(0.3),
                child: flutter.Center(
                  child: flutter.Text(
                    'PAUSE',
                    style: flutter.TextStyle(
                      color: flutter.Colors.white,
                      fontSize: 40,
                      fontWeight: flutter.FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Kelas Level1Game tidak perlu diubah
class Level1Game extends FlameGame
    with DragCallbacks, HasCollisionDetection
    implements PointCollector {
  late final TiledComponent map;
  PlayerComponent? player;
  late final JoystickComponent joystick;
  final List<RectangleHitbox> collisionBlocks = [];
  int totalPoints = 0;
  int collectedPoints = 0;
  bool _levelCompleted = false;
  bool _paused = false;

  final GameSettings settings = GameSettings();

  static const double tileSize = 64.0;
  late final Vector2 mapDimensions;
  final Vector2 playerStartPosition = Vector2(900, 210);
  final Vector2 playerSize = Vector2(64, 96);

  /// Notifikasi untuk level selesai
  void Function()? onLevelCompleted;

  // Getter and setter for paused state
  bool get paused => _paused;
  set paused(bool value) {
    _paused = value;
    if (_paused) {
      settings.stopBackgroundMusic(); // Pause music when game is paused
    } else {
      settings.resumeBackgroundMusic(); // Resume music when game is unpaused
    }
  }

  void collectPoint() {
    collectedPoints++;
    settings.playSfx('claim.mp3');
    overlays.remove('PointsDisplay');
    overlays.add('PointsDisplay');

    if (collectedPoints >= totalPoints && !_levelCompleted) {
      _levelCompleted = true;
      settings.playSfx('level_complete.mp3');
      overlays.add('LevelCompleteOverlay');
      onLevelCompleted?.call(); // Panggil callback saat level selesai
    }
  }

  @override
  void onRemove() {
    settings.stopBackgroundMusic();
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Ensure settings are initialized
      await settings.ensureInitialized();
      
      settings.stopBackgroundMusic();
      settings.playBackgroundMusic('background_music.mp3');

      await _loadMap();
      await _extractCollisionObjects();
      await _extractPointObjects();
      await _createPlayer();
      _setupCamera();
      _setupJoystick();

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
    // Only show joystick if enabled in settings
    if (settings.showJoystick) {
      final knobPaint = Paint()..color = flutter.Colors.blue.withOpacity(0.8);
      final backgroundPaint = Paint()..color = flutter.Colors.blueGrey.withOpacity(0.5);

      joystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: knobPaint),
        background: CircleComponent(radius: 60, paint: backgroundPaint),
        position: Vector2(100, size.y - 100),
      );

      camera.viewport.add(joystick);
    }
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
        final spriteName = obj.name;

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
    if (_paused) return; // Skip updates when paused
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
    if (player != null && settings.showJoystick) {
      player!.updateMovement(dt, joystick.direction, joystick.delta);
    }
  }
}