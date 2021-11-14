import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';
import 'package:flame/game.dart';

class Level3 extends Level{

  Level3(ArkanoidGame game):super(game);

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