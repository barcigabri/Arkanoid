import 'dart:ui';
import 'package:arkanoid/view.dart';
import 'package:flame/components.dart';
import 'package:flame/components.dart' as comp;
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

// it will be deleted when I add the controller, or I'll keep it if I leave the chance to tap
class GestureInvisibleScreen extends PositionComponent with Tappable, comp.Draggable {
  final ArkanoidGame game;

  GestureInvisibleScreen(this.game) : super (
      position: Vector2(game.playScreenPosition.x, 0),
      size: game.size - Vector2(game.playScreenPosition.x, 0),
  );

  @override
  bool onTapUp(TapUpInfo info) {
    if(game.activeView != View.pause) {
      game.balls.first.onTapUp(info);
    }
    return true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if(game.activeView != View.pause) {
      game.paddle.xPaddle = info.eventPosition.game.x;
      if (game.paddle.xPaddle >
          game.screen.x - game.screen.x / 6 - game.paddle.size.x / 2) {
        game.paddle.xPaddle =
            game.screen.x - game.screen.x / 6 - game.paddle.size.x / 2;
      }
      if (game.paddle.xPaddle < game.screen.x / 6 + game.paddle.size.x / 2) {
        game.paddle.xPaddle = game.screen.x / 6 + game.paddle.size.x / 2;
      }
    }

    return true;
  }

  void render(Canvas canvas) {
   super.render(canvas);
  }

  void update(double t) {
    super.update(t);
  }
}