import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';

//import 'package:arkanoid/prova.dart';

class Life extends SpriteComponent {
  final ArkanoidGame game;
  late SpriteComponent vrSprite;
  int lifeNumber;

  /*late SpriteComponent vrSprite2;*/
  Rect vrRect = Rect.zero;

  /*Rect vrRect2 = Rect.zero;*/
  Life(this.game, this.lifeNumber) : super(
    position: Vector2(game.playScreenPosition.x+game.tileSize.x/2+game.tileSize.x/2*lifeNumber, game.playScreenPosition.y+game.playScreenSize.y-game.tileSize.y),
    size: Vector2.all(game.tileSize.y*4/5),
    sprite: Sprite(Flame.images.fromCache('components/life.png'))
  ) {




  }

  void render(Canvas canvas) {
    super.render(canvas);
  }

  void update(double t) {}
}