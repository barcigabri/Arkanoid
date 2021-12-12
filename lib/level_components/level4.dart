import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level4 extends Level{

  Level4(ArkanoidGame game):super(game, 3);

  @override
  void generateLevelPositions() {
    for (double y = 1; y < 14; y++) {
      for (double x = 0; x < y; x++){
        if(y == 13 && x != 12) {
          addInPosition(x, y, 2);
        }
        else {
          addInPosition(x, y, 1);
        }
      }
    }
  }
}