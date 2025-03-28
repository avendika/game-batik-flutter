// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame/game.dart';
// import 'package:flame_tiled/flame_tiled.dart';
// import 'package:flutter/material.dart' as flutter;
// import 'package:flame/sprite.dart';
// import 'package:flame/collisions.dart'; 
// import 'package:flame/effects.dart';
// import 'dart:ui'; 
// import '../models/direction.dart';
// import '../player/player_component.dart';

// // A component to represent point objects from the map
// class PointObject extends SpriteComponent with HasGameRef, CollisionCallbacks {
//   PointObject({
//     required Vector2 position,
//     required Vector2 size,
//   }) : super(
//     position: position,
//     size: size,
//     anchor: Anchor.center,
//   );
  
//   @override
//   Future<void> onLoad() async {
//     // Load the sprite for the point
//     sprite = Sprite(await game.images.load('point_image.png'));
    
//     // Add a hitbox for collision detection
//     add(
//       RectangleHitbox(
//         size: size,
//         position: Vector2.zero(),
//         anchor: Anchor.center,
//       ),
//     );
    
//     // Add a small pulsing animation to make the point more visible
//     add(
//       ScaleEffect.by(
//         Vector2.all(1.2),
//         EffectController(
//           duration: 0.5,
//           reverseDuration: 0.5,
//           infinite: true,
//           alternate: true,
//         ),
//       ),
//     );
//   }
  
//   // Optional: Handle collision with player
//   @override
//   void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollisionStart(intersectionPoints, other);
    
//     if (other is PlayerComponent) {
//       // You can handle point collection here
//       // For example, make the point disappear, increase score, etc.
//       print('Player collected a point!');
//       removeFromParent(); // Remove the point from the game
//     }
//   }
// }

// class Level1Screen extends flutter.StatelessWidget {
//   const Level1Screen({super.key});

//   @override
//   flutter.Widget build(flutter.BuildContext context) {
//     final game = Level1Game();
//     return flutter.Scaffold(
//       body: flutter.Stack(
//         children: [
//           GameWidget(game: game),
//           flutter.Positioned(
//             top: 20,
//             left: 20,
//             child: flutter.ElevatedButton(
//               onPressed: () {
//                 flutter.Navigator.pop(context);
//               },
//               style: flutter.ElevatedButton.styleFrom(
//                 backgroundColor: flutter.Colors.orangeAccent,
//                 foregroundColor: flutter.Colors.white,
//               ),
//               child: const flutter.Text('Kembali'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Level1Game extends FlameGame with DragCallbacks, HasCollisionDetection {
  
//   late final TiledComponent map;
//   PlayerComponent? player;
//   Direction playerDirection = Direction.idle;
//   late final JoystickComponent joystick;
  
//   // List to store collision rectangles
//   final List<RectangleHitbox> collisionBlocks = [];
  
//   // List to store point objects
//   final List<PointObject> pointObjects = [];
  
//   // Constants for the tile size
//   static const double tileSize = 64.0;
  
//   // Map dimensions (akan diinisialisasi saat peta dimuat)
//   late final Vector2 mapDimensions;
  
//   // Player starting position - easily modifiable
//   final Vector2 playerStartPosition = Vector2(900, 210);
//   final Vector2 playerSize = Vector2(64, 96);
  
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
    
//     try {
//       // Load map
//       map = await TiledComponent.load('level1.tmx', Vector2.all(tileSize));
//       world.add(map);
      
//       // Menghitung dimensi peta berdasarkan ukuran tile dan jumlah tile
//       mapDimensions = Vector2(
//         map.tileMap.map.width * tileSize,
//         map.tileMap.map.height * tileSize
//       );
      
//       // Extract collision objects from the TMX file
//       await _extractCollisionObjects();
      
//       // Extract and add point objects from the map
//       await _extractPointObjects();
      
