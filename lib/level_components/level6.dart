import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level6 extends Level{

  Level6(ArkanoidGame game):super(game, 0);

  @override
  void generateLevelPositions() {
    // blocchi di destra
    for (double y = 3; y < 8; y++) {
      for (double x = 7; x < 16 - y ; x++) {
        if(x == 7) {
          addInPosition(x, y, 2);
        }
        else {
          addInPosition(x, y, 1);
        }
      }
    }
    // blocchi di sinistra
    for (double y = 9; y < 14; y++) {
      for (double x = y - 9; x < 6; x++) {
        if(x == 5) {
          addInPosition(x, y, 2);
        }
        else {
          addInPosition(x, y, 1);
        }
      }
    }
  }
}