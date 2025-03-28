import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import '../../models/direction.dart';

class PlayerComponent extends SpriteAnimationComponent with CollisionCallbacks {
  final Map animations = {};
  final Map idleAnimations = {};
  Vector2 velocity = Vector2.zero();
  final double moveSpeed = 100.0;
  Direction currentDirection = Direction.down;

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
    
    // Default to down idle animation
    animation = idleAnimations[Direction.down];
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
    // The position update is handled in the game class
    // to properly handle collision detection
  }
}