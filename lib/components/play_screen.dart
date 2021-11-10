import 'dart:ui';
import 'package:arkanoid/arkanoid_game.dart';

class PlayScreen {
  final ArkanoidGame game;
  Rect psRect = Rect.zero;

  PlayScreen(this.game){
    psRect = Rect.fromLTWH( //arkanoid size x=93mm y=103mm
      game.screen.x/6,
      game.screen.y/20,
      game.screen.x*2/3,
      game.screen.y*9/10,
    );
  }

  void render(Canvas canvas) {
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xFF0000FF);
    canvas.drawRect(psRect, boxPaint);
  }

  void update(double t) {}
}
