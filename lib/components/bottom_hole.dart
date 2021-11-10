import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class BottomHole extends SpriteComponent with Hitbox, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  Rect bgRectDown = Rect.zero;
  //Paint boxPaint = Paint()..color = Color(0xFFFF0000);
  BottomHole(this.game)  : super (
      position: Vector2(game.screen.x/6, (game.screen.y-game.playScreenSize.y)/2+game.playScreenSize.y),
      size: Vector2(game.screen.x*2/3, game.screen.y - (game.playScreenPosition.y+game.playScreenSize.y)),
      sprite: Sprite(Flame.images.fromCache('background/spike.png')/*,srcPosition: Vector2(0,0), srcSize: Vector2(20,20)*/)
  ) {

    collidableType = CollidableType.passive;
    addHitbox(HitboxRectangle());
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));

    bgRectDown = Rect.fromLTWH(
      game.screen.x/6,
      game.screen.y-game.screen.y/20,
      game.screen.x*2/3,
      game.screen.y/20,
    );
    // print('bottom: $bgRectDown');

  }

  void render(Canvas canvas) {
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine

    //debugColor = Colors.red;
    super.render(canvas);
    renderHitboxes(canvas);
    //canvas.drawRect(bgRectDown, boxPaint);


  }

  void update(double t) {}
}