//       // Load player sprite
//       final spriteSheet = SpriteSheet(
//         image: await images.load('character_walk.png'),
//         srcSize: Vector2(104, 150),
//       );
      
//       // Create player at specified starting position
//       player = PlayerComponent(
//         spriteSheet: spriteSheet,
//         position: playerStartPosition,
//         size: playerSize
//       );
      
//       // Add collision hitbox to the player
//       final playerHitbox = RectangleHitbox(
//         size: Vector2(playerSize.x * 0.6, playerSize.y * 0.3),
//         position: Vector2(playerSize.x * 0.2, playerSize.y * 0.7),
//       );
//       player!.add(playerHitbox);
      
//       world.add(player!);
      
//       // Set up camera
//       camera.viewfinder.anchor = Anchor.center;
      
//       // Position the camera to follow the player
//       if (player != null) {
//         camera.follow(player!);
//       }
      
//       // Add joystick for movement
//       final knobPaint = flutter.Paint()..color = flutter.Colors.blue.withOpacity(0.8);
//       final backgroundPaint = flutter.Paint()..color = flutter.Colors.blueGrey.withOpacity(0.5);
      
//       joystick = JoystickComponent(
//         knob: CircleComponent(radius: 20, paint: knobPaint),
//         background: CircleComponent(radius: 60, paint: backgroundPaint),
//         position: Vector2(100, size.y - 100),
//       );
      
//       camera.viewport.add(joystick);
      
//     } catch (e) {
//       print('Error during loading: $e');
//     }
//   }
  
//   // Extract collision objects from the TMX file
//   Future<void> _extractCollisionObjects() async {
//     try {
//       // Get the collision object layer
//       final collisionLayer = map.tileMap.getLayer<ObjectGroup>('Collision');
      
//       if (collisionLayer != null) {
//         // Scale factor to convert from TMX coordinates to game coordinates
//         final scaleFactor = tileSize / map.tileMap.map.tileWidth;
        
//         // Iterate through all objects in the collision layer
//         for (final obj in collisionLayer.objects) {
//           // Create a collision rectangle based on the object's properties
//           final position = Vector2(obj.x, obj.y) * scaleFactor;
//           final size = Vector2(obj.width, obj.height) * scaleFactor;
          
//           // Create and add the collision block
//           final collisionBlock = RectangleHitbox(
//             position: position,
//             size: size,
//           );
          
//           // Add the collision block to the game world
//           world.add(
//             PositionComponent(
//               position: Vector2.zero(),
//               size: Vector2.zero(),
//               children: [collisionBlock],
//             ),
//           );
          
//           // Also keep track of the blocks in our list
//           collisionBlocks.add(collisionBlock);
//         }
//       }
//     } catch (e) {
//       print('Error extracting collision objects: $e');
//     }
//   }

//   // Extract and add point objects from the map
//   Future<void> _extractPointObjects() async {
//     try {
//       // Get the Point object layer
//       final pointLayer = map.tileMap.getLayer<ObjectGroup>('Point');
      
//       if (pointLayer != null) {
//         // Scale factor to convert from TMX coordinates to game coordinates
//         final scaleFactor = tileSize / map.tileMap.map.tileWidth;
        
//         // Iterate through all point objects in the layer
//         for (final obj in pointLayer.objects) {
//           // Calculate position and size in game coordinates
//           final position = Vector2(obj.x, obj.y) * scaleFactor;
//           final size = Vector2(obj.width, obj.height) * scaleFactor;
          
//           // Create the point object
//           final pointObject = PointObject(
//             position: position,
//             size: size,
//           );
          
//           // Add the point object to the game world
//           world.add(pointObject);
          
//           // Keep track of the point objects in our list
//           pointObjects.add(pointObject);
          
//           print('Added point object at position: $position');
//         }
//       } else {
//         print('Point layer not found in the map');
//       }
//     } catch (e) {
//       print('Error extracting point objects: $e');
//     }
//   }
  
