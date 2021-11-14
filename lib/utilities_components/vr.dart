import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';

class Vr {
  final ArkanoidGame game;
  late SpriteComponent vrSprite;
  int side;

  /*late SpriteComponent vrSprite2;*/
  Rect vrRect = Rect.zero;

  /*Rect vrRect2 = Rect.zero;*/
  Vr(this.game,this.side) {
    vrSprite = SpriteComponent.fromImage(
        Flame.images.fromCache('vr/cardboardview.png'));
    /*vrSprite2 = SpriteComponent.fromImage(Flame.images.fromCache('vr/cardboardview.png'));*/

    vrRect = Rect.fromLTWH(
      0,
      0,
      game.screen.x,
      game.screen.y,
    );
    /*vrRect2 = Rect.fromLTWH(
      game.screenSize.x/2,
      0,
      game.screenSize.x/2,
      game.screenSize.y,
    );*/
    vrSprite.setByRect(vrRect);
    /*vrSprite2.setByRect(vrRect2);*/
    if (side == 2) {
      vrSprite.flipHorizontallyAroundCenter();
    }

  }

  void render(Canvas canvas) {
    canvas.save();
    vrSprite.render(canvas);
    canvas.restore();
  }

  void update(double t) {}
}