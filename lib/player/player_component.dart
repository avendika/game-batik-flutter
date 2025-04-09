import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'dart:ui';
import '../models/direction.dart';

class PlayerComponent extends SpriteAnimationComponent with CollisionCallbacks {
  final Map<Direction, SpriteAnimation> animations = {};
  final Map<Direction, SpriteAnimation> idleAnimations = {};
  Vector2 velocity = Vector2.zero();
  final double moveSpeed = 100.0;
  Direction currentDirection = Direction.down;
  List<RectangleHitbox> collisionBlocks = [];
  Vector2 mapDimensions = Vector2.zero();

  PlayerComponent({
    required SpriteSheet spriteSheet,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    // Create animations for each direction
    animations[Direction.up] = spriteSheet.createAnimation(row: 1, stepTime: 0.1, to: 4);
    animations[Direction.down] = spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 4);
    animations[Direction.left] = spriteSheet.createAnimation(row: 2, stepTime: 0.1, to: 4);
    animations[Direction.right] = spriteSheet.createAnimation(row: 3, stepTime: 0.1, to: 4);
    
    // Create idle animations for each direction
    idleAnimations[Direction.up] = spriteSheet.createAnimation(row: 1, stepTime: 0.1, to: 1);
    idleAnimations[Direction.down] = spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 1);
    idleAnimations[Direction.left] = spriteSheet.createAnimation(row: 2, stepTime: 0.1, to: 1);
    idleAnimations[Direction.right] = spriteSheet.createAnimation(row: 3, stepTime: 0.1, to: 1);
    
    // Default to down idle animation1
    animation = idleAnimations[Direction.down];
    
    // Add player hitbox
    final playerHitbox = RectangleHitbox(
      size: Vector2(size.x * 0.6, size.y * 0.3),
      position: Vector2(size.x * 0.2, size.y * 0.7),
    );
    add(playerHitbox);
  }

  void setCollisionBlocks(List<RectangleHitbox> blocks) {
    collisionBlocks = blocks;
  }
  
  void setMapDimensions(Vector2 dimensions) {
    mapDimensions = dimensions;
  }

  void move(Direction direction) {
    // Store the current direction
    currentDirection = direction;
    
    // Set the animation based on direction
    animation = animations[direction];
    
    switch (direction) {
      case Direction.up:
        velocity.y = -moveSpeed;
        velocity.x = 0;
        break;
      case Direction.down:
        velocity.y = moveSpeed;
        velocity.x = 0;
        break;
      case Direction.left:
        velocity.x = -moveSpeed;
        velocity.y = 0;
        break;
      case Direction.right:
        velocity.x = moveSpeed;
        velocity.y = 0;
        break;
      default:
        velocity = Vector2.zero();
        break;
    }
  }
  
  void updateMovement(double dt, JoystickDirection joystickDirection, Vector2 joystickDelta) {
    // Determine movement direction based on joystick input
    if (joystickDirection != JoystickDirection.idle) {
      Direction moveDirection;
      if (joystickDelta.x.abs() > joystickDelta.y.abs()) {
        moveDirection = joystickDelta.x > 0 ? Direction.right : Direction.left;
      } else {
        moveDirection = joystickDelta.y > 0 ? Direction.down : Direction.up;
      }

      // Store previous position for collision detection
      final previousPosition = position.clone();
      double speed = 500 * dt;
      Vector2 movement = Vector2.zero();

      // Apply movement based on direction
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

      position.add(movement);

      // Check collisions
      if (_checkCollision()) {
        position = previousPosition;
      }

      // Keep player within map bounds
      if (mapDimensions != Vector2.zero()) {
        position.x = position.x.clamp(0, mapDimensions.x - size.x);
        position.y = position.y.clamp(0, mapDimensions.y - size.y);
      }

      move(moveDirection);
    } else {
      stop();
    }
  }

  bool _checkCollision() {
    for (final block in collisionBlocks) {
      for (final hitbox in children.whereType<RectangleHitbox>()) {
        final playerGlobalPosition = position + hitbox.position;
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
          return true;
        }
      }
    }
    return false;
  }

  void stop() {
    velocity = Vector2.zero();
    resetToIdle();
  }

  void resetToIdle() {
    if (velocity.isZero()) {
      animation = idleAnimations[currentDirection];
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Movement is now handled by updateMovement method when called from game class
  }
}