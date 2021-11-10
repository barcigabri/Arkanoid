import 'dart:ui';

import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Logo extends TextComponent {
  final ArkanoidGame game;


  Logo(this.game) : super (
      "arkanoid",
      position: Vector2(game.screen.x/2,game.screen.y/3),
      //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
      textRenderer: game.getPainter(70),
  ) {
    anchor = Anchor.center;
  }


  @override
  void render(Canvas canvas) {

    super.render(canvas);
  }

  void update(double t) {
    super.update(t);
  }
}
