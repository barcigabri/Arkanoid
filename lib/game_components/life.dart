import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';

class Life extends SpriteComponent {
  final ArkanoidGame game;
  late SpriteComponent vrSprite;
  int lifeNumber;

  /*late SpriteComponent vrSprite2;*/
  Rect vrRect = Rect.zero;

  /*Rect vrRect2 = Rect.zero;*/
  Life(this.game, this.lifeNumber) : super(
    position: Vector2(game.playScreenPosition.x+game.tileSize.x/2+game.tileSize.x/2*lifeNumber, game.playScreenPosition.y+game.playScreenSize.y-game.tileSize.y),
    size: Vector2.all(game.tileSize.y*5/6),
    sprite: Sprite(Flame.images.fromCache('components/life.png')),
    priority: 10
  ) {




  }

  void render(Canvas canvas) {
    super.render(canvas);
  }

  void update(double t) {}
}