import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class ResumeButton extends SpriteComponent with Tappable {
  final ArkanoidGame game;

  ResumeButton(this.game):super(
      sprite: Sprite(Flame.images.fromCache('ui/play.png')),
      position: Vector2(game.playScreenPosition.x - game.tileSize.x * 3 / 2, game.screen.y / 2),
      size: Vector2.all(game.tileSize.x * 2),
      anchor: Anchor.center,
      priority: 7
  );

  @override
  bool onTapDown(TapDownInfo info) {
    size = Vector2.all(game.tileSize.x * 2.5);
    print('mao');
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    size = Vector2.all(game.tileSize.x * 2);
    game.resume();
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
        game.resume();
      }
    }
  }
}