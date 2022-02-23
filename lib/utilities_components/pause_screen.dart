import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class PauseScreen extends SpriteComponent {
  final ArkanoidGame game;


  PauseScreen(this.game) : super (
      position: Vector2.zero(),
      size: game.screen,
      sprite: Sprite(Flame.images.fromCache('background/penalization.png')),
      paint: Paint()..color = Colors.white.withOpacity(0.5),
      priority: 11
  ) {


    TextComponent textBox = TextComponent(
      text: "PAUSE",
      textRenderer: game.getPainter(40), position: Vector2(game.screen.x/2,game.screen.y/3),
      /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
      ),*/
      anchor: Anchor.center,
    );
    add(textBox);

  }





}