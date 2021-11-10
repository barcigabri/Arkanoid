import 'dart:ui';
import 'package:arkanoid/game_components/ball.dart';
import 'package:flame/components.dart';
import 'package:flame/components.dart' as comp;
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

// it will be deleted when I add the controller, or I'll keep it if I leave the chance to tap
class GestureInvisibleScreen extends PositionComponent with Tappable, comp.Draggable {
  final ArkanoidGame game;

  GestureInvisibleScreen(this.game) : super (
      position: Vector2.zero(),
      size: game.size,
  );

  @override
  bool onTapUp(TapUpInfo info) {
    game.balls.first.onTapUp(info);
    return true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    game.paddle.xPaddle = info.eventPosition.game.x;
    return true;
  }

  void render(Canvas canvas) {
   super.render(canvas);
  }

  void update(double t) {
    super.update(t);
  }
}