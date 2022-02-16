import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level4 extends Level{

  Level4(ArkanoidGame game):super(game, 3);

  @override
  void generateLevelPositions() {
    for (double y = 3; y < 16; y++) {
      for (double x = 1; x < 12; x++) {
        if (x == 4 || x == 8) x++;
        if (y == 7 - x || y == 15 - x || y == 23 - x) {
          addInPosition(x, y, 2);
        }
        else {
          addInPosition(x, y, 1);
        }
      }
    }
  }
}