import 'dart:ui';

import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/utilities_components/selector.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class SelectorDifficulty extends Selector {

  final ArkanoidGame game;

  int difficulty = 1;

  SelectorDifficulty(this.game, Vector2 pos, Vector2 siz, double leftBound, double rightBound, int value) : super (pos, siz,leftBound,rightBound, value);

  @override
  void updateVariable(int value) {
    difficulty = value;
    for(int i=0; i < game.difficulties.length; i++) {
      if(i == difficulty-1)  {
        game.difficulties.elementAt(i).textRenderer = game.getPainter(15);
      }
      else {
        game.difficulties.elementAt(i).textRenderer = game.getPainter(10);
      }
    }
  }


}
