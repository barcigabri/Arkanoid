import 'dart:ui';

import 'package:arkanoid/components/vr.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

const circlesInfo = '''
This example will create a circle every time you tap on the screen. It will have
the initial velocity towards the center of the screen and if it touches another
circle both of them will change color.
''';

class MyCollidable extends PositionComponent
    with HasGameRef<ArkanoidGame>, Hitbox, Collidable {
  late Vector2 velocity;
  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  bool _isWallHit = false;
  bool _isCollision = false;

  MyCollidable(Vector2 position)
      : super(
    position: position,
    size: Vector2.all(50),
    anchor: Anchor.center,
  ) {
    addHitbox(HitboxCircle());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final center = gameRef.size / 2;
    velocity = (center - position)..scaleTo(150);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isWallHit) {
      removeFromParent();
      return;
    }
    debugColor = _isCollision ? _collisionColor : _defaultColor;
    position.add(velocity * dt);
    _isCollision = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderHitboxes(canvas);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is ScreenCollidable) {
      _isWallHit = true;
      return;
    }
    _isCollision = true;
  }
}

class ArkanoidGame extends FlameGame with HasCollidables, TapDetector {
  late Vr vrLeft, vrRight;
  //late FixedResolutionViewport view1;
  late Vector2 screenSize;
  late Vector2 screen = Vector2.all(200);
/*
  @override
  void onGameResize(Vector2 gameSize) {
    screenSize = gameSize;
    print(screenSize.x);
*//*    view1 = FixedResolutionViewport(Vector2(screenSize.x/2,screenSize.y));
    camera.viewport = view1;
    screen=camera.viewport.effectiveSize;*//*
    screen=screenSize;
    //vrLeft = Vr(this,1);
    //vrRight = Vr(this,2);

  }*/

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(ScreenCollidable());
    add(MyCollidable(Vector2(60,60)));
  }

  /*ArkanoidGame(){


  }*/

  @override
  void onTapDown(TapDownInfo info) {
    add(MyCollidable(info.eventPosition.game));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(Offset(0,0), Offset(screen.x,screen.y), Paint()..color = Color(0xFFFF9800));

  }

}