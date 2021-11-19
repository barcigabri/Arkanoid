import 'dart:ui';

import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/utilities_components/selector.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class SliderSelection extends PositionComponent with Tappable{
  final Selector selector;
  final Paint white = Paint()..color = const Color(0xffffffff);
  Vector2 pos;
  Vector2 siz;

  // Il PositionComponent mette l'origine in position, size serve per conoscere la superficie tappabile
  SliderSelection(this.selector, this.pos, this.siz) : super (
    position: Vector2(pos.x - siz.x / 8, pos.y - siz.y * 8),
    size: Vector2(siz.x + siz.x / 4, siz.y * 16),
    anchor: Anchor.topLeft
  ) {
    pos = pos - position;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    if(event.eventPosition.game.x < selector.leftBound) {
      selector.position.x = selector.leftBound;
    }
    else if(event.eventPosition.game.x > selector.rightBound) {
      selector.position.x = selector.rightBound;
    }
    else {
      selector.position.x = event.eventPosition.game.x;
    }
    return true;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    selector.calcolaPosizione();
    return true;
  }

  @override
  bool onTapCancel() {
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(pos.toPositionedRect(siz), white);
    canvas.drawCircle(Offset(0, siz.y / 2).translate(siz.x / 8, pos.y), siz.y * 2, white);
    canvas.drawCircle(Offset(siz.x / 2, siz.y / 2).translate(siz.x / 8, pos.y), siz.y * 2, white);
    canvas.drawCircle(Offset(siz.x, siz.y / 2).translate(siz.x / 8, pos.y), siz.y * 2, white);
  }

}
