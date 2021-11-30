import 'dart:ui';

import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

abstract class Selector extends PositionComponent with Draggable {
  final Paint white = Paint()..color = const Color(0xffffffff);

  final double leftBound;
  final double rightBound;

  Selector(Vector2 pos, Vector2 siz, this.leftBound, this.rightBound, int value) : super (
      position: pos,
      size: siz,
      anchor: Anchor.center
  ) {
    updateVariable(value);
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if(info.eventPosition.game.x < leftBound) {
      position.x = leftBound;
    }
    else if(info.eventPosition.game.x > rightBound) {
      position.x = rightBound;
    }
    else {
      position.x = info.eventPosition.game.x;
    }
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    calcolaPosizione();
    return true;
  }

  @override
  void render(Canvas canvas) {

    super.render(canvas);
    canvas.drawCircle((size / 2).toOffset(), size.y / 2, white);

  }

  void calcolaPosizione() {
    int value;
    if(position.x - leftBound <= (rightBound - leftBound) / 4) {
      position.x = leftBound;
      value = 1;
    }
    else if(position.x - leftBound > (rightBound - leftBound) * 3 / 4) {
      position.x = rightBound;
      value = 3;
    }
    else {
      position.x = leftBound + (rightBound - leftBound)/2;
      value = 2;
    }
    updateVariable(value);
  }

  void updateVariable(int value);

  void keyboardAction(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if(position.x != rightBound) {
        position.x += (rightBound - leftBound)/2;
      }
    }
    else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if(position.x != leftBound) {
        position.x -= (rightBound - leftBound)/2;
      }
    }
    calcolaPosizione();
  }

}
