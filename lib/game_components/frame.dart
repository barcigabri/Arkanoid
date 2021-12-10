import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

// it will be deleted when I add the controller, or I'll keep it if I leave the chance to tap
class Frame extends SpriteComponent{
  final ArkanoidGame game;

  Frame(this.game) : super (
    position: game.playScreenPosition,
    size: game.playScreenSize,
    sprite: Sprite(Flame.images.fromCache('background/frame.png')),
    priority: 2
  ) {
    size.add(Vector2(game.playScreenSize.x/14, game.bottomHole.size.y));
    size.add(Vector2(0, size.y/30));
    position.sub(Vector2((size.x - game.playScreenSize.x)/2, size.y / 30));
  }


  void render(Canvas canvas) {
    super.render(canvas);
  }

  void update(double t) {
    super.update(t);
  }
}