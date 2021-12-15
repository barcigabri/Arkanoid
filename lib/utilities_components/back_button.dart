import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class ReturnButton extends SpriteComponent with Tappable {
  final ArkanoidGame game;

  ReturnButton(this.game):super(
      sprite: Sprite(Flame.images.fromCache('ui/back.png')),
      position: game.playScreenPosition,
      size: Vector2.all(game.tileSize.x * 2),
      anchor: Anchor.topLeft,
      priority: 7
  );

  @override
  bool onTapDown(TapDownInfo info) {
    size = Vector2.all(game.tileSize.x * 2.5);
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    size = Vector2.all(game.tileSize.x * 2);
    game.removeEyeSelection();
    game.startHome();
    return true;
  }

  @override
  bool onTapCancel() {
    size = Vector2.all(game.tileSize.x * 2);
    return true;
  }

  void keyboardAction(RawKeyEvent event) {

    if(event.logicalKey == LogicalKeyboardKey.gameButtonB || event.logicalKey == LogicalKeyboardKey.gameButtonX) {
      if(event is RawKeyDownEvent) {
        size = Vector2.all(game.tileSize.x * 2.5);
      }
      if(event is RawKeyUpEvent) {
        size = Vector2.all(game.tileSize.x * 2);
        game.removeEyeSelection();
        game.startHome();
      }

    }
  }
}