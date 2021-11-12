import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';
import 'package:flame/game.dart';

class Level1 extends Level{

  Level1(ArkanoidGame game):super(game);

  @override
  void generateLevelPositions() {
    for (double y = /*3*/9; y < 10; y++) {
      for (double x = /*1*/11; x < 12; x++) {
        if (x == 6) x++;
        addInPosition(x, y);
      }
    }
  }
}