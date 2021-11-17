import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class NoPenalizationButton extends TextComponent with Tappable {
  final ArkanoidGame game;


  NoPenalizationButton(this.game) : super (
    "PLAY WITHOUT\n\nPENALIZATION",
    position: Vector2(game.screen.x/2, game.playScreenPosition.y + game.playScreenSize.y - game.tileSize.y * 4),
    //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
    textRenderer: game.getPainter(8),
  ) {
    anchor = Anchor.center;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    textRenderer = game.getPainter(10);

    return true;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    textRenderer = game.getPainter(8);
    // game.lockOnTapUp = true;
    game.removeEyeSelection();
    game.startGame();
    return true;
  }

  @override
  bool onTapCancel() {
    textRenderer = game.getPainter(8);
    return true;
  }

}
