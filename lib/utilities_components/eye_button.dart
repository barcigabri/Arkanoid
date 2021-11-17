import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class EyeButton extends TextComponent with Tappable {
  final ArkanoidGame game;
  bool isLeft;


  EyeButton(this.game, this.isLeft) : super (
    "LEFT",
    position: Vector2(game.playScreenPosition.x + game.playScreenSize.x / 4, game.screen.y * 3 / 5),
    //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
    textRenderer: game.getPainter(15),
  ) {
    anchor = Anchor.center;
    if(!isLeft) {
      text = "RIGHT";
      position.x += game.playScreenSize.x / 2;
    }
  }

  @override
  bool onTapDown(TapDownInfo event) {
    textRenderer = game.getPainter(25);

    return true;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    textRenderer = game.getPainter(15);
    // game.lockOnTapUp = true;
    game.addPenalization(isLeft);
    return true;
  }

  @override
  bool onTapCancel() {
    textRenderer = game.getPainter(15);
    return true;
  }

}