//   @override
//   void update(double dt) {
//     super.update(dt);
    
//     // Batasi kamera agar tidak keluar dari batas map
//     if (player != null) {
//       // Hitung batas kamera
//       final halfWidth = camera.viewport.size.x / 2;
//       final halfHeight = camera.viewport.size.y / 2;
      
//       // Posisi kamera minimal (pojok kiri atas)
//       final minCameraX = halfWidth;
//       final minCameraY = halfHeight;
      
//       // Posisi kamera maksimal (pojok kanan bawah)
//       final maxCameraX = mapDimensions.x - halfWidth;
//       final maxCameraY = mapDimensions.y - halfHeight;
      
//       // Batasi posisi kamera
//       Vector2 targetPosition = player!.position.clone();
      
//       if (mapDimensions.x > camera.viewport.size.x) {
//         targetPosition.x = targetPosition.x.clamp(minCameraX, maxCameraX);
//       } else {
//         targetPosition.x = mapDimensions.x / 2;
//       }
      
//       if (mapDimensions.y > camera.viewport.size.y) {
//         targetPosition.y = targetPosition.y.clamp(minCameraY, maxCameraY);
//       } else {
//         targetPosition.y = mapDimensions.y / 2;
//       }
      
//       // Atur posisi kamera secara manual
//       camera.moveTo(targetPosition);
//     }
    
//     // Move player based on joystick input
//     if (player != null && joystick.direction != JoystickDirection.idle) {
//       // Calculate movement direction
//       Direction moveDirection;
      
//       if (joystick.delta.x.abs() > joystick.delta.y.abs()) {
//         moveDirection = joystick.delta.x > 0 ? Direction.right : Direction.left;
//       } else {
//         moveDirection = joystick.delta.y > 0 ? Direction.down : Direction.up;
//       }
      
//       // Store the player's current position before moving
//       final previousPosition = player!.position.clone();
      
//       // Move player
//       double speed = 100 * dt; // Kecepatan yang lebih konsisten dengan dt
//       Vector2 movement = Vector2.zero();
      
//       switch (moveDirection) {
//         case Direction.up:
//           movement.y = -speed;
//           break;
//         case Direction.down:
//           movement.y = speed;
//           break;
//         case Direction.left:
//           movement.x = -speed;
//           break;
//         case Direction.right:
//           movement.x = speed;
//           break;
//         case Direction.idle:
//           break;
//       }
      
//       // Update player position and animation
//       player!.position.add(movement);
      
//       // Check for collision with any collision block
//       bool hasCollision = false;
//       for (final block in collisionBlocks) {
//         for (final hitbox in player!.children.whereType<RectangleHitbox>()) {
//           // Get the global positions for comparison
//           final playerGlobalPosition = player!.position + hitbox.position;
//           final blockGlobalPosition = block.position;
          
//           // Create rectangles for collision check
//           final playerRect = Rect.fromLTWH(
//             playerGlobalPosition.x,
//             playerGlobalPosition.y,
//             hitbox.size.x,
//             hitbox.size.y,
//           );
          
//           final blockRect = Rect.fromLTWH(
//             blockGlobalPosition.x,
//             blockGlobalPosition.y,
//             block.size.x,
//             block.size.y,
//           );
          
//           // Check for intersection
//           if (playerRect.overlaps(blockRect)) {
//             hasCollision = true;
//             break;
//           }
//         }
        
//         if (hasCollision) break;
//       }
      
//       // If collision occurred, revert to previous position
//       if (hasCollision) {
//         player!.position = previousPosition;
//       }
      
//       // Batasi pergerakan player agar tidak keluar dari map
//       player!.position.x = player!.position.x.clamp(0, mapDimensions.x - player!.size.x);
//       player!.position.y = player!.position.y.clamp(0, mapDimensions.y - player!.size.y);
      
//       player!.move(moveDirection);
      
//     } else if (player != null) {
//       player!.stop();
//     }
//   }
// }