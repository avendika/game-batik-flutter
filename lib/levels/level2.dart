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
import '../services/game_menu.dart';
import '../services/user_service.dart'; // Import UserService
import 'level3.dart';
import 'LVCompleted/LevelCompleteOverlay.dart' as lvCompleted;
import '../screens/batik_question_overlay.dart';  


class Level2Screen extends flutter.StatefulWidget {
  const Level2Screen({super.key});

  @override
  flutter.State<Level2Screen> createState() => _Level2ScreenState();
}

class _Level2ScreenState extends flutter.State<Level2Screen> {
  final Level2Game _game = Level2Game();
  late final flutter.TextEditingController _answerController;
  bool _showMenuButton = true;
  bool _isPaused = false;
  bool _showQuestion = true;
  late GameMenu _gameMenu;
  // Add UserService instance
  final UserService _userService = UserService();

  @override
  void initState() {
    _showMenuButton = false; 
    super.initState();
    _answerController = flutter.TextEditingController();
    _game.onLevelCompleted = () {
      setState(() {
        _showMenuButton = false;
      });

        // Update user score when level is completed
      if (_userService.isLoggedIn && _game.collectedPoints > 0) {
        final currentScore = _userService.currentUser?.score ?? 0;
        final newScore = currentScore + _game.collectedPoints;
        _userService.updateProgress(newScore: newScore);
      }
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
            builder: (context) => const Level2Screen(),
          ),
        );
      },
      onExit: () {
          // Update score before exiting if points were collected
        if (_userService.isLoggedIn && _game.collectedPoints > 0) {
          final currentScore = _userService.currentUser?.score ?? 0;
          final newScore = currentScore + _game.collectedPoints;
          _userService.updateProgress(newScore: newScore);
        }

        _game.settings.handleScreenTransition('lobby');
        flutter.Navigator.pop(context); // Return to main menu
      },
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _showMenuButton = true;
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
              game: _game,
              overlayBuilderMap: {
                'Level2CompleteOverlay': (flutter.BuildContext context, Level2Game game) {
                  return lvCompleted.LevelCompleteOverlay(
                    levelNumber: '2',
                    batikImagePath: 'assets/batik_level/batik_mega_mendung.png',
                    batikDescription: 'Motif Mega Mendung berasal dari Cirebon dan menggambarkan awan pembawa hujan. '
                                    'Batik ini memiliki makna kesabaran dan tidak mudah marah. Warna dominannya '
                                    'biru dengan gradasi yang indah, melambangkan langit yang luas.',
                    onBackPressed: () {
                      game.overlays.remove('Level2CompleteOverlay');
                      flutter.Navigator.pop(context);
                    },
                    onContinuePressed: () {
                      game.overlays.remove('Level2CompleteOverlay');
                      flutter.Navigator.pushReplacement(
                        context,
                        flutter.MaterialPageRoute(
                          builder: (context) => const Level3Screen(),
                        ),
                      );
                    },
                  );
                },
                'PointsDisplay': (flutter.BuildContext context, Level2Game game) {
                  return flutter.Positioned(
                    top: 20,
                    right: 20,
                    child: PointsDisplay(
                      collected: game.collectedPoints,
                      total: game.totalPoints,
                    ),
                  );
                },
                'AlertMessage': (flutter.BuildContext context, Level2Game game) {
                  return flutter.Positioned(
                    top: 50,
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
              levelNumber: '2',
              batikImagePath: 'assets/batik_level/batik_parang.png',
              quizQuestion: 'Apa makna filosofi dari motif Batik Parang?',
              quizHint: 'Berhubungan dengan kesinambungan hidup',
            ),
          
          if (_showMenuButton) 
            _gameMenu.buildMenuButton(() {
              _game.settings.stopBackgroundMusic();
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

class Level2Game extends FlameGame with DragCallbacks, HasCollisionDetection implements PointCollector {
  late final TiledComponent map;
  PlayerComponent? player;
  late final JoystickComponent joystick;
  final List<RectangleHitbox> collisionBlocks = [];
  int totalPoints = 0;
  int collectedPoints = 0;
  bool _levelCompleted = false;
  // Add UserService instance
  final UserService userService = UserService();

  final GameSettings settings = GameSettings();

  static const double tileSize = 64.0;
  late final Vector2 mapDimensions;
  final Vector2 playerStartPosition = Vector2(1350, 250);
  final Vector2 playerSize = Vector2(64, 96);

    /// Notifikasi untuk level selesai
  void Function()? onLevelCompleted;

  void collectPoint() {
    collectedPoints++;
    settings.playSfx('claim.mp3');
    overlays.remove('PointsDisplay');
    overlays.add('PointsDisplay');

    // Update user score in real-time whenever a point is collected
    if (userService.isLoggedIn) {
      final currentScore = userService.currentUser?.score ?? 0;
      final newScore = currentScore + 20; // Add 1 point to score
      userService.updateProgress(newScore: newScore);
    }

    if (collectedPoints >= totalPoints && !_levelCompleted) {
      _levelCompleted = true;
      settings.playSfx('level_complete.mp3');
      overlays.add('Level2CompleteOverlay');
      onLevelCompleted?.call(); // Panggil callback saat level selesai
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