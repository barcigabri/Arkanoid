import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class HomeButton extends TextComponent with Tappable {
  final ArkanoidGame game;


  HomeButton(this.game) : super (
    text: "HOME",
    position: Vector2(game.screen.x/2,game.screen.y*2/3),
    //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
    textRenderer: game.getPainter(20),
  ) {
    anchor = Anchor.center;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    textRenderer = game.getPainter(30);

    return true;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    textRenderer = game.getPainter(20);
    game.removeLostScreen();
    game.startHome();
    return true;
  }

  @override
  bool onTapCancel() {
    textRenderer = game.getPainter(20);
    return true;
  }

}
