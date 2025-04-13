import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import '../player/player_component.dart';
import '../services/game_setting.dart';
import 'point_collector.dart';

class PointObject extends SpriteComponent with HasGameRef, CollisionCallbacks {
  final String spriteName;
  final GameSettings settings = GameSettings();

  PointObject({
    required this.spriteName,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await game.images.load('points/$spriteName.png'));

    final hitboxSize = size * 0.6;
    final hitboxOffset = (size - hitboxSize) / 2;

    add(RectangleHitbox(
      size: hitboxSize,
      position: hitboxOffset,
      anchor: Anchor.topLeft,
    ));

    add(ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(
        duration: 0.5,
        reverseDuration: 0.5,
        infinite: true,
        alternate: true,
      ),
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && !isRemoved) {
      try {
        // Let the game handle the sound now
        if (game is PointCollector) {
          (game as PointCollector).collectPoint();
        }
        
        removeFromParent();
      } catch (e) {
        print('Error during point collection: $e');
      }
    }
  }
}