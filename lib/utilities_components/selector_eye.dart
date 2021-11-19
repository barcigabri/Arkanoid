import 'dart:ui';

import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/utilities_components/selector.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class SelectorEye extends Selector {
  final ArkanoidGame game;


  int eye = 2;

  SelectorEye(this.game, Vector2 pos, Vector2 siz, double leftBound, double rightBound, int value) : super (pos, siz,leftBound,rightBound, value);

  @override
  void updateVariable(int value) {
    eye = value;
    for(int i=0; i<game.eyeChoice.length; i++) {
      if(i == eye-1)  {
        game.eyeChoice.elementAt(i).textRenderer = game.getPainter(15);
      }
      else {
        game.eyeChoice.elementAt(i).textRenderer = game.getPainter(10);
      }
    }
  }

}
